import 'enums.dart';

/// Percentuais da metodologia vigentes a partir de um mês (RF-15/RN-06).
/// Padrão 50-30-20, mas configurável (a soma deve ser 100).
class ConfiguracaoMetodologia {
  const ConfiguracaoMetodologia({
    required this.mesVigenciaInicial,
    this.percentualNecessidades = 50,
    this.percentualDesejos = 30,
    this.percentualPoupanca = 20,
  });

  /// Mês (`YYYY-MM`) a partir do qual estes percentuais valem.
  final String mesVigenciaInicial;
  final double percentualNecessidades;
  final double percentualDesejos;
  final double percentualPoupanca;

  double get soma =>
      percentualNecessidades + percentualDesejos + percentualPoupanca;

  /// Percentual (0..100) do grupo informado.
  double percentualDe(Grupo grupo) => switch (grupo) {
        Grupo.necessidade => percentualNecessidades,
        Grupo.desejo => percentualDesejos,
        Grupo.investimento => percentualPoupanca,
      };
}

/// Recorte fechado de um mês, gerado na virada; alimenta o histórico (seção 8).
class FechamentoMensal {
  const FechamentoMensal({
    required this.mesReferencia,
    required this.rendaTotal,
    required this.totalPorGrupo,
    required this.snapshotPercentuais,
  });

  final String mesReferencia;
  final double rendaTotal;
  final Map<Grupo, double> totalPorGrupo;
  final ConfiguracaoMetodologia snapshotPercentuais;
}
