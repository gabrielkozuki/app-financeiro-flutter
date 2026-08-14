import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/feedback.dart';
import '../../core/format/money.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/grupo_visual.dart';
import '../../core/widgets/campo_moeda.dart';
import '../../core/widgets/ui_kit.dart';
import '../../domain/entities/conta.dart';
import '../../domain/entities/configuracao.dart';
import '../../domain/entities/entrada.dart';
import '../../domain/entities/enums.dart';
import '../../l10n/app_localizations.dart';
import '../config/conta_backup_page.dart';
import '../mes/mes_panorama.dart';

const _totalPaginasOnboarding = 4;

/// Percentuais exibidos na página da metodologia. Vêm do padrão do domínio
/// (`ConfiguracaoMetodologia`), não de literais 50/30/20 escritos na tela — se
/// o padrão mudar, a tela acompanha. A vigência não importa aqui: é só leitura.
const _metodologiaPadrao = ConfiguracaoMetodologia(mesVigenciaInicial: '');

/// Rascunho de conta enquanto o usuário monta o onboarding (ainda não persistido).
class _ContaRascunho {
  _ContaRascunho(this.nome, this.valor, this.grupo, this.dia);
  final String nome;
  final double valor;
  final Grupo grupo;
  final int dia;
}

/// Rascunho de renda recorrente durante o onboarding.
class _RendaRascunho {
  _RendaRascunho(this.nome, this.valor);
  final String nome;
  final double valor;
}

/// Sugestões prontas para reduzir o atrito do cadastro inicial (risco #4 da
/// seção 12): o usuário toca e ajusta o valor. O nome traduzido é o que vai
/// para o banco — a conta nasce com o rótulo que o usuário tocou.
List<(String, Grupo, int)> _sugestoes(AppLocalizations l10n) => [
      (l10n.onboardingSugestaoAluguel, Grupo.necessidade, 5),
      (l10n.onboardingSugestaoInternet, Grupo.necessidade, 10),
      (l10n.onboardingSugestaoEnergia, Grupo.necessidade, 15),
      (l10n.onboardingSugestaoMercado, Grupo.necessidade, 20),
      (l10n.onboardingSugestaoAcademia, Grupo.desejo, 10),
      (l10n.onboardingSugestaoReserva, Grupo.investimento, 5),
    ];

