import 'dart:convert';

import 'package:app_financeiro/data/db/app_database.dart';
import 'package:app_financeiro/data/backup_service.dart';
import 'package:app_financeiro/domain/entities/enums.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contrato do backup JSON — a base declarada do backup em nuvem do M8.
///
/// O teste que existia cobria 1 entrada, 1 conta e 1 ocorrência, e conferia só
/// nome e contagem. Aqui as 8 tabelas são semeadas com os casos que de fato
/// quebram um round-trip (data de pagamento, soft-delete, nulos, chaves
/// estrangeiras, duas vigências) e a comparação é **linha a linha**: as
/// `DataClass` do drift têm `==` gerado, então igualdade de conjunto pega
/// qualquer campo perdido no caminho.
void main() {
  late AppDatabase db;
  late BackupService service;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    service = BackupService(db);
  });
  tearDown(() => db.close());

  /// Semeia as 8 tabelas. Ids explícitos para o teste poder afirmar que o
  /// backup os PRESERVA — se fossem regerados, as chaves estrangeiras
  /// (contaId, cartaoId, faturaCartaoId) passariam a apontar para outra linha.
  Future<void> semear() async {
    await db.into(db.entradas).insert(EntradasCompanion.insert(
        id: const Value(1),
        nome: 'Salário',
        valorLiquido: 5000,
        tipo: TipoEntrada.recorrente,
        diaRecebimento: const Value(5)));
    // Entrada pontual: `mesReferencia` preenchido e `diaRecebimento` nulo — o
    // par de nulos invertido em relação à recorrente acima.
    await db.into(db.entradas).insert(EntradasCompanion.insert(
        id: const Value(2),
        nome: '13º',
        valorLiquido: 4000,
        tipo: TipoEntrada.pontual,
        mesReferencia: const Value('2026-12')));

    await db.into(db.contas).insert(ContasCompanion.insert(
        id: const Value(10),
        nome: 'Aluguel',
        grupo: Grupo.necessidade,
        valorPlanejado: 1800,
        diaVencimento: 5,
        recorrencia: Recorrencia.fixa));
    await db.into(db.contas).insert(ContasCompanion.insert(
        id: const Value(11),
        nome: 'Notebook',
        grupo: Grupo.desejo,
        valorPlanejado: 300,
        diaVencimento: 12,
        recorrencia: Recorrencia.parcelada,
        totalParcelas: const Value(10),
        ativa: const Value(false)));

    // Paga, com data de pagamento e valor pago diferente do planejado (RN-04).
    await db.into(db.ocorrenciasConta).insert(OcorrenciasContaCompanion.insert(
        id: const Value(100),
        contaId: 10,
        mesReferencia: '2026-07',
        valorPlanejado: 1800,
        valorPago: const Value(1750.55),
        dataPagamento: Value(DateTime.utc(2026, 7, 4, 13, 30)),
        status: const Value(StatusPagamento.paga)));
    // Removida "só deste mês" (RF-07): soft-delete precisa sobreviver, senão a
    // virada recria a conta que o usuário apagou.
    await db.into(db.ocorrenciasConta).insert(OcorrenciasContaCompanion.insert(
        id: const Value(101),
        contaId: 11,
        mesReferencia: '2026-07',
        valorPlanejado: 300,
        parcelaAtual: const Value(3),
        removida: const Value(true)));

    await db.into(db.cartoes).insert(CartoesCompanion.insert(
        id: const Value(20), nome: 'Nubank', diaVencimento: 15));
    await db.into(db.faturasCartao).insert(FaturasCartaoCompanion.insert(
        id: const Value(200),
        cartaoId: 20,
        mesReferencia: '2026-07',
        valorTotal: const Value(2000),
        valorPago: const Value(2000),
        status: const Value(StatusPagamento.paga)));
    await db.into(db.rateiosFatura).insert(RateiosFaturaCompanion.insert(
        id: const Value(300), faturaCartaoId: 200, grupo: Grupo.necessidade, valor: 1400));
    await db.into(db.rateiosFatura).insert(RateiosFaturaCompanion.insert(
        id: const Value(301), faturaCartaoId: 200, grupo: Grupo.desejo, valor: 600));

    // Duas vigências: a leitura correta depende da ordem, então as duas
    // precisam voltar.
    await db.into(db.configuracoesMetodologia).insert(
        ConfiguracoesMetodologiaCompanion.insert(
            id: const Value(40), mesVigenciaInicial: '2026-01'));
    await db.into(db.configuracoesMetodologia).insert(
        ConfiguracoesMetodologiaCompanion.insert(
            id: const Value(41),
            mesVigenciaInicial: '2026-06',
            percentualNecessidades: const Value(70),
            percentualDesejos: const Value(20),
            percentualPoupanca: const Value(10)));

    await db.into(db.fechamentosMensais).insert(
        FechamentosMensaisCompanion.insert(
            mesReferencia: '2026-06',
            rendaTotal: 5000,
            totalNecessidade: const Value(2500),
            totalDesejo: const Value(900),
            totalInvestimento: const Value(400)));
  }

  /// Retrato de todas as tabelas, para comparar antes x depois.
  Future<Map<String, List<dynamic>>> retrato() async => {
        'entradas': await db.select(db.entradas).get(),
        'contas': await db.select(db.contas).get(),
        'ocorrencias': await db.select(db.ocorrenciasConta).get(),
        'cartoes': await db.select(db.cartoes).get(),
        'faturas': await db.select(db.faturasCartao).get(),
        'rateios': await db.select(db.rateiosFatura).get(),
        'configuracoes': await db.select(db.configuracoesMetodologia).get(),
        'fechamentos': await db.select(db.fechamentosMensais).get(),
      };

  test('round-trip devolve as 8 tabelas idênticas, linha a linha', () async {
    await semear();
    final antes = await retrato();
    final json = await service.exportarJson();

    await service.apagarTudo();
    expect((await retrato()).values.expand((l) => l), isEmpty,
        reason: 'apagarTudo precisa zerar tudo antes do import (RF-20)');

    await service.importarJson(json);
    final depois = await retrato();

    for (final tabela in antes.keys) {
      expect(depois[tabela], antes[tabela], reason: 'tabela "$tabela" divergiu');
    }
  });

  test('as chaves estrangeiras continuam resolvendo depois do restore',
      () async {
    await semear();
    final json = await service.exportarJson();
    await service.importarJson(json);

    final ocorrencias = await db.select(db.ocorrenciasConta).get();
    final contaIds = (await db.select(db.contas).get()).map((c) => c.id).toSet();
    expect(ocorrencias.map((o) => o.contaId), everyElement(isIn(contaIds)));

    final rateios = await db.select(db.rateiosFatura).get();
    final faturaIds =
        (await db.select(db.faturasCartao).get()).map((f) => f.id).toSet();
    expect(rateios.map((r) => r.faturaCartaoId), everyElement(isIn(faturaIds)));

    // A fatura precisa continuar apontando para o cartão certo.
    final fatura = (await db.select(db.faturasCartao).get()).single;
    expect(fatura.cartaoId, 20);
  });

  test('criar linha nova depois do restore não colide de id', () async {
    await semear();
    final json = await service.exportarJson();
    await service.importarJson(json);

    // As tabelas são AUTOINCREMENT e o import gravou ids explícitos altos;
    // se `sqlite_sequence` não acompanhasse, o próximo id colidiria.
    final novoId = await db.into(db.contas).insert(ContasCompanion.insert(
        nome: 'Internet',
        grupo: Grupo.necessidade,
        valorPlanejado: 100,
        diaVencimento: 20,
        recorrencia: Recorrencia.fixa));
    expect(novoId, greaterThan(11));
    expect((await db.select(db.contas).get()).length, 3);
  });

  test('os enums viajam como ÍNDICE, não como nome', () async {
    await semear();
    final mapa = jsonDecode(await service.exportarJson()) as Map<String, dynamic>;

    // Se algum dia isto virar 'necessidade'/'parcelada', reordenar o enum
    // deixa de ser detectável e todo backup antigo é reinterpretado.
    final contas = (mapa['contas'] as List).cast<Map<String, dynamic>>();
    expect(contas.firstWhere((c) => c['id'] == 10)['grupo'], 0);
    expect(contas.firstWhere((c) => c['id'] == 11)['recorrencia'], 2);
  });

  test('payload com chave duplicada é deduplicado, mantendo a paga', () async {
    await semear();
    final mapa = jsonDecode(await service.exportarJson()) as Map<String, dynamic>;

    // Cópia PENDENTE da ocorrência 100 (que está paga), mesma conta e mês.
    // Sem deduplicar, isto bateria no índice único e derrubaria o restore
    // inteiro; deduplicando errado, o pagamento do usuário se perderia.
    final ocorrencias = (mapa['ocorrencias'] as List)
        .cast<Map<String, dynamic>>()
        .toList();
    final paga = ocorrencias.firstWhere((o) => o['id'] == 100);
    mapa['ocorrencias'] = [
      ...ocorrencias,
      {...paga, 'id': 999, 'status': 0, 'valorPago': null},
    ];

    await service.importarJson(jsonEncode(mapa));

    final restauradas = await db.select(db.ocorrenciasConta).get();
    final doMes = restauradas.where((o) => o.contaId == 10).toList();
    expect(doMes, hasLength(1), reason: 'uma linha por conta+mês');
    expect(doMes.single.id, 100, reason: 'sobrevive a paga, não a cópia');
    expect(doMes.single.valorPago, 1750.55);
  });

  test('backup de um app mais novo é recusado com mensagem própria', () async {
    await semear();
    final mapa = jsonDecode(await service.exportarJson()) as Map<String, dynamic>;
    final antes = await retrato();

    mapa['formatoBackup'] = BackupService.formatoBackupAtual + 1;
    await expectLater(service.importarJson(jsonEncode(mapa)),
        throwsA(isA<BackupInvalidoException>()));

    // Recusa ANTES de escrever: o dado local não pode ser tocado.
    for (final tabela in antes.keys) {
      expect((await retrato())[tabela], antes[tabela]);
    }
  });

  test('arquivo que não é backup é recusado sem apagar nada', () async {
    await semear();
    final antes = await retrato();

    await expectLater(service.importarJson('isto não é json'),
        throwsA(isA<BackupInvalidoException>()));
    await expectLater(service.importarJson('{"qualquer":"coisa"}'),
        throwsA(isA<BackupInvalidoException>()));

    for (final tabela in antes.keys) {
      expect((await retrato())[tabela], antes[tabela]);
    }
  });

  test('backup sem envelope (formato antigo) ainda é aceito', () async {
    await semear();
    final mapa = jsonDecode(await service.exportarJson()) as Map<String, dynamic>;
    final esperado = await retrato();
    mapa.remove('formatoBackup');
    mapa.remove('geradoEm');

    await service.importarJson(jsonEncode(mapa));

    for (final tabela in esperado.keys) {
      expect((await retrato())[tabela], esperado[tabela]);
    }
  });

  test('geradoEm devolve a data do backup e tolera arquivo sem ela', () async {
    await semear();
    final json = await service.exportarJson();
    final data = BackupService.geradoEm(json);
    expect(data, isNotNull);
    expect(DateTime.now().difference(data!).inMinutes, lessThan(5));

    expect(BackupService.geradoEm('{"contas":[]}'), isNull);
    expect(BackupService.geradoEm('lixo'), isNull);
  });
}
