import '../entities/cartao.dart';
import '../entities/enums.dart';

/// Resultado da validação do rateio de uma fatura (RF-23/RN-08).
class ValidacaoRateio {
  const ValidacaoRateio({required this.faltaAlocar});

  /// Quanto ainda falta alocar para bater o valor total.
  /// Zero = válido; positivo = falta alocar; negativo = alocou além do total.
  final double faltaAlocar;

  bool get valido => faltaAlocar.abs() < 0.01;
}

/// Valida a subdivisão macro da fatura entre grupos. A soma das linhas de
/// rateio deve bater exatamente o valor total da fatura (RN-08); enquanto não
/// bater, a conclusão é impedida de forma amigável mostrando o quanto falta.
class RatearFatura {
  const RatearFatura();

  ValidacaoRateio validar({
    required double valorTotal,
    required Iterable<RateioFatura> rateios,
  }) {
    final somaRateios = rateios.fold<double>(0, (s, r) => s + r.valor);
    return ValidacaoRateio(faltaAlocar: valorTotal - somaRateios);
  }

  /// Soma comprometida por grupo trazida por uma fatura, a partir do seu rateio.
  /// Se não houver rateio, o total inteiro cai em Necessidade (aproximação
  /// conservadora até o usuário subdividir).
  Map<Grupo, double> comprometidoPorGrupo({
    required double? valorTotal,
    required Iterable<RateioFatura> rateios,
  }) {
    final mapa = <Grupo, double>{};
    if (rateios.isEmpty) {
      if (valorTotal != null && valorTotal > 0) {
        mapa[Grupo.necessidade] = valorTotal;
      }
      return mapa;
    }
    for (final r in rateios) {
      mapa[r.grupo] = (mapa[r.grupo] ?? 0) + r.valor;
    }
    return mapa;
  }
}
