import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/feedback.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ui_kit.dart';
import '../../l10n/app_localizations.dart';
import '../cartao/cartoes_page.dart';
import '../entradas/entradas_page.dart';
import '../mes/mes_panorama.dart';
import 'conta_backup_page.dart';
import 'percentuais_page.dart';

/// Aba "Configurações": rendas, cartões, percentuais da metodologia, exportação
/// e limpeza de dados (RF-15/RF-19/RF-20). O backup na nuvem entra no M8.
class ConfigTab extends ConsumerWidget {
  const ConfigTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.colors;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.abaConfiguracoes)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppTheme.maxLargura),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
              children: [
                SectionLabel(l10n.tituloDirecionamento),
                _Grupo(children: [
                  _item(context,
                      icone: Icons.attach_money,
                      titulo: l10n.rendasTitulo,
                      subtitulo: l10n.configRendasSubtitulo,
                      destino: const EntradasPage()),
                  _item(context,
                      icone: Icons.credit_card,
                      titulo: l10n.cartoesTitulo,
                      subtitulo: l10n.configCartoesSubtitulo,
                      destino: const CartoesPage()),
                  _item(context,
                      icone: Icons.percent,
                      titulo: l10n.configMetodologia,
                      subtitulo: l10n.configMetodologiaSubtitulo,
                      destino: const PercentuaisPage()),
                ]),
                SectionLabel(l10n.configSecaoDados),
                _Grupo(children: [
                  ListTile(
                    leading: const Icon(Icons.download_outlined),
                    title: Text(l10n.configExportar),
                    subtitle: Text(l10n.configExportarSubtitulo),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _abrirExportar(context, ref),
                  ),
                  _item(context,
                      icone: Icons.account_circle_outlined,
                      titulo: l10n.configContaBackup,
                      subtitulo: l10n.configContaBackupSubtitulo,
                      destino: const ContaBackupPage()),
                ]),
                SectionLabel(l10n.configSecaoRisco),
                _Grupo(children: [
                  ListTile(
                    leading: Icon(Icons.delete_forever_outlined,
                        color: scheme.error),
                    title: Text(l10n.configApagarTudo,
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
    final l10n = AppLocalizations.of(context);
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart_outlined),
              title: Text(l10n.configExportarCsv),
              onTap: () async {
                Navigator.pop(ctx);
                await _exportarCsv(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.data_object),
              title: Text(l10n.configExportarJson),
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
    final l10n = AppLocalizations.of(context);
    final mes = ref.read(mesReferenciaProvider);
    await executarComFeedback(
      context,
      () async {
        final conteudo =
            await ref.read(exportServiceProvider).exportarCsvMes(mes);
        await _compartilhar(
            'financas_$mes.csv', conteudo, l10n.configCompartilharCsv(mes));
      },
      mensagemErro: l10n.configErroExportarCsv,
    );
  }

  Future<void> _exportarJson(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    await executarComFeedback(
      context,
      () async {
        final conteudo = await ref.read(backupServiceProvider).exportarJson();
        await _compartilhar('financas_backup.json', conteudo,
            l10n.configCompartilharJson);
      },
      mensagemErro: l10n.configErroExportarJson,
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
    final l10n = AppLocalizations.of(context);
    final passo1 = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.configApagarConfirmarTitulo),
        content: Text(l10n.configApagarConfirmarTexto),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.acaoCancelar)),
          FilledButton.tonal(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.acaoContinuar)),
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
      () => ref.read(backupServiceProvider).apagarTudo(),
      mensagemErro: l10n.configErroApagar,
    );
    if (!ok || !context.mounted) return;
    aposMudancaAmpla(ref);
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
    final l10n = AppLocalizations.of(context);
    final palavra = l10n.configApagarPalavra;
    final confirmado = _controller.text.trim().toLowerCase() == palavra;
    return AlertDialog(
      title: Text(l10n.configApagarTemCerteza),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.configApagarInstrucao(palavra)),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            autocorrect: false,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: palavra,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.acaoCancelar)),
        FilledButton(
          style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error),
          onPressed: confirmado ? () => Navigator.pop(context, true) : null,
          child: Text(l10n.configApagarAcao),
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
