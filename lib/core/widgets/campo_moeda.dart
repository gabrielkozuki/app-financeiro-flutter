import 'package:flutter/material.dart';

import '../format/money.dart';

/// Campo monetário único do app: um [TextFormField] já pré-configurado com o
/// [MoedaInputFormatter] (digitação em centavos, sem ambiguidade de
/// separador), teclado numérico e `prefixText: 'R$ '`. Centraliza aqui toda a
/// entrada de dinheiro para não duplicar formatter/parse/validador entre as
/// telas (onboarding, rendas, contas, fatura).
///
/// Precisão: use [parseMoeda] sobre `controller.text` ao salvar e [moedaEdit]
/// para pré-preencher em edição — o par garante round-trip exato (ex.: 3000,50
/// → 3000.50), sem arredondar para reais nem descartar os centavos.
class CampoMoeda extends StatelessWidget {
  const CampoMoeda({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.autofocus = false,
    this.obrigatorioPositivo = false,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final bool autofocus;

  /// Atalho para o validador mais comum: exige um valor maior que zero. Ignorado
  /// quando um [validator] explícito é informado.
  final bool obrigatorioPositivo;

  /// Validador customizado; recebe o valor já convertido para double (0 quando
  /// o campo está vazio).
  final String? Function(double valor)? validator;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [MoedaInputFormatter()],
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        prefixText: r'R$ ',
      ),
      validator: _resolverValidator(),
    );
  }

  String? Function(String?)? _resolverValidator() {
    if (validator != null) {
      return (texto) => validator!(parseMoeda(texto ?? ''));
    }
    if (obrigatorioPositivo) {
      return (texto) =>
          parseMoeda(texto ?? '') <= 0 ? 'Valor inválido' : null;
    }
    return null;
  }
}
