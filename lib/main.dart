import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers.dart';
import 'core/theme/app_theme.dart';
import 'features/shell/root_gate.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Falha de inicialização NÃO impede o app de abrir: sem conta, o app funciona
  // inteiro offline (RNF-01/RNF-04), e login é um extra que mora em
  // Configurações. Deixar isso lançar trocaria uma funcionalidade opcional por
  // uma tela branca.
  var firebaseOk = false;
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    firebaseOk = true;
  } catch (e, s) {
    debugPrint('Firebase indisponível — o app segue offline. $e\n$s');
  }

  runApp(ProviderScope(
    overrides: [
      firebaseDisponivelProvider.overrideWith((_) => firebaseOk),
    ],
    child: const FinancasApp(),
  ));
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
