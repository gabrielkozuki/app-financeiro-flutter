import 'enums.dart';

/// O modelo/recorrência de uma conta (Módulo B). A instância de cada mês é a
/// [OcorrenciaConta]. A separação concretiza "separar tudo por mês" mantendo as
/// ocorrências agrupadas sob a conta de origem (seção 8).
class Conta {
  const Conta({
    required this.id,
    required this.nome,
    required this.grupo,
    required this.valorPlanejado,
    required this.diaVencimento,
    required this.recorrencia,
    this.totalParcelas,
    this.ativa = true,
  });

  final int id;
  final String nome;
  final Grupo grupo;
  final double valorPlanejado;
  final int diaVencimento;
  final Recorrencia recorrencia;

  /// Número total de parcelas (só para [Recorrencia.parcelada]).
  final int? totalParcelas;

  final bool ativa;

  Conta copyWith({
    String? nome,
    Grupo? grupo,
    double? valorPlanejado,
    int? diaVencimento,
    Recorrencia? recorrencia,
    int? totalParcelas,
    bool? ativa,
  }) {
    return Conta(
      id: id,
      nome: nome ?? this.nome,
      grupo: grupo ?? this.grupo,
      valorPlanejado: valorPlanejado ?? this.valorPlanejado,
      diaVencimento: diaVencimento ?? this.diaVencimento,
      recorrencia: recorrencia ?? this.recorrencia,
      totalParcelas: totalParcelas ?? this.totalParcelas,
      ativa: ativa ?? this.ativa,
    );
  }
}

/// A instância mensal de uma conta. Carrega o estado de pagamento e o valor
/// efetivamente pago, que substitui o planejado nos cálculos do mês (RN-04).
class OcorrenciaConta {
  const OcorrenciaConta({
    required this.id,
    required this.contaId,
    required this.mesReferencia,
    required this.valorPlanejado,
    this.valorPago,
    this.dataPagamento,
    this.status = StatusPagamento.pendente,
    this.parcelaAtual,
  });

  final int id;
  final int contaId;
  final String mesReferencia;
  final double valorPlanejado;
  final double? valorPago;
  final DateTime? dataPagamento;
  final StatusPagamento status;

  /// Número da parcela desta ocorrência (ex.: 3 em "3/10"); nulo se não parcelada.
  final int? parcelaAtual;

  /// Valor que efetivamente entra nos cálculos do mês: o pago, se houver,
  /// senão o planejado (RN-04).
  double get valorEfetivo => valorPago ?? valorPlanejado;

  bool get paga => status == StatusPagamento.paga;
}
