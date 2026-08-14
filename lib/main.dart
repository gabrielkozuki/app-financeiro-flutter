import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/shell/root_gate.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const ProviderScope(child: FinancasApp()));
}

class FinancasApp extends StatelessWidget {
  const FinancasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // O título vem do ARB (`onGenerateTitle`, não `title`): é ele que aparece
      // no seletor de apps recentes do Android, e precisa acompanhar o idioma.
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitulo,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const RootGate(),
    );
  }
}
