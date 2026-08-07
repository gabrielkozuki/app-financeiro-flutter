import 'package:drift/drift.dart';

import '../../domain/entities/cartao.dart';
import '../../domain/entities/enums.dart';
import '../../domain/repositories/repositories.dart';
import '../db/app_database.dart';
import '../db/mappers.dart';

class DriftCartoesRepository implements CartoesRepository {
  DriftCartoesRepository(this._db);

  final AppDatabase _db;

  @override
  Future<List<Cartao>> listarAtivos() async {
    final rows = await (_db.select(_db.cartoes)
          ..where((c) => c.ativa.equals(true)))
        .get();
    return rows.map(toCartao).toList();
  }

  @override
  Future<int> criar(Cartao cartao) {
    return _db.into(_db.cartoes).insert(CartoesCompanion.insert(
          nome: cartao.nome,
          diaVencimento: cartao.diaVencimento,
          ativa: Value(cartao.ativa),
        ));
  }

  @override
  Future<void> atualizar(Cartao cartao) {
    return (_db.update(_db.cartoes)..where((c) => c.id.equals(cartao.id)))
        .write(CartoesCompanion(
      nome: Value(cartao.nome),
      diaVencimento: Value(cartao.diaVencimento),
      ativa: Value(cartao.ativa),
    ));
  }

  @override
  Future<void> excluir(int cartaoId) {
    // Remove rateios e faturas filhas antes do cartão (FK sem cascade).
    return _db.transaction(() async {
      final faturas = await (_db.select(_db.faturasCartao)
            ..where((f) => f.cartaoId.equals(cartaoId)))
          .get();
      for (final f in faturas) {
        await (_db.delete(_db.rateiosFatura)
              ..where((r) => r.faturaCartaoId.equals(f.id)))
            .go();
      }
      await (_db.delete(_db.faturasCartao)
            ..where((f) => f.cartaoId.equals(cartaoId)))
          .go();
      await (_db.delete(_db.cartoes)..where((c) => c.id.equals(cartaoId))).go();
    });
  }

  @override
  Future<List<FaturaCartao>> faturasDoMes(String mesReferencia) async {
    final rows = await (_db.select(_db.faturasCartao)
          ..where((f) => f.mesReferencia.equals(mesReferencia)))
        .get();
    return rows.map(toFatura).toList();
  }

  @override
  Future<Set<int>> cartaoIdsComFaturaNoMes(String mesReferencia) async {
    final rows = await (_db.select(_db.faturasCartao)
          ..where((f) => f.mesReferencia.equals(mesReferencia)))
        .get();
    return rows.map((f) => f.cartaoId).toSet();
  }

  @override
  Future<int> criarFatura(
      {required int cartaoId, required String mesReferencia}) {
    // Uma fatura por cartão/mês é garantida pelo banco: a virada (RF-16) pode
    // rodar de novo sem criar uma segunda fatura vazia para o mesmo mês.
    return _db.into(_db.faturasCartao).insert(
          FaturasCartaoCompanion.insert(
            cartaoId: cartaoId,
            mesReferencia: mesReferencia,
          ),
          onConflict: DoNothing(target: [
            _db.faturasCartao.cartaoId,
            _db.faturasCartao.mesReferencia,
          ]),
        );
  }

  @override
  Future<void> definirValorFatura(int faturaId, double valorTotal) {
    return (_db.update(_db.faturasCartao)..where((f) => f.id.equals(faturaId)))
        .write(FaturasCartaoCompanion(valorTotal: Value(valorTotal)));
  }

  @override
  Future<void> marcarFaturaPaga(int faturaId, {double? valorPago}) {
    return (_db.update(_db.faturasCartao)..where((f) => f.id.equals(faturaId)))
        .write(FaturasCartaoCompanion(
      status: const Value(StatusPagamento.paga),
      valorPago: Value(valorPago),
      dataPagamento: Value(DateTime.now()),
    ));
  }

  @override
  Future<void> desmarcarFatura(int faturaId) {
    return (_db.update(_db.faturasCartao)..where((f) => f.id.equals(faturaId)))
        .write(const FaturasCartaoCompanion(
      status: Value(StatusPagamento.pendente),
      // Limpa também o valor pago (espelhando DriftContasRepository.desmarcar):
      // fatura pendente que guardasse o pago antigo exibiria um valor que não
      // vale mais para o mês.
      valorPago: Value(null),
      dataPagamento: Value(null),
    ));
  }

  @override
  Future<List<RateioFatura>> rateiosDaFatura(int faturaId) async {
    final rows = await (_db.select(_db.rateiosFatura)
          ..where((r) => r.faturaCartaoId.equals(faturaId)))
        .get();
    return rows.map(toRateio).toList();
  }

  @override
  Future<void> salvarRateio(int faturaId, Map<Grupo, double> valores) {
    return _db.transaction(() async {
      await (_db.delete(_db.rateiosFatura)
            ..where((r) => r.faturaCartaoId.equals(faturaId)))
          .go();
      for (final entry in valores.entries) {
        if (entry.value <= 0) continue;
        await _db.into(_db.rateiosFatura).insert(RateiosFaturaCompanion.insert(
              faturaCartaoId: faturaId,
              grupo: entry.key,
              valor: entry.value,
            ));
      }
    });
  }
}
