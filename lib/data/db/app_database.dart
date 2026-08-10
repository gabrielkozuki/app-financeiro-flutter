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

  /// Versão única enquanto o app está em desenvolvimento: o esquema muda e o
  /// aparelho de teste é reinstalado, então não há banco antigo a preservar e
  /// nenhuma migração a escrever. A unicidade de (conta, mês) e (cartão, mês)
  /// vem da constraint UNIQUE que o `uniqueKeys` de `tables.dart` emite no
  /// CREATE TABLE — e é ela o alvo do `ON CONFLICT ... DO NOTHING` da virada.
  ///
  /// **Ao publicar, isto muda de regime:** a partir da primeira versão na loja
  /// toda alteração de tabela exige subir esta versão e escrever um `onUpgrade`
  /// data-safe, porque aí existem bancos de usuários reais para preservar.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration =>
      MigrationStrategy(onCreate: (m) => m.createAll());
}
