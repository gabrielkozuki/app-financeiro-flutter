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
import '../../l10n/app_localizations.dart';

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

  /// Valor que entra nos cálculos (invariante: fatura pendente não tem
  /// `valorPago`). Delegado para não espalhar a regra — ver [FaturaCartao].
  double get valorEfetivo => fatura.valorEfetivo;
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
  final emTransacao = ref.watch(emTransacaoProvider);
  final reaberto = ref.watch(mesesReabertosProvider);
  final ehPassado = ehMesPassado(mes);

  // Ao visualizar o mês corrente, fecha (tira o retrato) os meses passados que
  // têm dados e ainda não foram fechados — exceto os reabertos nesta sessão.
  // Os repositórios vão por parâmetro: nada de `ref.read` depois de um await,
  // que quebraria a execução antiga se o provider fosse invalidado no meio.
  if (mes == mesCorrente()) {
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
    await _gerarMes(mes,
        contasRepo: contasRepo,
        cartoesRepo: cartoesRepo,
        emTransacao: emTransacao);
  }

  final linhas = await _linhasDoMes(mes,
      contasRepo: contasRepo, cartoesRepo: cartoesRepo);
  final itens = linhas.itens;
  final faturas = linhas.faturas;

  // Num mês fechado (passado, com retrato e não reaberto) TUDO que alimenta o
  // painel vem do snapshot imutável — renda, percentuais e o comprometido por
  // grupo. É o que torna o histórico de fato congelado (RN-06): recalcular ao
  // vivo faria o passado se mexer sempre que a conta de origem mudasse.
  // Fora daí, calcula ao vivo.
  FechamentoMensal? snapshot;
  if (ehPassado && !reaberto.contains(mes)) {
    snapshot = await fechRepo.doMes(mes);
  }
  final renda = snapshot?.rendaTotal ?? await entradasRepo.rendaDoMes(mes);
  final config = snapshot?.snapshotPercentuais ?? await configRepo.vigenteEm(mes);
  final metodologia = const CalcularMetodologia()(
    renda: renda,
    comprometidoPorGrupo:
        snapshot?.totalPorGrupo ?? _comprometidoPorGrupo(itens, faturas),
    config: config,
  );

  return PanoramaMes(itens: itens, faturas: faturas, metodologia: metodologia);
});

/// Carrega as linhas do mês já ordenadas para a checklist: ocorrências (com a
/// conta de origem) e faturas dos cartões ativos (com o rateio).
///
/// Junta por TODAS as contas, não só as ativas — assim as ocorrências de meses
/// passados de uma conta desativada ("excluir daqui em diante") continuam no
/// histórico.
Future<({List<ItemChecklist> itens, List<ItemFatura> faturas})> _linhasDoMes(
  String mes, {
  required ContasRepository contasRepo,
  required CartoesRepository cartoesRepo,
}) async {
  final porId = {for (final c in await contasRepo.listarTodas()) c.id: c};
  final itens = <ItemChecklist>[];
  for (final o in await contasRepo.ocorrenciasDoMes(mes)) {
    final conta = porId[o.contaId];
    if (conta != null) itens.add(ItemChecklist(ocorrencia: o, conta: conta));
  }
  itens.sort((a, b) {
    if (a.ocorrencia.paga != b.ocorrencia.paga) {
      return a.ocorrencia.paga ? 1 : -1;
    }
    return a.conta.diaVencimento.compareTo(b.conta.diaVencimento);
  });

  final cartoes = {for (final c in await cartoesRepo.listarAtivos()) c.id: c};
  final faturas = <ItemFatura>[];
  for (final f in await cartoesRepo.faturasDoMes(mes)) {
    final cartao = cartoes[f.cartaoId];
    if (cartao == null) continue;
    faturas.add(ItemFatura(
      fatura: f,
      cartao: cartao,
      rateios: await cartoesRepo.rateiosDaFatura(f.id),
    ));
  }
  faturas.sort((a, b) {
    if (a.fatura.paga != b.fatura.paga) return a.fatura.paga ? 1 : -1;
    return a.cartao.diaVencimento.compareTo(b.cartao.diaVencimento);
  });

  return (itens: itens, faturas: faturas);
}

/// Comprometido por grupo: as ocorrências entram pelo grupo da conta; a fatura
/// entra rateada (RN-08). Uma implementação só para a tela e para o retrato do
/// fechamento — se divergissem, o histórico congelaria um número diferente do
/// que o usuário viu no mês.
Map<Grupo, double> _comprometidoPorGrupo(
    List<ItemChecklist> itens, List<ItemFatura> faturas) {
  final comprometido = <Grupo, double>{};
  for (final i in itens) {
    comprometido[i.conta.grupo] =
        (comprometido[i.conta.grupo] ?? 0) + i.ocorrencia.valorEfetivo;
  }
  const rateador = RatearFatura();
  for (final f in faturas) {
    final porGrupo = rateador.comprometidoPorGrupo(
        valorTotal: f.valorEfetivo, rateios: f.rateios);
    porGrupo.forEach(
        (g, v) => comprometido[g] = (comprometido[g] ?? 0) + v);
  }
  return comprometido;
}

