import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/feedback.dart';
import '../../core/format/dates.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ui_kit.dart';
import '../../data/auth_service.dart';
import '../../data/backup_service.dart';
import '../../domain/entities/usuario.dart';
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
class ContaBackupPage extends ConsumerStatefulWidget {
  const ContaBackupPage({super.key});

  @override
  ConsumerState<ContaBackupPage> createState() => _ContaBackupPageState();
}

class _ContaBackupPageState extends ConsumerState<ContaBackupPage> {
  bool _ocupado = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final disponivel = ref.watch(firebaseDisponivelProvider);
    final usuario = ref.watch(usuarioProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.configContaBackup)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppTheme.maxLargura),
            child: Stack(
              children: [
                if (!disponivel)
                  _Indisponivel(l10n: l10n)
                else
                  usuario.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => erroAsync(e, s,
                        contexto: 'usuarioProvider',
                        onTentarNovamente: () => ref.invalidate(usuarioProvider)),
                    data: (u) => u == null ? _deslogado(l10n) : _logado(l10n, u),
                  ),
                if (_ocupado)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x33000000),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Telas
  // -------------------------------------------------------------------------

  Widget _deslogado(AppLocalizations l10n) => ListView(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
        children: [
          SectionLabel(l10n.backupSecaoEntrar),
          _Texto(l10n.backupEntrarTexto),
          // ORDEM IMPORTA: Apple ACIMA do Google. A diretriz 4.8 da App Store
          // exige uma alternativa equivalente e com privacidade quando há login
          // de terceiros, e as HIG pedem destaque. É exigência de revisão, não
          // estética — não reordene.
          //
          // No Android a Apple não aparece: lá o pacote cairia num fluxo web,
          // pior que o login do Google, para atender uma exigência que não vale
          // naquela loja.
          _Grupo(children: [
            if (AuthService.appleDisponivel)
              ListTile(
                leading: const Icon(Icons.apple, size: 30),
                title: Text(l10n.backupEntrarApple),
                onTap: _ocupado ? null : _entrarComApple,
              ),
            ListTile(
              leading: const Icon(Icons.g_mobiledata, size: 32),
              title: Text(l10n.backupEntrarGoogle),
              onTap: _ocupado ? null : _entrar,
            ),
          ]),
          const SizedBox(height: AppTheme.spaceLg),
        ],
      );

  Widget _logado(AppLocalizations l10n, Usuario u) => ListView(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
        children: [
          SectionLabel(l10n.backupSecaoEntrar),
          _Grupo(children: [
            ListTile(
              leading: const Icon(Icons.account_circle_outlined, size: 32),
              title: Text(u.rotulo ?? l10n.backupEntrarGoogle),
              subtitle: u.rotulo != null && u.email != null && u.rotulo != u.email
                  ? Text(u.email!)
                  : null,
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(l10n.backupSair),
              onTap: _ocupado ? null : () => _sair(u),
            ),
          ]),
          SectionLabel(l10n.backupSecao),
          _Grupo(children: [
            ListTile(
              leading: const Icon(Icons.cloud_upload_outlined),
              title: Text(l10n.backupEnviar),
              subtitle: Text(l10n.backupEnviarSubtitulo),
              onTap: _ocupado ? null : () => _enviar(u),
            ),
            ListTile(
              leading: const Icon(Icons.cloud_download_outlined),
              title: Text(l10n.backupRestaurarDaNuvem),
              subtitle: Text(l10n.backupRestaurarDaNuvemSubtitulo),
              onTap: _ocupado ? null : () => _restaurar(u),
            ),
            // Não existe "restaurar de um arquivo": o backup de verdade é o da
            // nuvem, e um segundo caminho de restauração seria uma segunda
            // fonte para a mesma coisa. O JSON exportado em Configurações
            // continua sendo portabilidade do dado (RF-19).
          ]),
          const SizedBox(height: AppTheme.spaceLg),
          _Grupo(children: [
            ListTile(
              leading: Icon(Icons.person_remove_outlined,
                  color: context.colors.error),
              title: Text(l10n.backupExcluirConta,
                  style: TextStyle(color: context.colors.error)),
              subtitle: Text(l10n.backupExcluirContaSubtitulo),
              onTap: _ocupado ? null : () => _excluirConta(u),
            ),
          ]),
          const SizedBox(height: AppTheme.spaceLg),
        ],
      );

  // -------------------------------------------------------------------------
  // Ações
  //
  // Toda escrita passa por `executarComFeedback`, que captura, loga e mostra
  // SnackBar sem relançar — por isso o `_ocupado` é resetado aqui, e não num
  // catch. Nenhuma delas fecha a tela: o usuário fica vendo o novo estado.
  // -------------------------------------------------------------------------

  Future<void> _rodar(Future<void> Function() acao) async {
    setState(() => _ocupado = true);
    try {
      await acao();
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _entrar() =>
      _entrarCom((s) => s.entrarComGoogle());

  Future<void> _entrarComApple() =>
      _entrarCom((s) => s.entrarComApple());

  /// Os dois provedores divergem só na obtenção da credencial. Daí para frente
  /// — cancelamento, erro e reconciliação dos dados — o caminho é o mesmo, e
  /// duplicá-lo seria a forma de os dois fluxos divergirem numa correção
  /// futura.
  Future<void> _entrarCom(Future<Usuario?> Function(AuthService) obter) =>
      _rodar(() async {
        final l10n = AppLocalizations.of(context);
        Usuario? u;
        final ok = await executarComFeedback(
          context,
          () async => u = await obter(ref.read(authServiceProvider)),
          mensagemErro: l10n.backupErroEntrar,
        );
        // `u == null` com `ok == true` é o usuário fechando a folha do provedor:
        // cancelar não é falha e não merece aviso nenhum.
        if (!ok || u == null || !mounted) return;
        await _reconciliar(u!);
      });

  /// Decide o que fazer com os dados logo depois do login.
  ///
  /// **Só pergunta quando os dois lados têm conteúdo** — é aí que existe risco
  /// de destruir algo. Banco local vazio restaura direto (não há o que perder);
  /// conta sem backup não tem o que restaurar. Isso substitui a ideia original
  /// de guardar "último uid visto", que exigiria uma tabela nova para um dado
  /// que a própria situação já revela.
  Future<void> _reconciliar(Usuario u) async {
    final l10n = AppLocalizations.of(context);
    final nuvem = ref.read(backupNuvemProvider);
    final backup = ref.read(backupServiceProvider);

    String? remoto;
    final ok = await executarComFeedback(
      context,
      () async => remoto = await nuvem.baixar(u.uid),
      mensagemErro: l10n.backupErroRestaurar,
    );
    if (!ok || remoto == null || !mounted) return;

    final temDadosLocais = await backup.temDados();
    if (!mounted) return;

    if (temDadosLocais) {
      final data = BackupService.geradoEm(remoto!);
      final usarNuvem = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.backupConflitoTitulo),
          content: Text(l10n.backupConflitoTexto(
              data == null ? '—' : dataCurta(data, l10n.localeName))),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.backupConflitoUsarAparelho)),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.backupConflitoUsarNuvem)),
          ],
        ),
      );
      if (!mounted) return;
      // "Usar os deste aparelho" não é só recusar: sem enviar, o backup antigo
      // continua lá e a próxima entrada pergunta de novo a mesma coisa.
      if (usarNuvem != true) return _enviar(u);
    }

    await _aplicarRestauracao(remoto!);
  }

  Future<void> _aplicarRestauracao(String json) async {
    final l10n = AppLocalizations.of(context);
    final ok = await executarComFeedback(
      context,
      () => ref.read(backupServiceProvider).importarJson(json),
      mensagemErro: l10n.backupErroRestaurar,
    );
    if (!mounted) return;
    if (ok) {
      // Trocar o banco inteiro invalida TUDO. Sem `aposMudancaAmpla`, os meses
      // reabertos desta sessão continuam marcados e a tela mostra dado que não
      // existe mais.
      aposMudancaAmpla(ref);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.backupRestaurado)));
    }
  }

  Future<void> _enviar(Usuario u) async {
    final l10n = AppLocalizations.of(context);
    final ok = await executarComFeedback(
      context,
      () async {
        final json = await ref.read(backupServiceProvider).exportarJson();
        await ref.read(backupNuvemProvider).enviar(uid: u.uid, json: json);
      },
      mensagemErro: l10n.backupErroEnviar,
    );
    if (ok && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.backupEnviado)));
    }
  }

  Future<void> _restaurar(Usuario u) => _rodar(() async {
        final l10n = AppLocalizations.of(context);
        String? remoto;
        final ok = await executarComFeedback(
          context,
          () async => remoto = await ref.read(backupNuvemProvider).baixar(u.uid),
          mensagemErro: l10n.backupErroRestaurar,
        );
        if (!ok || !mounted) return;
        if (remoto == null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.backupSemBackup)));
          return;
        }
        final data = BackupService.geradoEm(remoto!);
        final confirmou = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(data == null
                ? l10n.backupRestaurarTitulo
                : l10n.backupRestaurarTituloComData(
                    dataCurta(data, l10n.localeName))),
            content: Text(l10n.backupRestaurarTexto),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10n.acaoCancelar)),
              FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l10n.backupRestaurarDaNuvem)),
            ],
          ),
        );
        if (confirmou != true || !mounted) return;
        await _aplicarRestauracao(remoto!);
      });

  Future<void> _sair(Usuario u) => _rodar(() async {
        final l10n = AppLocalizations.of(context);
        final enviar = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.backupSairPergunta),
            content: Text(l10n.backupSairTexto),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, null),
                  child: Text(l10n.acaoCancelar)),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10n.backupSairSoSair)),
              FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l10n.backupSairEnviarESair)),
            ],
          ),
        );
        if (enviar == null || !mounted) return;
        if (enviar) await _enviar(u);
        if (!mounted) return;
        await executarComFeedback(
          context,
          () => ref.read(authServiceProvider).sair(),
          mensagemErro: l10n.backupErroSair,
        );
      });

  Future<void> _excluirConta(Usuario u) => _rodar(() async {
        final l10n = AppLocalizations.of(context);
        final confirmou = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.backupExcluirContaTitulo),
            content: Text(l10n.backupExcluirContaTexto),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10n.acaoCancelar)),
              FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: context.colors.error),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l10n.excluir)),
            ],
          ),
        );
        if (confirmou != true || !mounted) return;
        final ok = await executarComFeedback(
          context,
          () async {
            // ORDEM IMPORTA: apagar o nó ANTES de excluir a conta. Depois do
            // `delete()` não há mais uid autenticado, e a regra
            // `auth.uid === $uid` recusaria a escrita — o backup ficaria órfão
            // no banco para sempre.
            await ref.read(backupNuvemProvider).apagar(u.uid);
            await ref.read(authServiceProvider).excluirConta();
          },
          mensagemErro: l10n.backupErroExcluirConta,
        );
        if (ok && mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.backupContaExcluida)));
        }
      });
}

/// Estado de falha na inicialização do Firebase. Explica em vez de oferecer um
/// botão que não vai funcionar — e deixa claro que só esta tela está afetada.
class _Indisponivel extends StatelessWidget {
  const _Indisponivel({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_outlined,
                  size: 48, color: context.colors.onSurfaceVariant),
              const SizedBox(height: AppTheme.spaceLg),
              Text(l10n.backupIndisponivel,
                  style: context.texts.titleMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppTheme.spaceSm),
              Text(l10n.backupIndisponivelTexto,
                  style: context.texts.bodyMedium
                      ?.copyWith(color: context.colors.onSurfaceVariant),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}

class _Texto extends StatelessWidget {
  const _Texto(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(
            AppTheme.spaceLg, 0, AppTheme.spaceLg, AppTheme.spaceSm),
        child: Text(texto,
            style: context.texts.bodySmall
                ?.copyWith(color: context.colors.onSurfaceVariant)),
      );
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
