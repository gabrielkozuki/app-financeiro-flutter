import '../entities/configuracao.dart';
import '../entities/enums.dart';

/// Situação de um grupo em relação à referência da metodologia. É apenas
/// informativa (RF-13) — nunca representa erro, bloqueio ou culpa.
enum Situacao { abaixo, dentro, acima }

/// Resultado por grupo para o painel/rosca 50-30-20.
class ItemGrupo {
  const ItemGrupo({
    required this.grupo,
    required this.comprometido,
    required this.limite,
    required this.percentualRealizado,
    required this.metaPercentual,
  });

  final Grupo grupo;

  /// Soma comprometida no grupo (contas + rateio de faturas), já usando o valor
  /// efetivamente pago quando houver (RN-04).
  final double comprometido;

  /// Referência do grupo: percentual × renda.
  final double limite;

  /// Percentual da renda realizado neste grupo (0..100+).
  final double percentualRealizado;

  /// Percentual-alvo do grupo na metodologia vigente (0..100).
  final double metaPercentual;

  Situacao get situacao {
    const epsilon = 0.5; // meio ponto percentual de tolerância
    final delta = percentualRealizado - metaPercentual;
    if (delta > epsilon) return Situacao.acima;
    if (delta < -epsilon) return Situacao.abaixo;
    return Situacao.dentro;
  }
}

/// Panorama completo do mês para o painel 50-30-20.
class ResultadoMetodologia {
  const ResultadoMetodologia({
    required this.renda,
    required this.totalComprometido,
    required this.itens,
    required this.livreParaGastar,
    required this.percentualLivre,
  });

  final double renda;
  final double totalComprometido;
  final List<ItemGrupo> itens;

  /// Renda − total comprometido no mês (RF-14). Pode ser negativo.
  final double livreParaGastar;

  /// Fatia "Livre" da rosca, em % da renda (nunca negativa).
  final double percentualLivre;

  ItemGrupo item(Grupo grupo) => itens.firstWhere((i) => i.grupo == grupo);
}

/// Calcula o painel 50-30-20 a partir da renda do mês, do total comprometido
/// por grupo e dos percentuais vigentes (RF-12..14). Função pura e testável.
class CalcularMetodologia {
  const CalcularMetodologia();

  ResultadoMetodologia call({
    required double renda,
    required Map<Grupo, double> comprometidoPorGrupo,
    required ConfiguracaoMetodologia config,
  }) {
    final itens = Grupo.values.map((grupo) {
      final comprometido = comprometidoPorGrupo[grupo] ?? 0;
      final meta = config.percentualDe(grupo);
      return ItemGrupo(
        grupo: grupo,
        comprometido: comprometido,
        limite: renda * meta / 100,
        percentualRealizado: renda > 0 ? comprometido / renda * 100 : 0,
        metaPercentual: meta,
      );
    }).toList();

    final total = itens.fold<double>(0, (s, i) => s + i.comprometido);
    final livre = renda - total;
    final percentualLivre =
        renda > 0 ? (livre > 0 ? livre / renda * 100 : 0.0) : 0.0;

    return ResultadoMetodologia(
      renda: renda,
      totalComprometido: total,
      itens: itens,
      livreParaGastar: livre,
      percentualLivre: percentualLivre,
    );
  }
}
