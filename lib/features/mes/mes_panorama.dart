import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/feedback.dart';
import '../../core/format/dates.dart';
import '../../core/providers.dart';
import '../../domain/entities/cartao.dart';
import '../../domain/entities/conta.dart';
import '../../domain/entities/configuracao.dart';
import '../../domain/entities/enums.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/usecases/calcular_metodologia.dart';
import '../../domain/usecases/gerar_mes.dart';
import '../../domain/usecases/ratear_fatura.dart';

/// Uma linha da checklist: a ocorrência do mês + a conta de origem.
class ItemChecklist {
  const ItemChecklist({required this.ocorrencia, required this.conta});

  final OcorrenciaConta ocorrencia;
  final Conta conta;
}

/// Uma fatura de cartão do mês, com o cartão e o rateio entre grupos (RF-22/23).
class ItemFatura {
  const ItemFatura({
    required this.fatura,
    required this.cartao,
    required this.rateios,
  });

  final FaturaCartao fatura;
  final Cartao cartao;
  final List<RateioFatura> rateios;

  /// Valor que entra nos cálculos: pago, se houver; senão o total informado.
  double get valorEfetivo => fatura.valorPago ?? fatura.valorTotal ?? 0;
}

/// Panorama consolidado do mês selecionado — alimenta a aba Contas (checklist +
/// "pago este mês") e a aba Gráfico (rosca 50-30-20).
class PanoramaMes {
  const PanoramaMes({
    required this.itens,
    required this.faturas,
    required this.metodologia,
  });

  final List<ItemChecklist> itens;
  final List<ItemFatura> faturas;
  final ResultadoMetodologia metodologia;

  double get total =>
      itens.fold<double>(0, (s, i) => s + i.ocorrencia.valorEfetivo) +
      faturas.fold<double>(0, (s, f) => s + f.valorEfetivo);

  double get pago =>
      itens
          .where((i) => i.ocorrencia.paga)
          .fold<double>(0, (s, i) => s + i.ocorrencia.valorEfetivo) +
      faturas
          .where((f) => f.fatura.paga)
          .fold<double>(0, (s, f) => s + f.valorEfetivo);

  int get totalLinhas => itens.length + faturas.length;
  int get quantidadePagas =>
      itens.where((i) => i.ocorrencia.paga).length +
      faturas.where((f) => f.fatura.paga).length;
}

