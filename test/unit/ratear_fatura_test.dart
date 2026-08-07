import 'package:app_financeiro/domain/entities/cartao.dart';
import 'package:app_financeiro/domain/entities/enums.dart';
import 'package:app_financeiro/domain/usecases/ratear_fatura.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rateio da fatura entre grupos (RF-23): a soma deve bater o total (RN-08).
void main() {
  const ratear = RatearFatura();

  RateioFatura r(Grupo g, double v) =>
      RateioFatura(id: 0, faturaCartaoId: 1, grupo: g, valor: v);

  test('rateio que soma o total é válido', () {
    final v = ratear.validar(
      valorTotal: 2000,
      rateios: [r(Grupo.necessidade, 1400), r(Grupo.desejo, 600)],
    );
    expect(v.valido, isTrue);
    expect(v.faltaAlocar, closeTo(0, 0.001));
  });

  test('indica quanto falta alocar quando a soma não bate', () {
    final v =
        ratear.validar(valorTotal: 2000, rateios: [r(Grupo.necessidade, 1400)]);
    expect(v.valido, isFalse);
    expect(v.faltaAlocar, 600);
  });

  test('alocar além do total resulta em falta negativa', () {
    final v = ratear.validar(
      valorTotal: 2000,
      rateios: [r(Grupo.necessidade, 1500), r(Grupo.desejo, 700)],
    );
    expect(v.valido, isFalse);
    expect(v.faltaAlocar, -200);
  });

  test('sem rateio, o total inteiro entra em Necessidade (aproximação)', () {
    final mapa = ratear.comprometidoPorGrupo(valorTotal: 800, rateios: const []);
    expect(mapa[Grupo.necessidade], 800);
    expect(mapa[Grupo.desejo], isNull);
  });

  test('com rateio, distribui o comprometido por grupo', () {
    final mapa = ratear.comprometidoPorGrupo(
      valorTotal: 2000,
      rateios: [r(Grupo.necessidade, 1400), r(Grupo.desejo, 600)],
    );
    expect(mapa[Grupo.necessidade], 1400);
    expect(mapa[Grupo.desejo], 600);
  });
}
