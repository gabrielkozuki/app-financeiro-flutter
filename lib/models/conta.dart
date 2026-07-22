import 'package:flutter/material.dart';

enum Grupo { necessidade, desejo, investimento, livre }

extension GrupoInfo on Grupo {
  String get rotulo => switch (this) {
        Grupo.necessidade => 'Necessidade',
        Grupo.desejo => 'Desejo',
        Grupo.investimento => 'Investimento',
        Grupo.livre => 'Livre',
      };

  Color get cor => switch (this) {
        Grupo.necessidade => const Color(0xFF0F766E),
        Grupo.desejo => const Color(0xFFD9A441),
        Grupo.investimento => const Color(0xFF6FA86F),
        Grupo.livre => const Color(0xFFB6BDBD),
      };

  IconData get icone => switch (this) {
        Grupo.necessidade => Icons.home_outlined,
        Grupo.desejo => Icons.local_mall_outlined,
        Grupo.investimento => Icons.savings_outlined,
        Grupo.livre => Icons.account_balance_wallet_outlined,
      };
}

class Conta {
  Conta({
    required this.nome,
    required this.valor,
    required this.grupo,
    required this.diaVencimento,
    this.paga = false,
  });

  final String nome;
  final double valor;
  final Grupo grupo;
  final int diaVencimento;
  bool paga;
}

final List<Conta> contasMock = [
  Conta(nome: 'Aluguel', valor: 1200, grupo: Grupo.necessidade, diaVencimento: 5, paga: true),
  Conta(nome: 'Internet', valor: 99, grupo: Grupo.necessidade, diaVencimento: 10, paga: true),
  Conta(nome: 'Energia', valor: 187, grupo: Grupo.necessidade, diaVencimento: 1, paga: true),
  Conta(nome: 'Mercado', valor: 74, grupo: Grupo.necessidade, diaVencimento: 15),
  Conta(nome: 'Viagem', valor: 300, grupo: Grupo.desejo, diaVencimento: 20),
  Conta(nome: 'Streaming', valor: 390, grupo: Grupo.desejo, diaVencimento: 12),
  Conta(nome: 'Reserva de emergência', valor: 300, grupo: Grupo.investimento, diaVencimento: 5),
  Conta(nome: 'Aporte CDB', valor: 150, grupo: Grupo.investimento, diaVencimento: 5),
];