/// Carrega e calcula o panorama de um mês (`YYYY-MM`). É um family para que
/// cada mês tenha o próprio cache: ao voltar para um mês já visitado a lista
/// aparece pronta, em vez de piscar. Recomputado quando invalidado após uma
/// alteração — invalidar a family inteira recarrega todos os meses vivos.
final panoramaMesProvider =
    FutureProvider.family<PanoramaMes, String>((ref, mes) async {
  final contasRepo = ref.watch(contasRepoProvider);
  final cartoesRepo = ref.watch(cartoesRepoProvider);
  final entradasRepo = ref.watch(entradasRepoProvider);
  final configRepo = ref.watch(configRepoProvider);
  final fechRepo = ref.watch(fechamentoRepoProvider);
  final reaberto = ref.watch(mesesReabertosProvider);
  final ehPassado = _ehMesPassado(mes);

  // Ao visualizar o mês corrente, fecha (tira o retrato) os meses passados que
  // têm dados e ainda não foram fechados — exceto os reabertos nesta sessão.
  // Os repositórios vão por parâmetro: nada de `ref.read` depois de um await,
  // que quebraria a execução antiga se o provider fosse invalidado no meio.
  if (mes == mesReferencia(DateTime.now())) {
    await _garantirFechamentos(
      mesAtual: mes,
      reaberto: reaberto,
      contasRepo: contasRepo,
      cartoesRepo: cartoesRepo,
      entradasRepo: entradasRepo,
      configRepo: configRepo,
      fechRepo: fechRepo,
    );
  }

  // Virada de mês (RF-16): só o mês corrente e os futuros geram as ocorrências
  // das contas fixas e as faturas que ainda não existem. Mês passado NUNCA é
  // gerado — é recorte histórico (RN-05), inclusive quando reaberto: reabrir
  // serve para corrigir o que já existe naquele mês, não para injetar nele as
  // contas de hoje.
  if (!ehPassado) {
    await _garantirMesGerado(mes,
        contasRepo: contasRepo, cartoesRepo: cartoesRepo);
  }

  // Junta por TODAS as contas (não só ativas): assim as ocorrências de meses
  // passados de uma conta desativada ("excluir daqui em diante") continuam no
  // histórico.
  final todasContas = await contasRepo.listarTodas();
  final porId = {for (final c in todasContas) c.id: c};
  final ocorrencias = await contasRepo.ocorrenciasDoMes(mes);

  final comprometido = <Grupo, double>{};
  final itens = <ItemChecklist>[];
  for (final o in ocorrencias) {
    final conta = porId[o.contaId];
    if (conta == null) continue;
    itens.add(ItemChecklist(ocorrencia: o, conta: conta));
    comprometido[conta.grupo] =
        (comprometido[conta.grupo] ?? 0) + o.valorEfetivo;
  }
  itens.sort((a, b) {
    if (a.ocorrencia.paga != b.ocorrencia.paga) {
      return a.ocorrencia.paga ? 1 : -1;
    }
    return a.conta.diaVencimento.compareTo(b.conta.diaVencimento);
  });

  // Faturas de cartão do mês + rateio entre grupos.
  const rateador = RatearFatura();
  final cartoes = {for (final c in await cartoesRepo.listarAtivos()) c.id: c};
  final faturasRows = await cartoesRepo.faturasDoMes(mes);
  final faturas = <ItemFatura>[];
  for (final f in faturasRows) {
    final cartao = cartoes[f.cartaoId];
    if (cartao == null) continue;
    final rateios = await cartoesRepo.rateiosDaFatura(f.id);
    faturas.add(ItemFatura(fatura: f, cartao: cartao, rateios: rateios));
    final porGrupo = rateador.comprometidoPorGrupo(
        valorTotal: f.valorPago ?? f.valorTotal, rateios: rateios);
    for (final entry in porGrupo.entries) {
      comprometido[entry.key] = (comprometido[entry.key] ?? 0) + entry.value;
    }
  }
  faturas.sort((a, b) {
    if (a.fatura.paga != b.fatura.paga) return a.fatura.paga ? 1 : -1;
    return a.cartao.diaVencimento.compareTo(b.cartao.diaVencimento);
  });

  // Fonte da renda/percentuais: num mês fechado (passado, com retrato e não
  // reaberto), lê do snapshot imutável — assim mudar a renda hoje NÃO reescreve
  // o histórico. Caso contrário, calcula ao vivo.
  FechamentoMensal? snapshot;
  if (ehPassado && !reaberto.contains(mes)) {
    snapshot = await fechRepo.doMes(mes);
  }
  final renda = snapshot?.rendaTotal ?? await entradasRepo.rendaDoMes(mes);
  final config = snapshot?.snapshotPercentuais ?? await configRepo.vigenteEm(mes);
  final metodologia = const CalcularMetodologia()(
    renda: renda,
    comprometidoPorGrupo: comprometido,
    config: config,
  );

  return PanoramaMes(itens: itens, faturas: faturas, metodologia: metodologia);
});

/// Viradas em andamento, por mês. O provider é invalidado a cada alteração e
/// pode ser observado por duas abas ao mesmo tempo: sem isso, duas execuções
/// concorrentes fariam a mesma virada em paralelo. Quem chega depois espera a
/// escrita que já está em voo.
final Map<String, Future<void>> _viradasEmVoo = {};

