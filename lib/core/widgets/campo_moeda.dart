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
    this.controller,
    required this.labelText,
    this.prefixIcon,
    this.autofocus = false,
    this.obrigatorioPositivo = false,
    this.onChanged,
    this.onSubmitted,
  });

  /// Opcional: sem controller, o próprio [TextFormField] cria e descarta o
  /// dele. É o que evita o "used after being disposed" quando o campo vive
  /// dentro de um diálogo — leia o valor pelo [onChanged], não por um
  /// controller externo.
  final TextEditingController? controller;
  final String labelText;
  final Widget? prefixIcon;
  final bool autofocus;

  /// Atalho para o validador mais comum: exige um valor maior que zero.
  final bool obrigatorioPositivo;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [MoedaInputFormatter()],
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon,
        prefixText: r'R$ ',
      ),
      validator: obrigatorioPositivo
          ? (texto) => parseMoeda(texto ?? '') <= 0 ? 'Valor inválido' : null
          : null,
    );
  }
}
