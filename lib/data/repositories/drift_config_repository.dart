import 'package:drift/drift.dart';

import '../../domain/entities/configuracao.dart';
import '../../domain/repositories/repositories.dart';
import '../db/app_database.dart';
import '../db/mappers.dart';

class DriftConfigRepository implements ConfigRepository {
  DriftConfigRepository(this._db);

  final AppDatabase _db;

  @override
  Future<ConfiguracaoMetodologia> vigenteEm(String mesReferencia) async {
    // O snapshot mais recente cuja vigência começa em mês <= o informado.
    // A ordenação textual de `YYYY-MM` coincide com a cronológica.
    final row = await (_db.select(_db.configuracoesMetodologia)
          ..where((c) =>
              c.mesVigenciaInicial.isSmallerOrEqualValue(mesReferencia))
          ..orderBy([
            (c) => OrderingTerm(
                expression: c.mesVigenciaInicial, mode: OrderingMode.desc)
          ])
          ..limit(1))
        .getSingleOrNull();

    if (row == null) {
      return ConfiguracaoMetodologia(mesVigenciaInicial: mesReferencia);
    }
    return toConfig(row);
  }

  @override
  Future<void> salvar(ConfiguracaoMetodologia config) async {
    // Uma vigência por mês inicial: substitui se já existir (RN-06 preserva
    // vigências anteriores por serem meses distintos).
    await _db.transaction(() async {
      await (_db.delete(_db.configuracoesMetodologia)
            ..where((c) =>
                c.mesVigenciaInicial.equals(config.mesVigenciaInicial)))
          .go();
      await _db.into(_db.configuracoesMetodologia).insert(
            ConfiguracoesMetodologiaCompanion.insert(
              mesVigenciaInicial: config.mesVigenciaInicial,
              percentualNecessidades:
                  Value(config.percentualNecessidades),
              percentualDesejos: Value(config.percentualDesejos),
              percentualPoupanca: Value(config.percentualPoupanca),
            ),
          );
    });
  }
}