/// Executa a virada do mês (uma vez por mês, mesmo com chamadas concorrentes),
/// inserindo as ocorrências e faturas que faltam.
Future<void> _garantirMesGerado(
  String mes, {
  required ContasRepository contasRepo,
  required CartoesRepository cartoesRepo,
}) {
  final emVoo = _viradasEmVoo[mes];
  if (emVoo != null) return emVoo;

  final futuro =
      _gerarMes(mes, contasRepo: contasRepo, cartoesRepo: cartoesRepo);
  _viradasEmVoo[mes] = futuro;
  // Limpa ao concluir (inclusive em erro) para o mapa não virar cache eterno.
  return futuro.whenComplete(() => _viradasEmVoo.remove(mes));
}

Future<void> _gerarMes(
  String mes, {
  required ContasRepository contasRepo,
  required CartoesRepository cartoesRepo,
}) async {
  final gerado = const GerarMes()(
    mesReferencia: mes,
    contasFixasAtivas: await contasRepo.listarFixasAtivas(),
    contaIdsComOcorrenciaNoMes: await contasRepo.contaIdsComOcorrenciaNoMes(mes),
    cartoesAtivos: await cartoesRepo.listarAtivos(),
    cartaoIdsComFaturaNoMes: await cartoesRepo.cartaoIdsComFaturaNoMes(mes),
  );

  for (final o in gerado.ocorrencias) {
    await contasRepo.inserirOcorrencia(
      contaId: o.contaId,
      mesReferencia: o.mesReferencia,
      valorPlanejado: o.valorPlanejado,
    );
  }
  for (final f in gerado.faturas) {
    await cartoesRepo.criarFatura(cartaoId: f.cartaoId, mesReferencia: f.mesReferencia);
  }
}

/// Fecha os meses passados que têm dados e ainda não têm retrato — exceto os
/// reabertos nesta sessão (que estão sendo editados de propósito).
Future<void> _garantirFechamentos({
  required String mesAtual,
  required Set<String> reaberto,
  required ContasRepository contasRepo,
  required CartoesRepository cartoesRepo,
  required EntradasRepository entradasRepo,
  required ConfigRepository configRepo,
  required FechamentoRepository fechRepo,
}) async {
  for (final m in await fechRepo.mesesComDados()) {
    if (m.compareTo(mesAtual) < 0 &&
        !reaberto.contains(m) &&
        await fechRepo.doMes(m) == null) {
      await fecharMes(
        mes: m,
        contasRepo: contasRepo,
        cartoesRepo: cartoesRepo,
        entradasRepo: entradasRepo,
        configRepo: configRepo,
        fechRepo: fechRepo,
      );
    }
  }
}

/// Tira o retrato imutável de um mês: renda, totais por grupo e percentuais
/// vigentes congelados (seção 8). Recebe os repositórios explicitamente para
/// poder ser chamado tanto de um provider quanto de um widget.
Future<void> fecharMes({
  required String mes,
  required ContasRepository contasRepo,
  required CartoesRepository cartoesRepo,
  required EntradasRepository entradasRepo,
  required ConfigRepository configRepo,
  required FechamentoRepository fechRepo,
}) async {
  final contas = {for (final c in await contasRepo.listarTodas()) c.id: c};
  final comprometido = <Grupo, double>{};
  for (final o in await contasRepo.ocorrenciasDoMes(mes)) {
    final c = contas[o.contaId];
    if (c == null) continue;
    comprometido[c.grupo] = (comprometido[c.grupo] ?? 0) + o.valorEfetivo;
  }
  const rateador = RatearFatura();
  for (final f in await cartoesRepo.faturasDoMes(mes)) {
    final rateios = await cartoesRepo.rateiosDaFatura(f.id);
    final porGrupo = rateador.comprometidoPorGrupo(
        valorTotal: f.valorPago ?? f.valorTotal, rateios: rateios);
    porGrupo.forEach((k, v) => comprometido[k] = (comprometido[k] ?? 0) + v);
  }

  await fechRepo.salvar(FechamentoMensal(
    mesReferencia: mes,
    rendaTotal: await entradasRepo.rendaDoMes(mes),
    totalPorGrupo: comprometido,
    snapshotPercentuais: await configRepo.vigenteEm(mes),
  ));
}

