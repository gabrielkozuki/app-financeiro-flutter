import 'package:app_financeiro/domain/usecases/gerar_parcelas.dart';
import 'package:flutter_test/flutter_test.dart';

/// Geração de despesa parcelada (RF-06/RN-03): N ocorrências independentes.
void main() {
  const gerar = GerarParcelas();

  test('gera N parcelas independentes com contador', () {
    final parcelas = gerar(
        anoInicial: 2026, mesInicial: 7, valorParcela: 250, totalParcelas: 10);
    expect(parcelas.length, 10);
    expect(parcelas.first.parcelaAtual, 1);
    expect(parcelas.first.mesReferencia, '2026-07');
    expect(parcelas.last.parcelaAtual, 10);
    expect(parcelas.every((p) => p.valorPlanejado == 250), isTrue);
  });

  test('vira o ano ao ultrapassar dezembro', () {
    final parcelas = gerar(
        anoInicial: 2026, mesInicial: 11, valorParcela: 100, totalParcelas: 4);
    expect(parcelas.map((p) => p.mesReferencia).toList(),
        ['2026-11', '2026-12', '2027-01', '2027-02']);
  });

  test('uma única parcela é válida', () {
    final parcelas = gerar(
        anoInicial: 2026, mesInicial: 7, valorParcela: 99, totalParcelas: 1);
    expect(parcelas.single.mesReferencia, '2026-07');
  });
}
