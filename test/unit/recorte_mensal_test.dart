import 'package:app_financeiro/core/format/dates.dart';
import 'package:flutter_test/flutter_test.dart';

/// A fronteira "mês passado" — o invariante mais caro do app.
///
/// É ela que decide se a virada gera ocorrências naquele mês (RN-05) e se a UI
/// entra em somente leitura (RF-18). Um erro aqui não dá exceção: escreve
/// silenciosamente em histórico, e o `FechamentoMensal` congela o resultado.
void main() {
  group('ehMesPassado', () {
    const hoje = '2026-08';

    test('mês anterior é passado', () {
      expect(ehMesPassado('2026-07', referencia: hoje), isTrue);
    });

    test('o mês corrente NÃO é passado — é ele que gera a virada', () {
      expect(ehMesPassado(hoje, referencia: hoje), isFalse);
    });

    test('mês futuro NÃO é passado', () {
      expect(ehMesPassado('2026-09', referencia: hoje), isFalse);
    });

    test('a virada de ano é respeitada', () {
      expect(ehMesPassado('2025-12', referencia: '2026-01'), isTrue);
      expect(ehMesPassado('2026-01', referencia: '2025-12'), isFalse);
    });

    test('o zero-padding é o que faz a comparação textual ser cronológica', () {
      // Sem o zero à esquerda, '2026-9' > '2026-10' em ordem textual e
      // setembro seria tratado como futuro em outubro.
      expect(ehMesPassado('2026-09', referencia: '2026-10'), isTrue);
      expect(ehMesPassado('2026-02', referencia: '2026-10'), isTrue);
      expect(ehMesPassado('2026-10', referencia: '2026-02'), isFalse);
    });

    test('mês muito antigo continua passado', () {
      expect(ehMesPassado('2019-01', referencia: hoje), isTrue);
    });
  });

  group('mesReferencia e mesCorrente', () {
    test('a chave é sempre YYYY-MM zero-padded', () {
      expect(mesReferencia(DateTime(2026, 1)), '2026-01');
      expect(mesReferencia(DateTime(2026, 12)), '2026-12');
      expect(mesReferencia(DateTime(999, 3)), '0999-03');
    });

    test('o dia do mês não entra na chave do recorte', () {
      expect(mesReferencia(DateTime(2026, 8, 1)),
          mesReferencia(DateTime(2026, 8, 31)));
    });

    test('mesCorrente é o recorte de hoje e nunca é passado', () {
      expect(mesCorrente(), mesReferencia(DateTime.now()));
      expect(ehMesPassado(mesCorrente()), isFalse);
    });
  });
}
