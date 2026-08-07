import 'package:app_financeiro/data/db/app_database.dart';
import 'package:app_financeiro/data/export_service.dart';
import 'package:app_financeiro/data/repositories/drift_cartoes_repository.dart';
import 'package:app_financeiro/data/repositories/drift_config_repository.dart';
import 'package:app_financeiro/data/repositories/drift_contas_repository.dart';
import 'package:app_financeiro/data/repositories/drift_entradas_repository.dart';
import 'package:app_financeiro/data/repositories/drift_fechamento_repository.dart';
import 'package:app_financeiro/domain/entities/cartao.dart';
import 'package:app_financeiro/domain/entities/conta.dart';
import 'package:app_financeiro/domain/entities/configuracao.dart';
import 'package:app_financeiro/domain/entities/entrada.dart';
import 'package:app_financeiro/domain/entities/enums.dart';
import 'package:app_financeiro/domain/usecases/ratear_fatura.dart';
import 'package:app_financeiro/features/mes/mes_panorama.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Comportamento das regras de negócio sobre o banco (drift em memória).
/// Cobre RN-02, RN-03, RN-04, RN-06, RN-08 e o fechamento/exportação.
void main() {
  late AppDatabase db;
  late DriftContasRepository contas;
  late DriftEntradasRepository entradas;
  late DriftConfigRepository config;
  late DriftCartoesRepository cartoes;
  late DriftFechamentoRepository fechamentos;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    contas = DriftContasRepository(db);
    entradas = DriftEntradasRepository(db);
    config = DriftConfigRepository(db);
    cartoes = DriftCartoesRepository(db);
    fechamentos = DriftFechamentoRepository(db);
  });
  tearDown(() => db.close());

  Conta contaFixa(String nome, Grupo grupo, double valor) => Conta(
        id: 0,
        nome: nome,
        grupo: grupo,
        valorPlanejado: valor,
        diaVencimento: 5,
        recorrencia: Recorrencia.fixa,
      );

  group('Contas e ocorrências', () {
    test('marcar paga usa o valor pago nos cálculos do mês (RN-04)', () async {
      final id = await contas.criar(contaFixa('Aluguel', Grupo.necessidade, 1200));
      await contas.inserirOcorrencia(
          contaId: id, mesReferencia: '2026-07', valorPlanejado: 1200);

      var o = (await contas.ocorrenciasDoMes('2026-07')).single;
      await contas.marcarPaga(o.id, valorPago: 1180);
      o = (await contas.ocorrenciasDoMes('2026-07')).single;
      expect(o.paga, isTrue);
      expect(o.valorEfetivo, 1180);

      await contas.desmarcar(o.id);
      o = (await contas.ocorrenciasDoMes('2026-07')).single;
      expect(o.valorEfetivo, 1200);
    });

    test('"só deste mês" oculta mas não é recriada na virada (RN-03/RF-07)',
        () async {
      final id = await contas.criar(contaFixa('Energia', Grupo.necessidade, 180));
      await contas.inserirOcorrencia(
          contaId: id, mesReferencia: '2026-08', valorPlanejado: 180);

      final o = (await contas.ocorrenciasDoMes('2026-08')).single;
      await contas.removerOcorrenciaDoMes(o.id);

      expect(await contas.ocorrenciasDoMes('2026-08'), isEmpty);
      expect(await contas.contaIdsComOcorrenciaNoMes('2026-08'), isNotEmpty);
    });

    test('"deste mês em diante" preserva meses anteriores (RN-03)', () async {
      final id = await contas.criar(contaFixa('Energia', Grupo.necessidade, 180));
      await contas.inserirOcorrencia(
          contaId: id, mesReferencia: '2026-07', valorPlanejado: 180);
      await contas.inserirOcorrencia(
          contaId: id, mesReferencia: '2026-08', valorPlanejado: 180);

      await contas.excluirOcorrenciasDaContaAPartirDe(id, '2026-08');
      await contas.definirAtiva(id, false);

      expect((await contas.ocorrenciasDoMes('2026-07')).length, 1);
      expect(await contas.ocorrenciasDoMes('2026-08'), isEmpty);
      expect(await contas.listarAtivas(), isEmpty);
      expect((await contas.listarTodas()).length, 1); // segue no histórico
    });
  });

  group('Entradas e configuração', () {
    test('renda do mês soma recorrentes + pontuais do mês (RN-02)', () async {
      await entradas.criar(const Entrada(
          id: 0,
          nome: 'Salário',
          valorLiquido: 3000,
          tipo: TipoEntrada.recorrente));
      await entradas.criar(const Entrada(
        id: 0,
        nome: '13º',
        valorLiquido: 1500,
        tipo: TipoEntrada.pontual,
        mesReferencia: '2026-12',
      ));
      expect(await entradas.rendaDoMes('2026-07'), 3000);
      expect(await entradas.rendaDoMes('2026-12'), 4500);
    });

    test('config vigente: padrão 50-30-20 e snapshot mais recente (RN-06)',
        () async {
      expect((await config.vigenteEm('2026-07')).percentualNecessidades, 50);

      await config.salvar(
          const ConfiguracaoMetodologia(mesVigenciaInicial: '2026-01'));
      await config.salvar(const ConfiguracaoMetodologia(
        mesVigenciaInicial: '2026-06',
        percentualNecessidades: 70,
        percentualDesejos: 20,
        percentualPoupanca: 10,
      ));
      expect((await config.vigenteEm('2026-03')).percentualNecessidades, 50);
      expect((await config.vigenteEm('2026-08')).percentualNecessidades, 70);
    });
  });

  group('Cartões e faturas', () {
    test('fatura: valor, rateio (RN-08) e pagamento', () async {
      final cartaoId = await cartoes
          .criar(const Cartao(id: 0, nome: 'Nubank', diaVencimento: 12));
      final faturaId =
          await cartoes.criarFatura(cartaoId: cartaoId, mesReferencia: '2026-07');

      await cartoes.definirValorFatura(faturaId, 2000);
      await cartoes.salvarRateio(faturaId,
          {Grupo.necessidade: 1400, Grupo.desejo: 600});

      final rateios = await cartoes.rateiosDaFatura(faturaId);
      final porGrupo = const RatearFatura()
          .comprometidoPorGrupo(valorTotal: 2000, rateios: rateios);
      expect(porGrupo[Grupo.necessidade], 1400);
      expect(porGrupo[Grupo.desejo], 600);

      await cartoes.marcarFaturaPaga(faturaId, valorPago: 1950);
      expect((await cartoes.faturasDoMes('2026-07')).single.paga, isTrue);
    });

    test('excluir cartão remove faturas e rateios', () async {
      final cartaoId = await cartoes
          .criar(const Cartao(id: 0, nome: 'Inter', diaVencimento: 8));
      final faturaId =
          await cartoes.criarFatura(cartaoId: cartaoId, mesReferencia: '2026-07');
      await cartoes.salvarRateio(faturaId, {Grupo.necessidade: 100});

      await cartoes.excluir(cartaoId);
      expect(await cartoes.listarAtivos(), isEmpty);
      expect(await cartoes.faturasDoMes('2026-07'), isEmpty);
      expect(await cartoes.rateiosDaFatura(faturaId), isEmpty);
    });
  });

  group('Fechamento mensal', () {
    test('fecharMes congela renda, totais e percentuais do mês', () async {
      await entradas.criar(const Entrada(
          id: 0,
          nome: 'Salário',
          valorLiquido: 3000,
          tipo: TipoEntrada.recorrente));
      final id = await contas.criar(contaFixa('Aluguel', Grupo.necessidade, 1560));
      await contas.inserirOcorrencia(
          contaId: id, mesReferencia: '2026-05', valorPlanejado: 1560);

      await fecharMes(
        mes: '2026-05',
        contasRepo: contas,
        cartoesRepo: cartoes,
        entradasRepo: entradas,
        configRepo: config,
        fechRepo: fechamentos,
      );

      final f = (await fechamentos.doMes('2026-05'))!;
      expect(f.rendaTotal, 3000);
      expect(f.totalPorGrupo[Grupo.necessidade], 1560);
      expect(f.snapshotPercentuais.percentualNecessidades, 50);
    });

    test('reabrir e refechar grava o retrato corrigido, sem duplicá-lo (RN-06)',
        () async {
      Future<void> fechar() => fecharMes(
            mes: '2026-05',
            contasRepo: contas,
            cartoesRepo: cartoes,
            entradasRepo: entradas,
            configRepo: config,
            fechRepo: fechamentos,
          );

      await entradas.criar(const Entrada(
          id: 0,
          nome: 'Salário',
          valorLiquido: 3000,
          tipo: TipoEntrada.recorrente));
      final id = await contas.criar(contaFixa('Aluguel', Grupo.necessidade, 1560));
      final ocorrenciaId = await contas.inserirOcorrencia(
          contaId: id, mesReferencia: '2026-05', valorPlanejado: 1560);
      await fechar();

      // Mês fechado: mexer nos dados de hoje NÃO reescreve o retrato (RN-05).
      await entradas.criar(const Entrada(
        id: 0,
        nome: 'Freela',
        valorLiquido: 500,
        tipo: TipoEntrada.pontual,
        mesReferencia: '2026-05',
      ));
      expect((await fechamentos.doMes('2026-05'))!.rendaTotal, 3000);

      // Reabrir descarta só o retrato: as ocorrências do mês seguem intactas.
      await fechamentos.excluir('2026-05');
      expect(await fechamentos.doMes('2026-05'), isNull);
      expect(await contas.ocorrenciasDoMes('2026-05'), hasLength(1));

      // Correção feita com o mês reaberto: o aluguel daquele mês saiu 1400.
      await contas.marcarPaga(ocorrenciaId, valorPago: 1400);
      // E os percentuais passaram a ser 70-20-10 a partir daquele mês.
      await config.salvar(const ConfiguracaoMetodologia(
        mesVigenciaInicial: '2026-05',
        percentualNecessidades: 70,
        percentualDesejos: 20,
        percentualPoupanca: 10,
      ));

      // "Concluir edição": tira um retrato novo, relendo renda, totais e
      // percentuais — é o único caminho que altera um mês já fechado.
      await fechar();
      final f = (await fechamentos.doMes('2026-05'))!;
      expect(f.rendaTotal, 3500);
      expect(f.totalPorGrupo[Grupo.necessidade], 1400);
      expect(f.snapshotPercentuais.percentualNecessidades, 70);

      // O mês é a chave do retrato: refechar substitui, nunca acumula linhas.
      expect(await db.select(db.fechamentosMensais).get(), hasLength(1));
    });
  });

  group('Exportação e limpeza', () {
    test('backup JSON faz round-trip e apagarTudo limpa (RF-19/RF-20)',
        () async {
      final service = ExportService(db);
      await entradas.criar(const Entrada(
          id: 0,
          nome: 'Salário',
          valorLiquido: 3000,
          tipo: TipoEntrada.recorrente));
      final id = await contas.criar(contaFixa('Aluguel', Grupo.necessidade, 1200));
      await contas.inserirOcorrencia(
          contaId: id, mesReferencia: '2026-07', valorPlanejado: 1200);

      final json = await service.exportarJson();
      await service.apagarTudo();
      expect(await contas.listarAtivas(), isEmpty);
      expect(await entradas.contarTodas(), 0);

      await service.importarJson(json);
      expect((await contas.listarAtivas()).single.nome, 'Aluguel');
      expect(await entradas.contarTodas(), 1);
    });
  });
}
