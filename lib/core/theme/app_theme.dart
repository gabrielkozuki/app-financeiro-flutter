import 'package:flutter/material.dart';

/// Tema e tokens visuais do app, extraídos da vitrine inicial (`main.dart`).
///
/// Concentra as cores-semente, a escala de espaçamento e os temas de
/// componente usados nas telas para manter a identidade visual coesa em um
/// único lugar. Tom do produto: educativo e neutro — nunca punitivo.
class AppTheme {
  const AppTheme._();

  /// Cor-semente (verde-petróleo) do protótipo.
  static const Color seed = Color(0xFF0F766E);

  /// Fundo geral das telas no tema claro.
  static const Color fundoScaffold = Color(0xFFF7F9F9);

  /// Raio de canto padrão dos cards e campos.
  static const double raio = 16;

  /// Raio de canto maior, usado em folhas (bottom sheets) e diálogos.
  static const double raioGrande = 24;

  /// Largura máxima do conteúdo (mantém a leitura confortável em telas largas).
  static const double maxLargura = 480;

  // Escala de espaçamento — mantém o ritmo vertical/horizontal consistente
  // entre telas. Use estes tokens em vez de valores soltos quando possível.
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double spaceLg = 16;
  static const double spaceXl = 24;
  static const double spaceXxl = 32;

  /// Alvo mínimo de toque recomendado (RNF-05).
  static const double alvoToqueMinimo = 44;

  static ThemeData get light => _build(
        ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
      );

  static ThemeData get dark => _build(
        ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
      );

  static ThemeData _build(ColorScheme scheme) {
    final baseText = ThemeData(colorScheme: scheme, useMaterial3: true)
        .textTheme;
    final textTheme = baseText.copyWith(
      headlineMedium: baseText.headlineMedium
          ?.copyWith(fontWeight: FontWeight.w700, height: 1.15),
      headlineSmall: baseText.headlineSmall
          ?.copyWith(fontWeight: FontWeight.w700, height: 1.15),
      titleLarge: baseText.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: baseText.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: baseText.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: baseText.labelMedium?.copyWith(letterSpacing: 0.6),
      bodyMedium: baseText.bodyMedium?.copyWith(height: 1.35),
    );

    final inputRadius = BorderRadius.circular(raio - 2);
    final isDark = scheme.brightness == Brightness.dark;
    final scaffoldBg = isDark ? scheme.surface : fundoScaffold;

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      brightness: scheme.brightness,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(raio),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        color: scheme.surface,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
      ),
      iconTheme: IconThemeData(color: scheme.onSurfaceVariant),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(raio),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: spaceLg, vertical: spaceXs),
        minVerticalPadding: spaceSm,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: BorderSide(color: scheme.outline, width: 1.5),
        visualDensity: VisualDensity.standard,
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide(color: scheme.outlineVariant),
        backgroundColor: scheme.surfaceContainerHigh,
        selectedColor: scheme.secondaryContainer,
        labelStyle:
            textTheme.labelLarge?.copyWith(color: scheme.onSurface),
        padding:
            const EdgeInsets.symmetric(horizontal: spaceMd, vertical: spaceXs),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(raio - 4),
          )),
          padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: spaceMd, vertical: spaceSm)),
        ),
      ),
      // NOTA: `minimumSize` aqui usa uma LARGURA finita (não
      // `Size.fromHeight`/`double.infinity`). Um botão cuja largura mínima é
      // infinita quebra em runtime ("BoxConstraints forces an infinite
      // width") sempre que ele é filho direto (sem Expanded/Flexible) de uma
      // Row, porque a Row dá largura irrestrita a filhos não-flexíveis mesmo
      // quando a própria Row tem largura limitada. Para um botão "largura
      // total" dentro de uma Column/folha, envolva-o explicitamente em
      // `SizedBox(width: double.infinity, child: ...)` no local de uso.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, alvoToqueMinimo + 4),
          padding: const EdgeInsets.symmetric(horizontal: spaceXl),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(raio - 2),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, alvoToqueMinimo),
          padding: const EdgeInsets.symmetric(horizontal: spaceXl),
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(raio - 2),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(alvoToqueMinimo, alvoToqueMinimo),
          padding: const EdgeInsets.symmetric(horizontal: spaceLg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(raio - 4),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize:
              const Size(alvoToqueMinimo, alvoToqueMinimo),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: spaceLg, vertical: spaceLg),
        border: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: scheme.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: scheme.error, width: 1.6),
        ),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.secondaryContainer,
        indicatorShape: const StadiumBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
          );
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(raioGrande),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: scheme.outlineVariant,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(raioGrande)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(raio - 2),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: scheme.surfaceContainerHighest,
      ),
      switchTheme: SwitchThemeData(
        trackOutlineColor:
            const WidgetStatePropertyAll(Colors.transparent),
      ),
      // Centraliza a cor de todos os FABs ("Nova conta", "Nova entrada",
      // "Novo cartão") em `scheme.primary`/`onPrimary` — o padrão do Material
      // 3 (`primaryContainer`) destoava do restante da identidade
      // verde-petróleo. Ajustar aqui vale para todos de uma vez (DRY).
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        extendedTextStyle:
            textTheme.labelLarge?.copyWith(color: scheme.onPrimary),
      ),
    );
  }
}

/// Atalhos de leitura para o tema atual — reduz repetição de
/// `Theme.of(context)` nas telas.
extension AppThemeContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get texts => Theme.of(this).textTheme;
}
