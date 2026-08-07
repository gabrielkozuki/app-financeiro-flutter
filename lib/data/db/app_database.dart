import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/entities/enums.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// Banco de dados local do app (SQLite via drift) — fonte de verdade offline
/// (RNF-01). A sincronização em nuvem é um backup/restore por UID feito à parte,
/// construído sobre o `exportarJson`/`importarJson` de `data/export_service.dart`,
/// sem acoplar a persistência local.
@DriftDatabase(tables: [
  Entradas,
  Contas,
  OcorrenciasConta,
  Cartoes,
  FaturasCartao,
  RateiosFatura,
  ConfiguracoesMetodologia,
  FechamentosMensais,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'app_financeiro'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // v2: coluna `removida` para soft-delete de ocorrência (RF-07).
          if (from < 2) {
            await m.addColumn(ocorrenciasConta, ocorrenciasConta.removida);
          }
          // v3: unicidade de (conta, mês) e (cartão, mês). Bancos criados do
          // zero já nascem com a constraint UNIQUE declarada em `tables.dart`;
          // o SQLite não aceita acrescentar constraint a uma tabela existente,
          // então aqui o MESMO contrato é garantido por índice único — que é
          // também o alvo válido do `ON CONFLICT ... DO NOTHING` da virada.
          if (from < 3) {
            await _deduplicarParaIndicesUnicos(m);
            await m.database.customStatement(
              'CREATE UNIQUE INDEX IF NOT EXISTS ux_ocorrencia_conta_mes '
              'ON ocorrencias_conta (conta_id, mes_referencia)',
            );
            await m.database.customStatement(
              'CREATE UNIQUE INDEX IF NOT EXISTS ux_fatura_cartao_mes '
              'ON faturas_cartao (cartao_id, mes_referencia)',
            );
          }
        },
      );

  /// Passo obrigatório antes de criar os índices únicos da v3: o `CREATE UNIQUE
  /// INDEX` FALHA (e derruba a abertura do app) se o banco do aparelho já
  /// tiver duplicatas — que é justamente o defeito que a v3 vem impedir, já que
  /// a virada podia rodar duas vezes em paralelo e inserir a mesma ocorrência.
  ///
  /// Critério de desempate, aplicado por chave (conta+mês / cartão+mês):
  /// sobrevive a linha PAGA (`status` maior) e, no empate, a de MENOR id — a
  /// mais antiga. Assim nenhum pagamento já registrado pelo usuário se perde e
  /// o histórico fica com a linha original, não com a cópia acidental.
  Future<void> _deduplicarParaIndicesUnicos(Migrator m) async {
    // Ocorrências: apaga toda linha que tenha uma "melhor" irmã na mesma chave.
    await m.database.customStatement('''
      DELETE FROM ocorrencias_conta
      WHERE EXISTS (
        SELECT 1 FROM ocorrencias_conta AS outra
        WHERE outra.conta_id = ocorrencias_conta.conta_id
          AND outra.mes_referencia = ocorrencias_conta.mes_referencia
          AND (outra.status > ocorrencias_conta.status
            OR (outra.status = ocorrencias_conta.status
              AND outra.id < ocorrencias_conta.id))
      )
    ''');
    // Faturas: o rateio das faturas descartadas tem de sair ANTES delas, senão
    // ficam linhas órfãs em `rateios_fatura` (a FK não tem cascade) somando no
    // painel sem fatura correspondente.
    await m.database.customStatement('''
      DELETE FROM rateios_fatura
      WHERE fatura_cartao_id IN (
        SELECT f.id FROM faturas_cartao AS f
        WHERE EXISTS (
          SELECT 1 FROM faturas_cartao AS outra
          WHERE outra.cartao_id = f.cartao_id
            AND outra.mes_referencia = f.mes_referencia
            AND (outra.status > f.status
              OR (outra.status = f.status AND outra.id < f.id))
        )
      )
    ''');
    await m.database.customStatement('''
      DELETE FROM faturas_cartao
      WHERE EXISTS (
        SELECT 1 FROM faturas_cartao AS outra
        WHERE outra.cartao_id = faturas_cartao.cartao_id
          AND outra.mes_referencia = faturas_cartao.mes_referencia
          AND (outra.status > faturas_cartao.status
            OR (outra.status = faturas_cartao.status
              AND outra.id < faturas_cartao.id))
      )
    ''');
  }
}
