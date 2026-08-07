import 'enums.dart';

/// Cartão de crédito (Módulo F). Modelado à parte por ter comportamento próprio:
/// fatura sempre variável e subdividida entre grupos.
class Cartao {
  const Cartao({
    required this.id,
    required this.nome,
    required this.diaVencimento,
    this.ativa = true,
  });

  final int id;
  final String nome;
  final int diaVencimento;
  final bool ativa;

  Cartao copyWith({String? nome, int? diaVencimento, bool? ativa}) {
    return Cartao(
      id: id,
      nome: nome ?? this.nome,
      diaVencimento: diaVencimento ?? this.diaVencimento,
      ativa: ativa ?? this.ativa,
    );
  }
}

/// Instância mensal da fatura de um cartão — análoga a uma [OcorrenciaConta],
/// mas em entidade própria (RF-22).
class FaturaCartao {
  const FaturaCartao({
    required this.id,
    required this.cartaoId,
    required this.mesReferencia,
    this.valorTotal,
    this.valorPago,
    this.dataPagamento,
    this.status = StatusPagamento.pendente,
  });

  final int id;
  final int cartaoId;
  final String mesReferencia;
  final double? valorTotal;
  final double? valorPago;
  final DateTime? dataPagamento;
  final StatusPagamento status;

  bool get paga => status == StatusPagamento.paga;

  /// Valor que efetivamente entra nos cálculos do mês: o pago, se houver; senão
  /// o total informado (RN-04). Invariante do contrato: fatura pendente nunca
  /// tem valor pago — desmarcar limpa o campo.
  double get valorEfetivo => valorPago ?? valorTotal ?? 0;
}

/// Subdivisão macro da fatura entre grupos (RF-23). As linhas de rateio de uma
/// fatura devem somar exatamente o valor total (RN-08).
class RateioFatura {
  const RateioFatura({
    required this.id,
    required this.faturaCartaoId,
    required this.grupo,
    required this.valor,
  });

  final int id;
  final int faturaCartaoId;
  final Grupo grupo;
  final double valor;
}
