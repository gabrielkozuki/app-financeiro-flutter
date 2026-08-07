import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final NumberFormat _moeda =
    NumberFormat.currency(locale: 'pt_BR', symbol: r'R$', decimalDigits: 2);
final NumberFormat _numero = NumberFormat('#,##0.00', 'pt_BR');

/// Formata em Reais com 2 casas decimais (ex.: `R$ 3.000,50`). Precisão é
/// essencial neste app — sempre exibimos os centavos, nunca arredondamos para
/// reais inteiros.
String brl(num valor) => _moeda.format(valor);

/// Texto (sem símbolo) para pré-preencher um campo monetário em edição, no
/// mesmo formato que o [MoedaInputFormatter] mantém (ex.: `3.000,50`).
String moedaEdit(num valor) => _numero.format(valor);

/// Converte o texto de um campo monetário para double. Como o campo é formatado
/// em centavos pelo [MoedaInputFormatter], basta considerar os dígitos: os dois
/// últimos são os centavos. Assim não há ambiguidade entre `.` e `,`.
double parseMoeda(String texto) {
  final digitos = texto.replaceAll(RegExp(r'[^0-9]'), '');
  if (digitos.isEmpty) return 0;
  return int.parse(digitos) / 100;
}

/// Formata um campo de dinheiro como moeda enquanto o usuário digita: cada
/// dígito entra pela direita (centavos), como nos apps de banco. Digitar
/// `3 0 0 0 5 0` mostra `3.000,50`; teclas de `.`/`,` são ignoradas. Elimina
/// qualquer ambiguidade de separador decimal/milhar.
class MoedaInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digitos = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitos.isEmpty) return const TextEditingValue();
    // Limita para evitar estouro de int em entradas absurdas.
    final limitado =
        digitos.length > 15 ? digitos.substring(0, 15) : digitos;
    final texto = _numero.format(int.parse(limitado) / 100);
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}
