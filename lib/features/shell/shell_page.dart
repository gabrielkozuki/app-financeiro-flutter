import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

import '../config/config_tab.dart';
import '../contas/contas_tab.dart';
import '../grafico/grafico_tab.dart';

/// Casca de navegação com EXATAMENTE 3 menus fixos (Contas | Gráfico |
/// Configurações), conforme o protótipo. Formulários e detalhes abrem
/// sobrepostos (push/modal) e nunca adicionam itens a esta barra.
class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _indice = 0;

  static const _abas = [ContasTab(), GraficoTab(), ConfigTab()];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(index: _indice, children: _abas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.checklist_outlined),
            selectedIcon: const Icon(Icons.checklist),
            label: l10n.abaContas,
          ),
          NavigationDestination(
            icon: const Icon(Icons.donut_small_outlined),
            selectedIcon: const Icon(Icons.donut_small),
            label: l10n.abaGrafico,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.abaConfiguracoes,
          ),
        ],
      ),
    );
  }
}
