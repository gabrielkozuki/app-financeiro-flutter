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
    this.pausadaDesde,
    this.retomadaEm,
  });

  final int id;
  final String nome;
  final double valorLiquido;
  final TipoEntrada tipo;

  /// Dia do mês em que a entrada recorrente é recebida (só para recorrentes).
  final int? diaRecebimento;

  /// Mês (`YYYY-MM`) ao qual a entrada pontual pertence (só para pontuais).
  final String? mesReferencia;

  /// Mês (`YYYY-MM`) a partir do qual a entrada deixou de contar. Nulo quando
  /// nunca foi pausada.
  final String? pausadaDesde;

  /// Mês em que voltou a contar. Nulo quando segue pausada.
  final String? retomadaEm;

  /// Esta entrada compõe a renda de [mes]?
  ///
  /// A comparação é textual porque `YYYY-MM` com zero à esquerda é
  /// cronologicamente ordenável — mesma propriedade que `ehMesPassado` usa.
  ///
  /// A pausa vale **do mês escolhido em diante**, nunca para trás: pausar hoje
  /// não pode alterar o que já aconteceu. E retomar vale do mês escolhido em
  /// diante, deixando o intervalo pausado como estava.
  bool contaEm(String mes) {
    final desde = pausadaDesde;
    if (desde == null) return true;
    if (mes.compareTo(desde) < 0) return true;
    final volta = retomadaEm;
    return volta != null && mes.compareTo(volta) >= 0;
  }

  /// Estado no mês exibido, para a tela decidir entre "Pausar" e "Retomar".
  bool pausadaEm(String mes) => !contaEm(mes);
}
