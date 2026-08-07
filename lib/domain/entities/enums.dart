/// Grupos da metodologia 50-30-20 nos quais cada conta é classificada
/// diretamente (RN-07). Não há camada intermediária de categorias.
///
/// Observação: "Livre" (o quanto da renda ainda não foi comprometido) NÃO é um
/// grupo de classificação — é uma fatia calculada, exibida apenas na rosca.
enum Grupo {
  necessidade,
  desejo,
  investimento;

  String get rotulo => switch (this) {
        Grupo.necessidade => 'Necessidade',
        Grupo.desejo => 'Desejo',
        Grupo.investimento => 'Investimento',
      };
}

/// Recorrência de uma conta (RF-04/RF-06).
enum Recorrencia { fixa, pontual, parcelada }

/// Tipo de entrada de renda (RF-01/RF-02).
enum TipoEntrada { recorrente, pontual }

/// Estado de uma ocorrência ou fatura no mês — apenas dois valores (RF-08).
/// Em um mês fechado, "pendente" significa "não foi paga naquele mês" (RN-05).
enum StatusPagamento { pendente, paga }
