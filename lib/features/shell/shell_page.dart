import 'package:flutter/material.dart';

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
    return Scaffold(
      body: IndexedStack(index: _indice, children: _abas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Contas',
          ),
          NavigationDestination(
            icon: Icon(Icons.donut_small_outlined),
            selectedIcon: Icon(Icons.donut_small),
            label: 'Gráfico',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }
}
