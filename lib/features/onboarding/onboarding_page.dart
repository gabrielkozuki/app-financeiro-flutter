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
/// seção 12): o usuário toca e ajusta o valor.
const _sugestoes = <(String, Grupo, int)>[
  ('Aluguel', Grupo.necessidade, 5),
  ('Internet', Grupo.necessidade, 10),
  ('Energia', Grupo.necessidade, 15),
  ('Mercado', Grupo.necessidade, 20),
  ('Academia', Grupo.desejo, 10),
  ('Reserva de emergência', Grupo.investimento, 5),
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
        ? 'Renda ${_rendas.length + 1}'
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

  Future<double?> _perguntarValor(String nome) {
    return showDialog<double>(
      context: context,
      builder: (_) => _DialogoValor(nome: nome),
    );
  }

  Future<void> _concluir() async {
    setState(() => _salvando = true);
    final mes = ref.read(mesReferenciaProvider);
    final entradasRepo = ref.read(entradasRepoProvider);
    final contasRepo = ref.read(contasRepoProvider);
    final configRepo = ref.read(configRepoProvider);

    final ok = await executarComFeedback(context, () async {
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
    }, mensagemErro: 'Não foi possível concluir seu cadastro.');

    if (!mounted) return;
    setState(() => _salvando = false);
    if (!ok) return;
    invalidarLeituras(ref);
  }

  /// Confirma a saída antes de descartar os rascunhos: nada é persistido até
  /// [_concluir], então o back do sistema levaria embora tudo o que foi
  /// digitado sem aviso.
  Future<void> _confirmarSaida() async {
    final sair = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair e perder o que você já digitou?'),
        content: const Text(
            'Suas rendas e contas ainda não foram salvas. Você pode continuar '
            'de onde parou.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Continuar')),
          FilledButton.tonal(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sair')),
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

  Widget _indicadorProgresso() {
    final scheme = context.colors;
    return Semantics(
      label: 'Passo ${_pagina + 1} de $_totalPaginasOnboarding',
      child: Row(
        children: [
          for (var i = 0; i < _totalPaginasOnboarding; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == _totalPaginasOnboarding - 1 ? 0 : 6),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 4,
                  decoration: BoxDecoration(
                    color: i <= _pagina
                        ? scheme.primary
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _paginaBoasVindas() {
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
          Text('Minhas Finanças', style: textTheme.headlineMedium),
          const SizedBox(height: 24),
          Text(
            'Um aplicativo para organizar sua vida financeira, '
            'com o objetivo de te dar mais discernimento e autonomia.',
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          _bulletBoasVindas(Icons.checklist, 'Marque o que já pagou',
              'Veja num relance o que falta pagar no mês.'),
          const SizedBox(height: 16),
          _bulletBoasVindas(Icons.donut_small, 'Direcionamento',
              'Separação de renda proporcional como referência, '
                  'não como limitação.'),
          const SizedBox(height: 16),
          _bulletBoasVindas(Icons.lock_outline, 'Seus dados são seus',
              'Funciona offline; nada sai do aparelho sem você mandar.'),
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
          Text('Quais são suas rendas?', style: textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Adicione suas entradas mensais em valores líquidos — salário, '
            'vale, bolsa. Pode adicionar mais de uma.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _rendaNome,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Nome (ex.: Salário)',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: CampoMoeda(
                  controller: _rendaValorCtrl,
                  labelText: 'Valor líquido',
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _adicionarRenda(),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filledTonal(
                onPressed: podeAdicionar ? _adicionarRenda : null,
                icon: const Icon(Icons.add),
                tooltip: 'Adicionar renda',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_rendas.isEmpty)
            Text('Nenhuma renda adicionada ainda.', style: textTheme.bodySmall)
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
                Text('Total mensal', style: textTheme.titleMedium),
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
          Text('Como dividir seu dinheiro', style: textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Usamos a referência 50-30-20 como diagnóstico — nunca como '
            'limite ou cobrança. Dá para ajustar os percentuais depois.',
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
          Text(grupo.rotulo, style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          Text('$pct%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: grupo.cor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _paginaContas() {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Suas contas principais', style: textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Adicione de 3 a 5 contas para começar. Toque numa sugestão:',
              style: textTheme.bodyMedium),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final (nome, grupo, dia) in _sugestoes)
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
    final podeAvancarRenda = _rendas.isNotEmpty;
    final podeConcluir = _contas.isNotEmpty && !_salvando;

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
          switch (_pagina) {
            // 0 = boas-vindas, 1 = renda, 2 = metodologia, 3 = contas.
            0 => FilledButton(
                onPressed: () => _irPara(1),
                child: const Text('Começar'),
              ),
            1 => FilledButton(
                onPressed: podeAvancarRenda ? () => _irPara(2) : null,
                child: const Text('Continuar'),
              ),
            2 => FilledButton(
                onPressed: () => _irPara(3),
                child: const Text('Continuar'),
              ),
            _ => FilledButton(
                onPressed: podeConcluir ? _concluir : null,
                child: _salvando
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Concluir'),
              ),
          },
        ],
      ),
    );
  }
}

/// Diálogo "quanto custa?" das sugestões de conta. É dono do próprio
/// [TextEditingController] e o descarta em [State.dispose] — descartá-lo no
/// `.then` do `showDialog` causa o crash "TextEditingController was used after
/// being disposed" durante a animação de fechamento (ver `config_tab.dart`).
class _DialogoValor extends StatefulWidget {
  const _DialogoValor({required this.nome});

  final String nome;

  @override
  State<_DialogoValor> createState() => _DialogoValorState();
}

class _DialogoValorState extends State<_DialogoValor> {
  final _valor = TextEditingController();

  @override
  void dispose() {
    _valor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.nome),
      content: CampoMoeda(
        controller: _valor,
        labelText: 'Valor',
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final v = parseMoeda(_valor.text);
            Navigator.pop(context, v > 0 ? v : null);
          },
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
