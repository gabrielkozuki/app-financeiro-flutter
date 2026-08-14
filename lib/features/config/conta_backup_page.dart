import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/feedback.dart';
import '../../core/format/dates.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ui_kit.dart';
import '../../data/backup_service.dart';
import '../../l10n/app_localizations.dart';
import '../mes/mes_panorama.dart';

/// Conta e backup: onde o usuário entra na conta dele e restaura seus dados.
///
/// É uma página sobreposta (push), alcançável de Configurações **e** da
/// primeira tela do onboarding — quem instala o app num aparelho novo precisa
/// chegar aqui sem antes cadastrar nada, senão restaurar apagaria o que ele
/// acabou de digitar.
///
/// Autenticação NÃO é porta de entrada: o app abre e funciona inteiro sem
/// login (RNF-01/RNF-04). Entrar serve para ganhar backup na nuvem, do mesmo
/// jeito que exportar CSV serve para ganhar planilha.
class ContaBackupPage extends ConsumerWidget {
  const ContaBackupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.configContaBackup)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppTheme.maxLargura),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
              children: [
                SectionLabel(l10n.backupSecaoEntrar),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppTheme.spaceLg, 0,
                      AppTheme.spaceLg, AppTheme.spaceSm),
                  child: Text(
                    l10n.backupEntrarTexto,
                    style: context.texts.bodySmall
                        ?.copyWith(color: context.colors.onSurfaceVariant),
                  ),
                ),
                // ORDEM IMPORTA, não é preferência visual: a diretriz 4.8 de
                // revisão da App Store exige uma opção de login equivalente e
                // com privacidade quando há login de terceiros (Google), e as
                // HIG da Apple pedem o "Entrar com a Apple" em posição de
                // destaque. Manter Apple ACIMA de Google evita rejeição na
                // publicação. Não reordene ao implementar o M8.
                _Grupo(children: [
                  ListTile(
                    leading: const Icon(Icons.apple),
                    title: Text(l10n.backupEntrarApple),
                    subtitle: Text(l10n.backupEmBreve),
                    enabled: false,
                  ),
                  ListTile(
                    leading: const Icon(Icons.g_mobiledata, size: 32),
                    title: Text(l10n.backupEntrarGoogle),
                    subtitle: Text(l10n.backupEmBreve),
                    enabled: false,
                  ),
                ]),
                SectionLabel(l10n.backupSecao),
                _Grupo(children: [
                  ListTile(
                    leading: const Icon(Icons.cloud_upload_outlined),
                    title: Text(l10n.backupNuvem),
                    subtitle: Text(l10n.backupNuvemSubtitulo),
                    enabled: false,
                  ),
                  ListTile(
                    leading: const Icon(Icons.restore_page_outlined),
                    title: Text(l10n.backupRestaurarArquivo),
                    subtitle: Text(l10n.backupRestaurarArquivoSubtitulo),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _restaurarDeArquivo(context, ref),
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

  Future<void> _restaurarDeArquivo(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final escolha = await FilePicker.pickFiles(
      dialogTitle: l10n.backupEscolherArquivo,
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    final caminho = escolha?.files.singleOrNull?.path;
    if (caminho == null || !context.mounted) return;

    final String conteudo;
    try {
      conteudo = await File(caminho).readAsString();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.backupErroLerArquivo)));
      }
      return;
    }
    if (!context.mounted) return;

    final quando = BackupService.geradoEm(conteudo);
    final confirmou = await _confirmar(context, quando);
    if (confirmou != true || !context.mounted) return;

    final ok = await executarComFeedback(
      context,
      () => ref.read(backupServiceProvider).importarJson(conteudo),
      mensagemErro: l10n.backupErroRestaurar,
    );
    if (!ok || !context.mounted) return;
    aposMudancaAmpla(ref);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.backupRestaurado)));
  }

  /// Confirma antes de substituir tudo. Diz a data do backup quando o arquivo
  /// a carrega, e avisa do buraco de meses: restaurar um backup de março em
  /// junho deixa abril e maio vazios, porque mês passado nunca é gerado
  /// (RN-05). Sem esse aviso o usuário conclui que a restauração falhou.
  Future<bool?> _confirmar(BuildContext context, DateTime? quando) {
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(quando == null
            ? l10n.backupRestaurarTitulo
            : l10n.backupRestaurarTituloComData(
                dataCurta(quando, l10n.localeName))),
        content: Text(l10n.backupRestaurarTexto),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.acaoCancelar)),
          FilledButton.tonal(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.acaoRestaurar)),
        ],
      ),
    );
  }
}

/// Agrupa itens num cartão, no mesmo padrão visual da aba Configurações.
class _Grupo extends StatelessWidget {
  const _Grupo({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceLg, vertical: AppTheme.spaceXs),
      child: Column(children: children),
    );
  }
}
