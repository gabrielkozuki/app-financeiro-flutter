import 'package:drift/drift.dart';

import '../../domain/entities/configuracao.dart';
import '../../domain/entities/enums.dart';
import '../../domain/repositories/repositories.dart';
import '../db/app_database.dart';
import '../db/mappers.dart';

class DriftFechamentoRepository implements FechamentoRepository {
  DriftFechamentoRepository(this._db);

  final AppDatabase _db;

  @override
  Future<FechamentoMensal?> doMes(String mesReferencia) async {
    final row = await (_db.select(_db.fechamentosMensais)
          ..where((f) => f.mesReferencia.equals(mesReferencia)))
        .getSingleOrNull();
    return row == null ? null : toFechamento(row);
  }

  @override
  Future<void> salvar(FechamentoMensal f) {
    final snap = f.snapshotPercentuais;
    return _db.into(_db.fechamentosMensais).insertOnConflictUpdate(
          FechamentosMensaisCompanion.insert(
            mesReferencia: f.mesReferencia,
            rendaTotal: f.rendaTotal,
            totalNecessidade:
                Value(f.totalPorGrupo[Grupo.necessidade] ?? 0),
            totalDesejo: Value(f.totalPorGrupo[Grupo.desejo] ?? 0),
            totalInvestimento:
                Value(f.totalPorGrupo[Grupo.investimento] ?? 0),
            snapNecessidades: Value(snap.percentualNecessidades),
            snapDesejos: Value(snap.percentualDesejos),
            snapPoupanca: Value(snap.percentualPoupanca),
          ),
        );
  }

  @override
  Future<void> excluir(String mesReferencia) {
    return (_db.delete(_db.fechamentosMensais)
          ..where((f) => f.mesReferencia.equals(mesReferencia)))
        .go();
  }

  @override
  Future<List<String>> mesesComDados() async {
    final ocorr = await (_db.selectOnly(_db.ocorrenciasConta, distinct: true)
          ..addColumns([_db.ocorrenciasConta.mesReferencia]))
        .get();
    final faturas = await (_db.selectOnly(_db.faturasCartao, distinct: true)
          ..addColumns([_db.faturasCartao.mesReferencia]))
        .get();
    final meses = <String>{
      ...ocorr.map((r) => r.read(_db.ocorrenciasConta.mesReferencia)!),
      ...faturas.map((r) => r.read(_db.faturasCartao.mesReferencia)!),
    };
    return meses.toList();
  }
}
