import 'package:flutter/material.dart';

import '../../domain/entities/enums.dart';
import '../../l10n/app_localizations.dart';

/// Cor, ícone e rótulo de cada grupo da metodologia. É uma preocupação de UI,
/// por isso vive na camada de apresentação e não no domínio (que permanece
/// puro).
///
/// As cores de "desejo" e "investimento" foram escurecidas em relação à
/// paleta original (0xFFD9A441 e 0xFF6FA86F) para atingir contraste WCAG
/// AA (>=4,5:1) como texto sobre o fundo claro do app (0xFFF7F9F9) — a
/// paleta original dava ~2,13:1 e ~2,65:1, respectivamente. O matiz
/// (dourado/verde) foi preservado; só a luminosidade mudou. Razões de
/// contraste calculadas via luminância relativa (fórmula WCAG 2.1), sobre
/// 0xFFF7F9F9. "necessidade" já passava (~5,18:1) e não foi alterada.
extension GrupoVisual on Grupo {
  Color get cor => switch (this) {
        Grupo.necessidade => const Color(0xFF0F766E), // ~5,18:1
        Grupo.desejo => const Color(0xFF8C661C), // ~4,93:1 (era 2,13:1)
        Grupo.investimento => const Color(0xFF497949), // ~4,83:1 (era 2,65:1)
      };

  IconData get icone => switch (this) {
        Grupo.necessidade => Icons.home_outlined,
        Grupo.desejo => Icons.local_mall_outlined,
        Grupo.investimento => Icons.savings_outlined,
      };

  /// Nome do grupo na língua do usuário (Needs/Wants/Savings em inglês, os
  /// termos canônicos do 50-30-20).
  String rotulo(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      Grupo.necessidade => l10n.grupoNecessidade,
      Grupo.desejo => l10n.grupoDesejo,
      Grupo.investimento => l10n.grupoInvestimento,
    };
  }
}

/// Cor da fatia "Livre" (renda ainda não comprometida) na rosca 50-30-20.
/// "Livre" não é um grupo de classificação — é uma fatia calculada.
///
/// Cinza neutro deliberadamente mais claro que as três cores de grupo (3,95:1
/// contra 4,83–5,18:1), para "Livre" ficar em segundo plano na rosca sem cair
/// abaixo do piso de 3:1 do RNF-05/WCAG 1.4.11 — o 0xFFB6BDBD anterior dava
/// 1,81:1 na fatia e 1,66:1 no ícone do GroupAvatar (que aqui fica em 3,30:1).
const Color corLivre = Color(0xFF787D7D);
