import 'package:app_financeiro/domain/entities/entrada.dart';
import 'package:app_financeiro/domain/entities/enums.dart';
import 'package:flutter_test/flutter_test.dart';

/// A pausa de uma renda tem **vigência**: vale do mês escolhido em diante,
/// nunca para trás. Pausar hoje não pode alterar o que já aconteceu — e retomar
/// não pode ressuscitar os meses que ficaram pausados no meio.
///
/// A regra é pura (`Entrada.contaEm`) justamente para poder ser testada assim,
/// sem banco: é a mesma decisão que fez a comparação ser textual, já que
/// `YYYY-MM` com zero à esquerda ordena cronologicamente.
void main() {
  Entrada renda({String? pausadaDesde, String? retomadaEm}) => Entrada(
        id: 1,
        nome: 'Salário',
        valorLiquido: 5000,
        tipo: TipoEntrada.recorrente,
        diaRecebimento: 5,
        pausadaDesde: pausadaDesde,
        retomadaEm: retomadaEm,
      );

  group('nunca pausada', () {
    test('conta em qualquer mês', () {
      final e = renda();
      for (final mes in ['2020-01', '2026-08', '2030-12']) {
        expect(e.contaEm(mes), isTrue, reason: mes);
      }
    });
  });

  group('pausada sem retomada', () {
    final e = renda(pausadaDesde: '2026-08');

    test('meses ANTERIORES continuam contando', () {
      // O ponto central: pausar em agosto não pode reescrever julho.
      expect(e.contaEm('2026-07'), isTrue);
      expect(e.contaEm('2025-12'), isTrue);
    });

    test('o mês da pausa já não conta', () {
      expect(e.contaEm('2026-08'), isFalse);
    });

    test('os meses seguintes não contam', () {
      expect(e.contaEm('2026-09'), isFalse);
      expect(e.contaEm('2027-03'), isFalse);
    });
  });

  group('pausada e retomada', () {
    // Pausou em agosto, retomou em outubro.
    final e = renda(pausadaDesde: '2026-08', retomadaEm: '2026-10');

    test('antes da pausa conta', () => expect(e.contaEm('2026-07'), isTrue));

    test('o intervalo pausado NÃO volta a contar ao retomar', () {
      // É o que distingue vigência de um booleano: retomar em outubro não
      // pode fazer agosto e setembro contarem de novo.
      expect(e.contaEm('2026-08'), isFalse);
      expect(e.contaEm('2026-09'), isFalse);
    });

    test('o mês da retomada volta a contar', () {
      expect(e.contaEm('2026-10'), isTrue);
    });

    test('os meses seguintes contam', () {
      expect(e.contaEm('2026-11'), isTrue);
      expect(e.contaEm('2027-06'), isTrue);
    });
  });

  group('virada de ano', () {
    // A comparação textual só é cronológica porque o mês tem zero à esquerda.
    final e = renda(pausadaDesde: '2026-11', retomadaEm: '2027-02');

    test('dezembro do ano da pausa não conta', () {
      expect(e.contaEm('2026-12'), isFalse);
    });

    test('janeiro do ano seguinte ainda não conta', () {
      expect(e.contaEm('2027-01'), isFalse);
    });

    test('fevereiro volta a contar', () {
      expect(e.contaEm('2027-02'), isTrue);
    });

    test('outubro do ano anterior conta', () {
      expect(e.contaEm('2026-10'), isTrue);
    });
  });

  group('pausadaEm é o inverso de contaEm', () {
    test('para a tela decidir entre Pausar e Retomar', () {
      final e = renda(pausadaDesde: '2026-08', retomadaEm: '2026-10');
      for (final mes in ['2026-07', '2026-08', '2026-09', '2026-10']) {
        expect(e.pausadaEm(mes), !e.contaEm(mes), reason: mes);
      }
    });
  });
}
