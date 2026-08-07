import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/widgets/ui_kit.dart';
import '../onboarding/onboarding_page.dart';
import 'shell_page.dart';

/// Decide a tela inicial: onboarding na primeira execução, senão o shell de 3
/// abas. A porta de autenticação (login) envolverá este gate no M8.
class RootGate extends ConsumerWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final precisa = ref.watch(precisaOnboardingProvider);
    return precisa.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      // Falha ao abrir/migrar o banco: sem isto o app inteiro virava um texto
      // de exceção sem nenhuma ação possível.
      error: (e, s) => Scaffold(
        body: erroAsync(
          e,
          s,
          contexto: 'RootGate',
          titulo: 'Não conseguimos abrir seus dados',
          onTentarNovamente: () => ref.invalidate(precisaOnboardingProvider),
        ),
      ),
      data: (precisaOnboarding) =>
          precisaOnboarding ? const OnboardingPage() : const ShellPage(),
    );
  }
}