/// Descarta o cache de TODOS os providers de leitura. Nenhum deles é
/// autoDispose, então o que não for invalidado depois de uma escrita ampla
/// (apagar tudo, concluir o onboarding, importar backup) continua exibindo
/// dados que não existem mais. `panoramaMesProvider` é uma family: invalidar a
/// family recarrega todos os meses em cache.
///
/// Mora aqui, e não em `core/providers.dart`, porque só o panorama está fora do
/// core — deixá-lo lá obrigava `core` a importar `features`, invertendo a
/// direção das camadas.
void invalidarLeituras(WidgetRef ref) {
  ref.invalidate(panoramaMesProvider);
  ref.invalidate(entradasProvider);
  ref.invalidate(entradasDoMesProvider);
  ref.invalidate(cartoesProvider);
  ref.invalidate(precisaOnboardingProvider);
}

/// Reabre o mês selecionado para edição: descarta o retrato e marca o mês como
/// reaberto nesta sessão (fica editável, restrito às ocorrências daquele mês).
Future<void> reabrirMesSelecionado(BuildContext context, WidgetRef ref) async {
  final mes = ref.read(mesReferenciaProvider);
  final fechRepo = ref.read(fechamentoRepoProvider);
  final ok = await executarComFeedback(
    context,
    () => fechRepo.excluir(mes),
    mensagemErro: 'Não foi possível reabrir o mês.',
  );
  if (!ok || !context.mounted) return;
  ref.read(mesesReabertosProvider.notifier).reabrir(mes);
  ref.invalidate(panoramaMesProvider);
}

/// Conclui a edição de um mês reaberto: tira um novo retrato (com as correções)
/// e volta o mês para somente leitura.
Future<void> concluirEdicaoMesSelecionado(
    BuildContext context, WidgetRef ref) async {
  final mes = ref.read(mesReferenciaProvider);
  final contasRepo = ref.read(contasRepoProvider);
  final cartoesRepo = ref.read(cartoesRepoProvider);
  final entradasRepo = ref.read(entradasRepoProvider);
  final configRepo = ref.read(configRepoProvider);
  final fechRepo = ref.read(fechamentoRepoProvider);
  final ok = await executarComFeedback(
    context,
    () => fecharMes(
      mes: mes,
      contasRepo: contasRepo,
      cartoesRepo: cartoesRepo,
      entradasRepo: entradasRepo,
      configRepo: configRepo,
      fechRepo: fechRepo,
    ),
    mensagemErro: 'Não foi possível concluir a edição do mês.',
  );
  if (!ok || !context.mounted) return;
  ref.read(mesesReabertosProvider.notifier).refechar(mes);
  ref.invalidate(panoramaMesProvider);
}

/// Indica que o mês selecionado é um mês fechado atualmente REABERTO (editável).
final mesEditandoFechadoProvider = Provider<bool>((ref) {
  final mes = ref.watch(mesReferenciaProvider);
  final reaberto = ref.watch(mesesReabertosProvider);
  return _ehMesPassado(mes) && reaberto.contains(mes);
});

/// Um mês é "passado" (candidato a fechado) quando começa antes do mês atual.
/// A chave `YYYY-MM` é zero-padded, então a comparação textual serve de ordem.
bool _ehMesPassado(String mes) =>
    mes.compareTo(mesReferencia(DateTime.now())) < 0;

/// Somente leitura na UI (RN-05/RF-18): mês passado que NÃO foi reaberto nesta
/// sessão. Reabrir um mês o torna editável até ser fechado de novo.
final mesSomenteLeituraProvider = Provider<bool>((ref) {
  final mes = ref.watch(mesReferenciaProvider);
  final reaberto = ref.watch(mesesReabertosProvider);
  return _ehMesPassado(mes) && !reaberto.contains(mes);
});