/// Onboarding de primeira execução (seção 9): renda → metodologia (padrão
/// 50-30-20) → 3 a 5 contas principais → app funcional.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controlador = PageController();
  final _rendaNome = TextEditingController();
  final _rendaValorCtrl = TextEditingController();
  final _rendas = <_RendaRascunho>[];
  final _contas = <_ContaRascunho>[];
  int _pagina = 0;
  bool _salvando = false;

  @override
  void dispose() {
    _controlador.dispose();
    _rendaNome.dispose();
    _rendaValorCtrl.dispose();
    super.dispose();
  }

  void _adicionarRenda() {
    final valor = parseMoeda(_rendaValorCtrl.text);
    if (valor <= 0) return;
    final nome = _rendaNome.text.trim().isEmpty
        ? AppLocalizations.of(context).onboardingRendaPadrao(_rendas.length + 1)
        : _rendaNome.text.trim();
    setState(() {
      _rendas.add(_RendaRascunho(nome, valor));
      _rendaNome.clear();
      _rendaValorCtrl.clear();
    });
  }

  void _irPara(int pagina) {
    // Fecha o teclado ao trocar de página do onboarding.
    FocusScope.of(context).unfocus();
    setState(() => _pagina = pagina);
    _controlador.animateToPage(
      pagina,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _adicionarConta(String sugestaoNome, Grupo grupo, int dia) async {
    final valor = await _perguntarValor(sugestaoNome);
    if (valor == null) return;
    setState(() =>
        _contas.add(_ContaRascunho(sugestaoNome, valor, grupo, dia)));
  }

  /// Diálogo "quanto custa?" das sugestões de conta. Sem controller: o valor é
  /// lido pelo `onChanged` e vive no escopo deste Future, então não há nada
  /// para descartar cedo demais — é o que causava o "TextEditingController was
  /// used after being disposed" na animação de fechamento (ver `config_tab`).
  Future<double?> _perguntarValor(String nome) {
    final l10n = AppLocalizations.of(context);
    var valor = 0.0;
    return showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(nome),
        content: CampoMoeda(
          labelText: l10n.campoValor,
          autofocus: true,
          onChanged: (texto) => valor = parseMoeda(texto),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.acaoCancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, valor > 0 ? valor : null),
            child: Text(l10n.acaoAdicionar),
          ),
        ],
      ),
    );
  }

  Future<void> _concluir() async {
    setState(() => _salvando = true);
    final l10n = AppLocalizations.of(context);
    final mes = ref.read(mesReferenciaProvider);
    final entradasRepo = ref.read(entradasRepoProvider);
    final contasRepo = ref.read(contasRepoProvider);
    final configRepo = ref.read(configRepoProvider);
    final emTransacao = ref.read(emTransacaoProvider);

    // Tudo ou nada: se as rendas gravassem e as contas não, o
    // `precisaOnboarding` viraria false e o usuário cairia no app na próxima
    // abertura com metade do que cadastrou, sem aviso.
    final ok = await executarComFeedback(context, () => emTransacao(() async {
      for (final r in _rendas) {
        await entradasRepo.criar(Entrada(
          id: 0,
          nome: r.nome,
          valorLiquido: r.valor,
          tipo: TipoEntrada.recorrente,
          // O onboarding não pergunta o dia (RF-01): melhor deixar em branco
          // (a tela de Rendas mostra "-") do que inventar um dia que o usuário
          // veria como "Recebe dia 5" sem entender de onde veio.
          diaRecebimento: null,
        ));
      }
      await configRepo.salvar(ConfiguracaoMetodologia(mesVigenciaInicial: mes));

      for (final c in _contas) {
        final id = await contasRepo.criar(Conta(
          id: 0,
          nome: c.nome,
          grupo: c.grupo,
          valorPlanejado: c.valor,
          diaVencimento: c.dia,
          recorrencia: Recorrencia.fixa,
        ));
        await contasRepo.inserirOcorrencia(
            contaId: id, mesReferencia: mes, valorPlanejado: c.valor);
      }
    }), mensagemErro: l10n.onboardingErroConcluir);

    if (!mounted) return;
    setState(() => _salvando = false);
    if (!ok) return;
    invalidarLeituras(ref);
  }

  /// Confirma a saída antes de descartar os rascunhos: nada é persistido até
  /// [_concluir], então o back do sistema levaria embora tudo o que foi
  /// digitado sem aviso.
  Future<void> _confirmarSaida() async {
    final l10n = AppLocalizations.of(context);
    final sair = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.onboardingSairTitulo),
        content: Text(l10n.onboardingSairTexto),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.acaoContinuar)),
          FilledButton.tonal(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.acaoSair)),
        ],
      ),
    );
    // Esta é a rota raiz (home do MaterialApp): não há para onde voltar, então
    // "sair" significa encerrar o app — o mesmo que o back faria sem o PopScope.
    if (sair == true) await SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final temRascunho = _pagina > 0 || _rendas.isNotEmpty || _contas.isNotEmpty;
    return PopScope(
      canPop: !temRascunho,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmarSaida();
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppTheme.maxLargura),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: _indicadorProgresso(),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _controlador,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _paginaBoasVindas(),
                        _paginaRenda(),
                        _paginaMetodologia(),
                        _paginaContas(),
                      ],
                    ),
                  ),
                  _rodape(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _indicadorProgresso() => Semantics(
        label: AppLocalizations.of(context)
            .onboardingPasso(_pagina + 1, _totalPaginasOnboarding),
        excludeSemantics: true,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (_pagina + 1) / _totalPaginasOnboarding,
            minHeight: 4,
          ),
        ),
      );

  Widget _paginaBoasVindas() {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          GroupAvatar(
            icone: Icons.account_balance_wallet_outlined,
            cor: context.colors.primary,
            tamanho: 72,
          ),
          const SizedBox(height: 20),
          Text(l10n.appTitulo,
              style: textTheme.headlineMedium),
          const SizedBox(height: 24),
          Text(
            l10n.onboardingBoasVindasTexto,
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          _bulletBoasVindas(
              Icons.checklist,
              l10n.onboardingBulletChecklistTitulo,
              l10n.onboardingBulletChecklistDescricao),
          const SizedBox(height: 16),
          _bulletBoasVindas(
              Icons.donut_small,
              l10n.onboardingBulletDirecionamentoTitulo,
              l10n.onboardingBulletDirecionamentoDescricao),
          const SizedBox(height: 16),
          _bulletBoasVindas(
              Icons.lock_outline,
              l10n.onboardingBulletPrivacidadeTitulo,
              l10n.onboardingBulletPrivacidadeDescricao),
          const SizedBox(height: 24),
          // Porta de saída do onboarding para quem NÃO é usuário novo.
          //
          // Sem ela, um aparelho recém-instalado é um beco sem saída: o
          // `precisaOnboardingProvider` só libera o app quando existe alguma
          // conta ou renda, e a restauração vive em Configurações — dentro do
          // app. Quem trocou de celular teria de cadastrar dados só para
          // alcançar a tela que os apagaria em seguida.
          Center(
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ContaBackupPage())),
              icon: const Icon(Icons.restore, size: 18),
              label: Text(l10n.onboardingJaUso),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bulletBoasVindas(IconData icone, String titulo, String descricao) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: context.colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(descricao, style: textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paginaRenda() {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final total = _rendas.fold<double>(0, (s, r) => s + r.valor);
    final podeAdicionar = parseMoeda(_rendaValorCtrl.text) > 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Icon(Icons.savings_outlined, size: 48, color: context.colors.primary),
          const SizedBox(height: 16),
          Text(l10n.onboardingRendaTitulo, style: textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingRendaTexto,
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _rendaNome,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.onboardingRendaNomeLabel,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: CampoMoeda(
                  controller: _rendaValorCtrl,
                  labelText: l10n.campoValorLiquido,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _adicionarRenda(),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filledTonal(
                onPressed: podeAdicionar ? _adicionarRenda : null,
                icon: const Icon(Icons.add),
                tooltip: l10n.onboardingAdicionarRenda,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_rendas.isEmpty)
            Text(l10n.onboardingRendaVazia, style: textTheme.bodySmall)
          else ...[
            for (var i = 0; i < _rendas.length; i++)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.repeat),
                title: Text(_rendas[i].nome),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(brl(_rendas[i].valor)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _rendas.removeAt(i)),
                    ),
                  ],
                ),
              ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.onboardingTotalMensal, style: textTheme.titleMedium),
                Text(brl(total),
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _paginaMetodologia() {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.donut_small_outlined,
              size: 48, color: context.colors.primary),
          const SizedBox(height: 16),
          Text(l10n.onboardingMetodologiaTitulo,
              style: textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            l10n.onboardingMetodologiaTexto,
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          for (final g in Grupo.values) _linhaMetodologia(g),
        ],
      ),
    );
  }

  Widget _linhaMetodologia(Grupo grupo) {
    final pct = _metodologiaPadrao.percentualDe(grupo).round();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          GroupAvatar(icone: grupo.icone, cor: grupo.cor, tamanho: 36),
          const SizedBox(width: 12),
          Text(grupo.rotulo(context),
              style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          Text('$pct%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: grupo.cor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _paginaContas() {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(l10n.onboardingContasTitulo, style: textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(l10n.onboardingContasTexto, style: textTheme.bodyMedium),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final (nome, grupo, dia) in _sugestoes(l10n))
                ActionChip(
                  avatar: Icon(grupo.icone, size: 18, color: grupo.cor),
                  label: Text(nome),
                  onPressed: () => _adicionarConta(nome, grupo, dia),
                ),
            ],
          ),
          const Divider(height: 32),
          Expanded(
            child: _contas.isEmpty
                ? Center(
                    child: Text('Nenhuma conta adicionada ainda.',
                        style: textTheme.bodyMedium),
                  )
                : ListView.builder(
                    itemCount: _contas.length,
                    itemBuilder: (_, i) {
                      final c = _contas[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: GroupAvatar(
                              icone: c.grupo.icone, cor: c.grupo.cor, tamanho: 36),
                          title: Text(c.nome),
                          subtitle: Text('Vence dia ${c.dia}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(brl(c.valor),
                                  style:
                                      const TextStyle(fontWeight: FontWeight.w600)),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () =>
                                    setState(() => _contas.removeAt(i)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _rodape() {
    final l10n = AppLocalizations.of(context);
    // 0 = boas-vindas, 1 = renda, 2 = metodologia, 3 = contas. Só a última
    // página conclui; as demais apenas avançam, e a de renda exige ao menos
    // uma entrada cadastrada.
    final ultima = _pagina == _totalPaginasOnboarding - 1;
    final podeAvancar = switch (_pagina) {
      1 => _rendas.isNotEmpty,
      3 => _contas.isNotEmpty,
      _ => true,
    };

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_pagina > 0)
            TextButton(
              onPressed: _salvando ? null : () => _irPara(_pagina - 1),
              child: const Text('Voltar'),
            ),
          const Spacer(),
          FilledButton(
            onPressed: (podeAvancar && !_salvando)
                ? (ultima ? _concluir : () => _irPara(_pagina + 1))
                : null,
            child: _salvando
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(switch (_pagina) {
                    0 => l10n.acaoComecar,
                    3 => l10n.acaoConcluir,
                    _ => l10n.acaoContinuar,
                  }),
          ),
        ],
      ),
    );
  }
}