/// Executa a virada do mês, inserindo as ocorrências e faturas que faltam.
///
/// Não precisa de trava contra execução concorrente: a idempotência é do banco
/// (índice único por conta/mês e cartão/mês + `DoNothing`), coberta por
/// `test/persistence/esquema_test.dart`. Duas abas observam a MESMA instância
/// do family, então o Riverpod já compartilha uma única computação por mês.
Future<void> _gerarMes(
  String mes, {
  required ContasRepository contasRepo,
  required CartoesRepository cartoesRepo,
  required Future<void> Function(Future<void> Function()) emTransacao,
}) async {
  final gerado = const GerarMes()(
    mesReferencia: mes,
    contasFixasAtivas: await contasRepo.listarFixasAtivas(),
    contaIdsComOcorrenciaNoMes: await contasRepo.contaIdsComOcorrenciaNoMes(mes),
    cartoesAtivos: await cartoesRepo.listarAtivos(),
    cartaoIdsComFaturaNoMes: await cartoesRepo.cartaoIdsComFaturaNoMes(mes),
  );
  if (gerado.ocorrencias.isEmpty && gerado.faturas.isEmpty) return;

  // Um commit só para a virada inteira: são ~20-25 linhas no primeiro acesso
  // de cada mês, e sem isto cada INSERT vira uma ida ao isolate do banco —
  // desperdício justamente no momento em que o usuário está abrindo o app.
  await emTransacao(() async {
    for (final o in gerado.ocorrencias) {
      await contasRepo.inserirOcorrencia(
        contaId: o.contaId,
        mesReferencia: o.mesReferencia,
        valorPlanejado: o.valorPlanejado,
      );
    }
    for (final f in gerado.faturas) {
      await cartoesRepo.criarFatura(
          cartaoId: f.cartaoId, mesReferencia: f.mesReferencia);
    }
  });
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
  // Duas consultas fixas (meses com dados + meses já fechados) e a diferença
  // entre os conjuntos. Antes era um `doMes` POR MÊS: com 10 anos de uso, 120
  // consultas a cada invalidação do panorama só para concluir que não há nada
  // a fechar — que é o caso comum.
  final jaFechados = await fechRepo.mesesFechados();
  for (final m in await fechRepo.mesesComDados()) {
    if (m.compareTo(mesAtual) < 0 &&
        !reaberto.contains(m) &&
        !jaFechados.contains(m)) {
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
  final linhas = await _linhasDoMes(mes,
      contasRepo: contasRepo, cartoesRepo: cartoesRepo);

  await fechRepo.salvar(FechamentoMensal(
    mesReferencia: mes,
    rendaTotal: await entradasRepo.rendaDoMes(mes),
    totalPorGrupo: _comprometidoPorGrupo(linhas.itens, linhas.faturas),
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

/// Ritual obrigatório depois de TROCAR o banco inteiro: apagar tudo (RF-20),
/// restaurar um backup ou concluir o onboarding.
///
/// São duas coisas que precisam andar juntas — descartar o cache de leitura e
/// esquecer os meses reabertos, que são de dados que podem não existir mais.
/// Existe como função única porque o M8 acrescenta dois chamadores (restaurar
/// da nuvem e de arquivo), e um ritual de duas linhas copiado em quatro lugares
/// é a receita conhecida de "restaurei e a tela continuou mostrando o antigo".
void aposMudancaAmpla(WidgetRef ref) {
  invalidarLeituras(ref);
  ref.read(mesesReabertosProvider.notifier).limpar();
}

/// Reabre o mês selecionado para edição: descarta o retrato e marca o mês como
/// reaberto nesta sessão (fica editável, restrito às ocorrências daquele mês).
Future<void> reabrirMesSelecionado(BuildContext context, WidgetRef ref) async {
  final mes = ref.read(mesReferenciaProvider);
  final fechRepo = ref.read(fechamentoRepoProvider);
  final ok = await executarComFeedback(
    context,
    () => fechRepo.excluir(mes),
    mensagemErro: AppLocalizations.of(context).mesErroReabrir,
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
    mensagemErro: AppLocalizations.of(context).mesErroConcluirEdicao,
  );
  if (!ok || !context.mounted) return;
  ref.read(mesesReabertosProvider.notifier).refechar(mes);
  ref.invalidate(panoramaMesProvider);
}

/// Indica que o mês selecionado é um mês fechado atualmente REABERTO (editável).
final mesEditandoFechadoProvider = Provider<bool>((ref) {
  final mes = ref.watch(mesReferenciaProvider);
  final reaberto = ref.watch(mesesReabertosProvider);
  return ehMesPassado(mes) && reaberto.contains(mes);
});

/// Somente leitura na UI (RN-05/RF-18): mês passado que NÃO foi reaberto nesta
/// sessão. Reabrir um mês o torna editável até ser fechado de novo.
final mesSomenteLeituraProvider = Provider<bool>((ref) {
  final mes = ref.watch(mesReferenciaProvider);
  final reaberto = ref.watch(mesesReabertosProvider);
  return ehMesPassado(mes) && !reaberto.contains(mes);
});
