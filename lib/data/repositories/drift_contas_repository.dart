import 'package:drift/drift.dart';

import '../../domain/entities/conta.dart';
import '../../domain/entities/enums.dart';
import '../../domain/repositories/repositories.dart';
import '../db/app_database.dart';
import '../db/mappers.dart';

class DriftContasRepository implements ContasRepository {
  DriftContasRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<Conta>> listarAtivas() async {
    final rows = await (_db.select(_db.contas)
          ..where((c) => c.ativa.equals(true)))
        .get();
    return rows.map(toConta).toList();
  }

  @override
  Future<List<Conta>> listarTodas() async {
    final rows = await _db.select(_db.contas).get();
    return rows.map(toConta).toList();
  }

  @override
  Future<List<Conta>> listarFixasAtivas() async {
    final rows = await (_db.select(_db.contas)
          ..where((c) =>
              c.ativa.equals(true) &
              c.recorrencia.equalsValue(Recorrencia.fixa)))
        .get();
    return rows.map(toConta).toList();
  }

  @override
  Future<int> criar(Conta conta) {
    return _db.into(_db.contas).insert(ContasCompanion.insert(
          nome: conta.nome,
          grupo: conta.grupo,
          valorPlanejado: conta.valorPlanejado,
          diaVencimento: conta.diaVencimento,
          recorrencia: conta.recorrencia,
          totalParcelas: Value(conta.totalParcelas),
          ativa: Value(conta.ativa),
        ));
  }

  @override
  Future<void> atualizar(Conta conta) {
    return (_db.update(_db.contas)..where((c) => c.id.equals(conta.id)))
        .write(ContasCompanion(
      nome: Value(conta.nome),
      grupo: Value(conta.grupo),
      valorPlanejado: Value(conta.valorPlanejado),
      diaVencimento: Value(conta.diaVencimento),
      recorrencia: Value(conta.recorrencia),
      totalParcelas: Value(conta.totalParcelas),
      ativa: Value(conta.ativa),
    ));
  }

  @override
  Future<void> definirAtiva(int contaId, bool ativa) {
    return (_db.update(_db.contas)..where((c) => c.id.equals(contaId)))
        .write(ContasCompanion(ativa: Value(ativa)));
  }

  @override
  Future<void> excluir(int contaId) {
    // Remove as ocorrências filhas antes da conta (a FK não tem cascade).
    return _db.transaction(() async {
      await (_db.delete(_db.ocorrenciasConta)
            ..where((o) => o.contaId.equals(contaId)))
          .go();
      await (_db.delete(_db.contas)..where((c) => c.id.equals(contaId))).go();
    });
  }

  @override
  Future<List<OcorrenciaConta>> ocorrenciasDoMes(String mesReferencia) async {
    // Exclui as removidas "só deste mês" (RF-07) — elas continuam gravadas,
    // mas não aparecem na checklist.
    final rows = await (_db.select(_db.ocorrenciasConta)
          ..where((o) =>
              o.mesReferencia.equals(mesReferencia) & o.removida.equals(false)))
        .get();
    return rows.map(toOcorrencia).toList();
  }

  @override
  Future<Set<int>> contaIdsComOcorrenciaNoMes(String mesReferencia) async {
    final rows = await (_db.select(_db.ocorrenciasConta)
          ..where((o) => o.mesReferencia.equals(mesReferencia)))
        .get();
    return rows.map((o) => o.contaId).toSet();
  }

  @override
  Future<int> inserirOcorrencia({
    required int contaId,
    required String mesReferencia,
    required double valorPlanejado,
    int? parcelaAtual,
  }) {
    // Uma ocorrência por conta/mês é garantida pelo banco: se a virada (RF-16)
    // rodar duas vezes, a segunda inserção não faz nada em vez de duplicar a
    // linha na checklist (e dobrar o valor no painel).
    return _db.into(_db.ocorrenciasConta).insert(
          OcorrenciasContaCompanion.insert(
            contaId: contaId,
            mesReferencia: mesReferencia,
            valorPlanejado: valorPlanejado,
            parcelaAtual: Value(parcelaAtual),
          ),
          onConflict: DoNothing(target: [
            _db.ocorrenciasConta.contaId,
            _db.ocorrenciasConta.mesReferencia,
          ]),
        );
  }

  @override
  Future<void> marcarPaga(int ocorrenciaId, {double? valorPago}) {
    return (_db.update(_db.ocorrenciasConta)
          ..where((o) => o.id.equals(ocorrenciaId)))
        .write(OcorrenciasContaCompanion(
      status: const Value(StatusPagamento.paga),
      valorPago: Value(valorPago),
      dataPagamento: Value(DateTime.now()),
    ));
  }

  @override
  Future<void> desmarcar(int ocorrenciaId) {
    return (_db.update(_db.ocorrenciasConta)
          ..where((o) => o.id.equals(ocorrenciaId)))
        .write(const OcorrenciasContaCompanion(
      status: Value(StatusPagamento.pendente),
      valorPago: Value(null),
      dataPagamento: Value(null),
    ));
  }

  @override
  Future<void> excluirOcorrencia(int ocorrenciaId) {
    return (_db.delete(_db.ocorrenciasConta)
          ..where((o) => o.id.equals(ocorrenciaId)))
        .go();
  }

  @override
  Future<void> removerOcorrenciaDoMes(int ocorrenciaId) {
    return (_db.update(_db.ocorrenciasConta)
          ..where((o) => o.id.equals(ocorrenciaId)))
        .write(const OcorrenciasContaCompanion(removida: Value(true)));
  }

  @override
  Future<void> atualizarOcorrencia(
    int ocorrenciaId, {
    double? valorPlanejado,
    double? valorPago,
    bool limparValorPago = false,
  }) {
    return (_db.update(_db.ocorrenciasConta)
          ..where((o) => o.id.equals(ocorrenciaId)))
        .write(OcorrenciasContaCompanion(
      valorPlanejado: valorPlanejado == null
          ? const Value.absent()
          : Value(valorPlanejado),
      // `null` é "não informado" (não mexe); apagar o valor pago é pedido
      // explicitamente por [limparValorPago], para o mês voltar a calcular
      // pelo planejado (RN-04).
      valorPago: limparValorPago
          ? const Value(null)
          : (valorPago == null ? const Value.absent() : Value(valorPago)),
    ));
  }

  @override
  Future<void> excluirOcorrenciasDaContaAPartirDe(
      int contaId, String mesReferencia) {
    // A comparação textual de `YYYY-MM` coincide com a cronológica.
    return (_db.delete(_db.ocorrenciasConta)
          ..where((o) =>
              o.contaId.equals(contaId) &
              o.mesReferencia.isBiggerOrEqualValue(mesReferencia)))
        .go();
  }
}

