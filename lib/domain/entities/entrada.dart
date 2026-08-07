import 'enums.dart';

/// Entrada de renda — unifica salário, 13º, freelances etc. (modelo de
/// entradas/saídas do Módulo A). Sempre em valor líquido (RN-02).
class Entrada {
  const Entrada({
    required this.id,
    required this.nome,
    required this.valorLiquido,
    required this.tipo,
    this.diaRecebimento,
    this.mesReferencia,
    this.ativa = true,
  });

  final int id;
  final String nome;
  final double valorLiquido;
  final TipoEntrada tipo;

  /// Dia do mês em que a entrada recorrente é recebida (só para recorrentes).
  final int? diaRecebimento;

  /// Mês (`YYYY-MM`) ao qual a entrada pontual pertence (só para pontuais).
  final String? mesReferencia;

  final bool ativa;
}
