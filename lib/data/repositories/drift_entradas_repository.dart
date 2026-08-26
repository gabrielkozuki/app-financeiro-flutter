import 'package:drift/drift.dart';

import '../../domain/entities/entrada.dart';
import '../../domain/entities/enums.dart';
import '../../domain/repositories/repositories.dart';
import '../db/app_database.dart';
import '../db/mappers.dart';

class DriftEntradasRepository implements EntradasRepository {
  DriftEntradasRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<Entrada>> doMes(String mesReferencia) async {
    final rows = await (_db.select(_db.entradas)
          ..where((e) =>
              e.tipo.equalsValue(TipoEntrada.recorrente) |
              (e.tipo.equalsValue(TipoEntrada.pontual) &
                  e.mesReferencia.equals(mesReferencia))))
        .get();
    // A pausa é filtrada em Dart, não em SQL: a regra tem vigência (ver
    // `Entrada.contaEm`) e exprimi-la em `where` deixaria a condição espalhada
    // entre o domínio e o banco. São poucas entradas por usuário — a diferença
    // de custo não existe, e a regra fica num lugar só, testável isolada.
    return rows.map(toEntrada).where((e) => e.contaEm(mesReferencia)).toList();
  }

  @override
  Future<double> rendaDoMes(String mesReferencia) async {
    final entradas = await doMes(mesReferencia);
    return entradas.fold<double>(0, (s, e) => s + e.valorLiquido);
  }

  @override
  Future<List<Entrada>> todas() async {
    final rows = await _db.select(_db.entradas).get();
    return rows.map(toEntrada).toList();
  }

  @override
  Future<int> criar(Entrada entrada) {
    return _db.into(_db.entradas).insert(EntradasCompanion.insert(
          nome: entrada.nome,
          valorLiquido: entrada.valorLiquido,
          tipo: entrada.tipo,
          diaRecebimento: Value(entrada.diaRecebimento),
          mesReferencia: Value(entrada.mesReferencia),
          pausadaDesde: Value(entrada.pausadaDesde),
          retomadaEm: Value(entrada.retomadaEm),
        ));
  }

  @override
  Future<void> atualizar(Entrada entrada) {
    return (_db.update(_db.entradas)..where((e) => e.id.equals(entrada.id)))
        .write(EntradasCompanion(
      nome: Value(entrada.nome),
      valorLiquido: Value(entrada.valorLiquido),
      tipo: Value(entrada.tipo),
      diaRecebimento: Value(entrada.diaRecebimento),
      mesReferencia: Value(entrada.mesReferencia),
      pausadaDesde: Value(entrada.pausadaDesde),
      retomadaEm: Value(entrada.retomadaEm),
    ));
  }

  @override
  Future<void> excluir(int id) {
    return (_db.delete(_db.entradas)..where((e) => e.id.equals(id))).go();
  }

  @override
  Future<int> contarTodas() async {
    final expr = _db.entradas.id.count();
    final query = _db.selectOnly(_db.entradas)..addColumns([expr]);
    final row = await query.getSingle();
    return row.read(expr) ?? 0;
  }
}
