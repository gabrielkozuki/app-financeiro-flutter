import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/feedback.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ui_kit.dart';
import '../cartao/cartoes_page.dart';
import '../entradas/entradas_page.dart';
import '../mes/mes_panorama.dart';
import 'percentuais_page.dart';

/// Aba "Configurações": rendas, cartões, percentuais da metodologia, exportação
/// e limpeza de dados (RF-15/RF-19/RF-20). O backup na nuvem entra no M8.
class ConfigTab extends ConsumerWidget {
  const ConfigTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colors;
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppTheme.maxLargura),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
              children: [
                const SectionLabel('Direcionamento'),
                _Grupo(children: [
                  _item(context,
                      icone: Icons.attach_money,
                      titulo: 'Rendas',
                      subtitulo: 'Entradas recorrentes e pontuais',
                      destino: const EntradasPage()),
                  _item(context,
                      icone: Icons.credit_card,
                      titulo: 'Cartões',
                      subtitulo: 'Cartões de crédito e faturas',
                      destino: const CartoesPage()),
                  _item(context,
                      icone: Icons.percent,
                      titulo: 'Metodologia (percentuais)',
                      subtitulo: 'Ajuste a referência 50-30-20',
                      destino: const PercentuaisPage()),
                ]),
                const SectionLabel('Dados'),
                _Grupo(children: [
                  ListTile(
                    leading: const Icon(Icons.download_outlined),
                    title: const Text('Exportar dados'),
                    subtitle:
                        const Text('Planilha (CSV) ou backup completo (JSON)'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _abrirExportar(context, ref),
                  ),
                  const ListTile(
                    leading: Icon(Icons.cloud_upload_outlined),
                    title: Text('Backup na nuvem'),
                    subtitle: Text('Em breve (M8, com login)'),
                    enabled: false,
                  ),
                ]),
                const SectionLabel('Zona de risco'),
                _Grupo(children: [
                  ListTile(
                    leading: Icon(Icons.delete_forever_outlined,
                        color: scheme.error),
                    title: Text('Apagar todos os dados',
                        style: TextStyle(color: scheme.error)),
                    onTap: () => _apagarTudo(context, ref),
                  ),
                ]),
                const SizedBox(height: AppTheme.spaceLg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context,
      {required IconData icone,
      required String titulo,
      required String subtitulo,
      required Widget destino}) {
    return ListTile(
      leading: Icon(icone),
      title: Text(titulo),
      subtitle: Text(subtitulo),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => destino)),
    );
  }

  Future<void> _abrirExportar(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart_outlined),
              title: const Text('Planilha do mês (CSV)'),
              onTap: () async {
                Navigator.pop(ctx);
                await _exportarCsv(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.data_object),
              title: const Text('Backup completo (JSON)'),
              onTap: () async {
                Navigator.pop(ctx);
                await _exportarJson(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportarCsv(BuildContext context, WidgetRef ref) async {
    final mes = ref.read(mesReferenciaProvider);
    await executarComFeedback(
      context,
      () async {
        final conteudo =
            await ref.read(exportServiceProvider).exportarCsvMes(mes);
        await _compartilhar(
            'financas_$mes.csv', conteudo, 'Planilha de $mes');
      },
      mensagemErro: 'Não foi possível exportar a planilha deste mês.',
    );
  }

  Future<void> _exportarJson(BuildContext context, WidgetRef ref) async {
    await executarComFeedback(
      context,
      () async {
        final conteudo = await ref.read(exportServiceProvider).exportarJson();
        await _compartilhar(
            'financas_backup.json', conteudo, 'Backup completo do app');
      },
      mensagemErro: 'Não foi possível gerar o backup.',
    );
  }

  Future<void> _compartilhar(String nome, String conteudo, String texto) async {
    final dir = await getTemporaryDirectory();
    final arquivo = File('${dir.path}/$nome');
    await arquivo.writeAsString(conteudo);
    await SharePlus.instance
        .share(ShareParams(files: [XFile(arquivo.path)], text: texto));
  }

  Future<void> _apagarTudo(BuildContext context, WidgetRef ref) async {
    final passo1 = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar todos os dados?'),
        content: const Text(
            'Isso remove rendas, contas, cartões e histórico deste dispositivo.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton.tonal(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Continuar')),
        ],
      ),
    );
    if (passo1 != true || !context.mounted) return;

    final passo2 = await showDialog<bool>(
      context: context,
      builder: (_) => const _ConfirmarExclusaoDialog(),
    );
    if (passo2 != true || !context.mounted) return;

    final ok = await executarComFeedback(
      context,
      () => ref.read(exportServiceProvider).apagarTudo(),
      mensagemErro: 'Não foi possível apagar os dados.',
    );
    if (!ok || !context.mounted) return;
    invalidarLeituras(ref);
    // Meses reabertos são de dados que não existem mais.
    ref.read(mesesReabertosProvider.notifier).limpar();
  }
}

/// Segunda confirmação da exclusão total (RF-20): exige digitar "excluir".
///
/// É dono do próprio [TextEditingController], descartando-o em [State.dispose].
/// Isso evita o crash "TextEditingController was used after being disposed",
/// que ocorria quando o controller era descartado pelo chamador enquanto a
/// animação de fechamento do diálogo ainda reconstruía o [TextField].
class _ConfirmarExclusaoDialog extends StatefulWidget {
  const _ConfirmarExclusaoDialog();

  @override
  State<_ConfirmarExclusaoDialog> createState() =>
      _ConfirmarExclusaoDialogState();
}

class _ConfirmarExclusaoDialogState extends State<_ConfirmarExclusaoDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final confirmado = _controller.text.trim().toLowerCase() == 'excluir';
    return AlertDialog(
      title: const Text('Tem certeza?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
              'Esta ação não pode ser desfeita. Para confirmar, digite '
              '"excluir" abaixo.'),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            autocorrect: false,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'excluir',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar')),
        FilledButton(
          style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error),
          onPressed: confirmado ? () => Navigator.pop(context, true) : null,
          child: const Text('Apagar tudo'),
        ),
      ],
    );
  }
}

/// Agrupa itens de configuração num único card com divisores finos, dando
/// hierarquia visual às seções (Direcionamento, Dados, Zona de risco).
class _Grupo extends StatelessWidget {
  const _Grupo({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppTheme.spaceLg, 0, AppTheme.spaceLg, AppTheme.spaceSm),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}
