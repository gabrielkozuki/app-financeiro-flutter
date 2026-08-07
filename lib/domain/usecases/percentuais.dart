import '../entities/configuracao.dart';

/// Valida os percentuais da metodologia: a soma deve ser exatamente 100 (RF-15).
/// A alteração vale para o mês corrente e os futuros; o histórico preserva os
/// percentuais vigentes em cada mês (RN-06) — garantido guardando um snapshot
/// por vigência, não sobrescrevendo os anteriores.
class ValidarPercentuais {
  const ValidarPercentuais();

  bool call(ConfiguracaoMetodologia config) => (config.soma - 100).abs() < 0.01;
}
