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

  /// **Regime novo desde a publicação (25/08/2026).** Enquanto o app era só
  /// desenvolvimento, a versão era única e mudar tabela significava desinstalar
  /// o aparelho de teste. Agora existem bancos nas mãos de testadores: toda
  /// alteração de esquema sobe esta versão e escreve um `onUpgrade` data-safe.
  ///
  /// v2 — a pausa de renda virou vigência (`pausadaDesde`/`retomadaEm`) no
  /// lugar do booleano `ativa`.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, de, para) async {
          if (de < 2) {
            // `ativa` (booleano) sai; `pausadaDesde`/`retomadaEm` entram.
            // Nenhum build publicado chegou a gravar `ativa = false` — o
            // recurso de pausar nasceu junto com estas colunas —, então não há
            // valor antigo a converter: as novas nascem nulas, que é
            // exatamente "nunca pausada".
            await m.alterTable(TableMigration(entradas));
          }
        },
        // O SQLite ignora as chaves estrangeiras por padrão: as `references`
        // de `tables.dart` seriam só documentação. Ligar aqui (e não no
        // `driftDatabase`) faz valer também nos testes, que constroem o banco
        // em memória.
        //
        // Importa sobretudo no restore, que aceita um JSON arbitrário: sem
        // isto, uma ocorrência apontando para conta inexistente entrava calada,
        // sumia da checklist e ocupava a chave (conta, mês) para sempre. Agora
        // o insert falha e a transação inteira volta atrás, com erro visível.
        // Todas as exclusões do app já removem filhos antes do pai.
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
