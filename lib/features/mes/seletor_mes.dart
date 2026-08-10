import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/dates.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';

/// Seletor de mês (‹ Mês Ano ›) usado nas abas Contas e Gráfico. As setas mudam
/// um mês por vez; tocar no rótulo abre um seletor de mês/ano. Navegar para
/// meses passados exibe o histórico em modo leitura (RF-18).
class SeletorMes extends ConsumerWidget {
  const SeletorMes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mes = ref.watch(mesSelecionadoProvider);
    final textTheme = Theme.of(context).textTheme;
    final notifier = ref.read(mesSelecionadoProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => notifier.mover(-1),
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Mês anterior',
        ),
        // Espaço extra entre a seta e o rótulo — evita toques acidentais na
        // seta ao mirar no rótulo (e vice-versa).
        const SizedBox(width: AppTheme.spaceLg),
        // Toque no rótulo abre o seletor de mês/ano.
        Semantics(
          button: true,
          label: 'Mês selecionado: ${mesAno(mes)}. Toque para escolher outro.',
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.raio),
            onTap: () async {
              final escolhido = await selecionarMes(context, mes);
              if (escolhido != null) notifier.definir(escolhido);
            },
            // O texto sozinho (titleLarge + padding 4/4) fica com ~36dp de
            // altura de toque, abaixo dos 44dp de RNF-05. As setas vizinhas já
            // herdam 44x44 do IconButtonTheme; aqui garantimos o mesmo mínimo.
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(minHeight: AppTheme.alvoToqueMinimo),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spaceSm, vertical: AppTheme.spaceXs),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        mesAno(mes),
                        style: textTheme.titleLarge,
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spaceLg),
        IconButton(
          onPressed: () => notifier.mover(1),
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Próximo mês',
        ),
      ],
    );
  }
}

/// [SeletorMes] pronto para `AppBar.bottom`. A altura acompanha o textScaler do
/// usuário (RNF-05): 48dp fixos cortavam o rótulo do mês em fontes grandes.
/// Nunca limitamos o textScaler — só ajustamos a barra a ele.
PreferredSizeWidget seletorMesBar(BuildContext context) => PreferredSize(
      preferredSize:
          Size.fromHeight(MediaQuery.textScalerOf(context).scale(48)),
      child: const SeletorMes(),
    );

/// Abre um seletor de mês/ano e devolve o primeiro dia do mês escolhido (ou
/// nulo se cancelado). Preferimos um seletor de mês ao `showDatePicker` padrão,
/// que é focado em dias — aqui o recorte é sempre mensal.
Future<DateTime?> selecionarMes(BuildContext context, DateTime inicial) {
  return showDialog<DateTime>(
    context: context,
    builder: (_) => _SeletorMesDialog(inicial: inicial),
  );
}

class _SeletorMesDialog extends StatefulWidget {
  const _SeletorMesDialog({required this.inicial});

  final DateTime inicial;

  @override
  State<_SeletorMesDialog> createState() => _SeletorMesDialogState();
}

class _SeletorMesDialogState extends State<_SeletorMesDialog> {
  late int _ano = widget.inicial.year;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final agora = DateTime.now();

    return AlertDialog(
      title: const Text('Escolher mês'),
      contentPadding: const EdgeInsets.fromLTRB(
          AppTheme.spaceLg, AppTheme.spaceSm, AppTheme.spaceLg, AppTheme.spaceSm),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Navegação de ano.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => setState(() => _ano--),
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Ano anterior',
                ),
                Text('$_ano', style: context.texts.titleLarge),
                IconButton(
                  onPressed: () => setState(() => _ano++),
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Próximo ano',
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceSm),
            // Grade de 12 meses.
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              mainAxisSpacing: AppTheme.spaceSm,
              crossAxisSpacing: AppTheme.spaceSm,
              childAspectRatio: 2.0,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (var m = 1; m <= 12; m++)
                  _BotaoMes(
                    rotulo: nomeMes(m).substring(0, 3),
                    selecionado:
                        _ano == widget.inicial.year && m == widget.inicial.month,
                    ehHoje: _ano == agora.year && m == agora.month,
                    onTap: () => Navigator.pop(context, DateTime(_ano, m)),
                    scheme: scheme,
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}

class _BotaoMes extends StatelessWidget {
  const _BotaoMes({
    required this.rotulo,
    required this.selecionado,
    required this.onTap,
    required this.scheme,
    this.ehHoje = false,
  });

  final String rotulo;
  final bool selecionado;
  final bool ehHoje;
  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    // "Hoje" era sinalizado só por um pontinho de 4x4 dependente de matiz —
    // ilegível para quem tem baixa visão de cor. Uma borda visível não
    // depende de matiz, e o rótulo semântico cobre o leitor de tela.
    final destaqueHoje = ehHoje && !selecionado;
    final conteudo = Material(
      color: selecionado ? scheme.primary : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppTheme.raio - 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.raio - 4),
        onTap: onTap,
        child: Container(
          decoration: destaqueHoje
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.raio - 4),
                  border: Border.all(color: scheme.primary, width: 2),
                )
              : null,
          alignment: Alignment.center,
          child: Text(
            rotulo,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selecionado ? scheme.onPrimary : scheme.onSurface,
            ),
          ),
        ),
      ),
    );
    if (!ehHoje) return conteudo;
    // Substitui a semântica automática do botão (que só leria o rótulo do
    // mês) para incluir "mês atual" — informação que hoje só existia na cor.
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: '$rotulo, mês atual',
      onTap: onTap,
      child: conteudo,
    );
  }
}
