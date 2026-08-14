import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/ui_kit.dart';
import '../../l10n/app_localizations.dart';

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
                  // Não existe "restaurar de um arquivo": o backup de verdade
                  // é o da nuvem (M9), e um segundo caminho de restauração
                  // seria uma segunda fonte para a mesma coisa. O JSON exportado
                  // em Configurações continua sendo portabilidade do dado
                  // (RF-19), não um canal de restauração.
                ]),
                const SizedBox(height: AppTheme.spaceLg),
              ],
            ),
          ),
        ),
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
