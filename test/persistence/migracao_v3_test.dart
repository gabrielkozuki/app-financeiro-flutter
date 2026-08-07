import 'dart:io';

import 'package:app_financeiro/data/db/app_database.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Migração v2 → v3 (índices únicos de conta/mês e cartão/mês).
///
/// É o código de maior risco do app: `CREATE UNIQUE INDEX` falha se o aparelho
/// já tiver duplicatas — justamente o defeito que a v3 vem impedir —, e uma
/// falha aqui deixa o usuário sem conseguir ABRIR o app. Os demais testes usam
/// `NativeDatabase.memory()`, que passa por `onCreate` e nunca exercita o
/// `onUpgrade`, então esta é a única cobertura do caminho de atualização.
///
/// O banco v2 é montado no `setup` do `NativeDatabase`, que roda antes de o
/// drift ler o `user_version` — assim ele encontra um banco legítimo na v2.
void main() {
  late Directory dir;
  late File arquivo;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('migracao_v3');
    arquivo = File('${dir.path}/app.sqlite');
  });
  tearDown(() async => dir.delete(recursive: true));

  /// Esquema da v2: igual ao atual, mas SEM as constraints de unicidade.
  void criarBancoV2(dynamic db) {
    db.execute('''
      CREATE TABLE contas (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL, grupo INTEGER NOT NULL,
        valor_planejado REAL NOT NULL, dia_vencimento INTEGER NOT NULL,
        recorrencia INTEGER NOT NULL, total_parcelas INTEGER,
        ativa INTEGER NOT NULL DEFAULT 1)''');
    db.execute('''
      CREATE TABLE ocorrencias_conta (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        conta_id INTEGER NOT NULL REFERENCES contas (id),
        mes_referencia TEXT NOT NULL, valor_planejado REAL NOT NULL,
        valor_pago REAL, data_pagamento INTEGER,
        status INTEGER NOT NULL DEFAULT 0, parcela_atual INTEGER,
        removida INTEGER NOT NULL DEFAULT 0)''');
    db.execute('''
      CREATE TABLE cartoes (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL, dia_vencimento INTEGER NOT NULL,
        ativa INTEGER NOT NULL DEFAULT 1)''');
    db.execute('''
      CREATE TABLE faturas_cartao (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        cartao_id INTEGER NOT NULL REFERENCES cartoes (id),
        mes_referencia TEXT NOT NULL, valor_total REAL, valor_pago REAL,
        data_pagamento INTEGER, status INTEGER NOT NULL DEFAULT 0)''');
    db.execute('''
      CREATE TABLE rateios_fatura (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        fatura_cartao_id INTEGER NOT NULL REFERENCES faturas_cartao (id),
        grupo INTEGER NOT NULL, valor REAL NOT NULL)''');
    db.execute('''
      CREATE TABLE entradas (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL, valor_liquido REAL NOT NULL, tipo INTEGER NOT NULL,
        dia_recebimento INTEGER, mes_referencia TEXT,
        ativa INTEGER NOT NULL DEFAULT 1)''');
    db.execute('''
      CREATE TABLE configuracoes_metodologia (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        mes_vigencia_inicial TEXT NOT NULL,
        percentual_necessidades REAL NOT NULL DEFAULT 50.0,
        percentual_desejos REAL NOT NULL DEFAULT 30.0,
        percentual_poupanca REAL NOT NULL DEFAULT 20.0)''');
    db.execute('''
      CREATE TABLE fechamentos_mensais (
        mes_referencia TEXT NOT NULL, renda_total REAL NOT NULL,
        total_necessidade REAL NOT NULL DEFAULT 0.0,
        total_desejo REAL NOT NULL DEFAULT 0.0,
        total_investimento REAL NOT NULL DEFAULT 0.0,
        snap_necessidades REAL NOT NULL DEFAULT 50.0,
        snap_desejos REAL NOT NULL DEFAULT 30.0,
        snap_poupanca REAL NOT NULL DEFAULT 20.0,
        PRIMARY KEY (mes_referencia))''');
    db.execute('PRAGMA user_version = 2');
  }

  /// Abre o arquivo com o AppDatabase atual, disparando o `onUpgrade` 2 → 3.
  AppDatabase abrirMigrando(void Function(dynamic) semear) =>
      AppDatabase(NativeDatabase(arquivo, setup: (db) {
        criarBancoV2(db);
        semear(db);
      }));

  Future<List<int>> ids(AppDatabase db, String tabela) async {
    final linhas = await db
        .customSelect('SELECT id FROM $tabela ORDER BY id')
        .get();
    return [for (final l in linhas) l.read<int>('id')];
  }

  test('mantém a ocorrência PAGA e descarta as duplicatas pendentes', () async {
    final db = abrirMigrando((raw) {
      raw.execute(
          "INSERT INTO contas (id, nome, grupo, valor_planejado, "
          "dia_vencimento, recorrencia) VALUES (1, 'Aluguel', 0, 900, 5, 0)");
      // Três linhas da MESMA chave (conta 1, 2026-06). A paga é a do meio, para
      // provar que o desempate é por status e não por ordem de inserção.
      for (final (id, status, pago) in [(1, 0, null), (2, 1, 900.0), (3, 0, null)]) {
        raw.execute(
            'INSERT INTO ocorrencias_conta (id, conta_id, mes_referencia, '
            "valor_planejado, valor_pago, status) VALUES "
            "($id, 1, '2026-06', 900, ${pago ?? 'NULL'}, $status)");
      }
    });
    addTearDown(db.close);

    expect(await ids(db, 'ocorrencias_conta'), [2],
        reason: 'o pagamento já registrado pelo usuário não pode se perder');
  });

  test('no empate de status, sobrevive a linha mais antiga (menor id)',
      () async {
    final db = abrirMigrando((raw) {
      raw.execute("INSERT INTO contas (id, nome, grupo, valor_planejado, "
          "dia_vencimento, recorrencia) VALUES (1, 'Internet', 0, 100, 10, 0)");
      // Duas pendentes na mesma chave + uma linha única de controle, que não
      // pode ser tocada pela deduplicação.
      raw.execute('INSERT INTO ocorrencias_conta (id, conta_id, '
          "mes_referencia, valor_planejado) VALUES (7, 1, '2026-06', 100)");
      raw.execute('INSERT INTO ocorrencias_conta (id, conta_id, '
          "mes_referencia, valor_planejado) VALUES (8, 1, '2026-06', 100)");
      raw.execute('INSERT INTO ocorrencias_conta (id, conta_id, '
          "mes_referencia, valor_planejado) VALUES (9, 1, '2026-07', 100)");
    });
    addTearDown(db.close);

    expect(await ids(db, 'ocorrencias_conta'), [7, 9],
        reason: 'sobra exatamente uma por chave — nem zero, nem todas');
  });

  test('fatura duplicada leva embora o rateio órfão junto', () async {
    final db = abrirMigrando((raw) {
      raw.execute("INSERT INTO cartoes (id, nome, dia_vencimento) "
          "VALUES (1, 'Nubank', 15)");
      raw.execute('INSERT INTO faturas_cartao (id, cartao_id, mes_referencia, '
          "valor_total, status) VALUES (1, 1, '2026-06', 1500, 0)");
      raw.execute('INSERT INTO faturas_cartao (id, cartao_id, mes_referencia, '
          "valor_total, valor_pago, status) VALUES (2, 1, '2026-06', 1500, "
          '1500, 1)');
      raw.execute('INSERT INTO rateios_fatura (id, fatura_cartao_id, grupo, '
          'valor) VALUES (10, 1, 0, 1500)');
      raw.execute('INSERT INTO rateios_fatura (id, fatura_cartao_id, grupo, '
          'valor) VALUES (11, 2, 0, 1500)');
    });
    addTearDown(db.close);

    expect(await ids(db, 'faturas_cartao'), [2], reason: 'a paga sobrevive');
    expect(await ids(db, 'rateios_fatura'), [11],
        reason: 'rateio sem fatura somaria no painel 50-30-20 sem dono');
  });

  test('depois de migrar, a chave duplicada é impossível e a virada é idempotente',
      () async {
    final db = abrirMigrando((raw) {
      raw.execute("INSERT INTO contas (id, nome, grupo, valor_planejado, "
          "dia_vencimento, recorrencia) VALUES (1, 'Luz', 0, 200, 8, 0)");
      raw.execute('INSERT INTO ocorrencias_conta (id, conta_id, '
          "mes_referencia, valor_planejado) VALUES (1, 1, '2026-06', 200)");
    });
    addTearDown(db.close);

    // O índice existe nos dois casos (banco migrado e banco novo).
    final indices = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'index' "
            "AND name LIKE 'ux_%'")
        .get();
    expect(
      {for (final i in indices) i.read<String>('name')},
      {'ux_ocorrencia_conta_mes', 'ux_fatura_cartao_mes'},
    );

    // Uma segunda virada do mesmo mês não duplica: o ON CONFLICT DO NOTHING dos
    // repositórios tem alvo válido, e uma inserção crua seria rejeitada.
    await expectLater(
      db.customInsert(
        'INSERT INTO ocorrencias_conta (conta_id, mes_referencia, '
        'valor_planejado) VALUES (?, ?, ?)',
        variables: [Variable(1), Variable('2026-06'), Variable(200.0)],
      ),
      throwsA(anything),
    );
    expect(await ids(db, 'ocorrencias_conta'), [1]);
  });
}
