import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/feedback.dart';
import '../../core/format/dates.dart';
import '../../core/format/money.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/campo_moeda.dart';
import '../../core/widgets/ui_kit.dart';
import '../../domain/entities/entrada.dart';
import '../../domain/entities/enums.dart';
import '../../l10n/app_localizations.dart';
import '../mes/mes_panorama.dart';
import '../mes/seletor_mes.dart';

/// Tela (sobreposta) de gestão de renda: entradas recorrentes (salário) e
/// pontuais (13º, freelances) — RF-01/RF-02. Acessada pela aba Configurações.
/// Usa o mês selecionado do app: mostra as recorrentes (todo mês) e as pontuais
/// daquele mês, separadas.
class EntradasPage extends ConsumerWidget {
  const EntradasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(entradasVisiveisNoMesProvider);
    final mes = ref.watch(mesSelecionadoProvider);
    final mesChave = ref.watch(mesReferenciaProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.rendasTitulo),
        bottom: seletorMesBar(context),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirForm(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.rendaNova),
      ),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => erroAsync(
            e,
            s,
            contexto: 'EntradasPage',
            titulo: l10n.erroCarregarRendas,
            onTentarNovamente: () =>
                ref.invalidate(entradasVisiveisNoMesProvider),
          ),
          data: (entradas) {
            final recorrentes = entradas
                .where((e) => e.tipo == TipoEntrada.recorrente)
                .toList();
            final pontuais =
                entradas.where((e) => e.tipo == TipoEntrada.pontual).toList();
            final total = entradas.fold<double>(0, (s, e) => s + e.valorLiquido);

            if (entradas.isEmpty) {
              return EmptyState(
                icone: Icons.attach_money,
                titulo: l10n.rendasVazioTitulo,
                descricao: l10n.rendasVazioDescricao,
              );
            }

            return ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                _CardTotal(total: total),
                if (recorrentes.isNotEmpty) ...[
                  SectionLabel(l10n.rendasRecorrentes),
                  for (final e in recorrentes) _tile(context, ref, mesChave, e),
                ],
                if (pontuais.isNotEmpty) ...[
                  SectionLabel(
                      l10n.rendasPontuaisDoMes(mesAno(mes, l10n.localeName))),
                  for (final e in pontuais) _tile(context, ref, mesChave, e),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _tile(
      BuildContext context, WidgetRef ref, String mesChave, Entrada e) {
    final l10n = AppLocalizations.of(context);
    final pausada = e.pausadaEm(mesChave);
    final recorrente = e.tipo == TipoEntrada.recorrente;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceLg, vertical: AppTheme.spaceXs),
      child: Card(
        child: ListTile(
          leading: GroupAvatar(
            icone:
                e.tipo == TipoEntrada.recorrente ? Icons.repeat : Icons.event_outlined,
            cor: context.colors.primary,
            tamanho: 36,
          ),
          title: Text(e.nome,
              style: TextStyle(
                  color: pausada ? context.colors.onSurfaceVariant : null)),
          // Renda pausada anuncia o estado no lugar do dia de recebimento —
          // que deixou de valer enquanto ela não conta.
          subtitle: Text(pausada
              ? l10n.entradaPausada
              : recorrente
                  ? l10n.rendaRecebeDia('${e.diaRecebimento ?? '-'}')
                  : l10n.rendaSoEm(e.mesReferencia ?? '-')),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(brl(e.valorLiquido),
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: pausada ? context.colors.onSurfaceVariant : null,
                      decoration:
                          pausada ? TextDecoration.lineThrough : null)),
              // Só recorrente: pontual pertence a um mês e já não conta nos
              // seguintes. A ação fica NA LISTA, e não no formulário, porque
              // ela depende do mês exibido — e o seletor de mês está logo
              // acima, na mesma tela.
              if (recorrente)
                IconButton(
                  onPressed: () => _alternarPausa(context, ref, mesChave, e),
                  icon: Icon(pausada
                      ? Icons.play_arrow_outlined
                      : Icons.pause_outlined),
                  tooltip:
                      pausada ? l10n.entradaRetomar : l10n.entradaPausar,
                ),
            ],
          ),
          onTap: () => _abrirForm(context, entrada: e),
        ),
      ),
    );
  }

  /// Pausa ou retoma **a partir do mês exibido**, nunca retroativamente.
  ///
  /// Pausar em agosto: `pausadaDesde = '2026-08'` e `retomadaEm` limpo — de
  /// agosto em diante para de contar. Retomar em outubro: `retomadaEm =
  /// '2026-10'` — agosto e setembro seguem sem contar, outubro em diante volta.
  ///
  /// Retomar num mês anterior ao da pausa desfaz a pausa inteira: é o gesto de
  /// "eu não queria ter pausado", e não faria sentido gravar um intervalo que
  /// termina antes de começar.
  Future<void> _alternarPausa(
      BuildContext context, WidgetRef ref, String mesChave, Entrada e) async {
    final l10n = AppLocalizations.of(context);
    final pausada = e.pausadaEm(mesChave);
    final desfaz =
        pausada && (e.pausadaDesde == null || mesChave.compareTo(e.pausadaDesde!) <= 0);

    final atualizada = Entrada(
      id: e.id,
      nome: e.nome,
      valorLiquido: e.valorLiquido,
      tipo: e.tipo,
      diaRecebimento: e.diaRecebimento,
      mesReferencia: e.mesReferencia,
      pausadaDesde: pausada ? (desfaz ? null : e.pausadaDesde) : mesChave,
      retomadaEm: pausada ? (desfaz ? null : mesChave) : null,
    );

    final ok = await executarComFeedback(
      context,
      () => ref.read(entradasRepoProvider).atualizar(atualizada),
      mensagemErro: l10n.entradaErroPausar,
    );
    // A renda entra no cálculo do painel: invalidar só a lista deixaria o
    // gráfico e a checklist mostrando a renda antiga.
    if (ok && context.mounted) aposMudancaAmpla(ref);
  }

  Future<void> _abrirForm(BuildContext context, {Entrada? entrada}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _EntradaForm(entrada: entrada),
    );
  }
}

/// Resumo do total de renda do mês — mesma linguagem visual do card "Pago
/// este mês" da aba Contas, para dar consistência entre as telas.
class _CardTotal extends StatelessWidget {
  const _CardTotal({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppTheme.spaceLg, AppTheme.spaceSm, AppTheme.spaceLg, AppTheme.spaceSm),
      child: HighlightCard(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Row(
          children: [
            Icon(Icons.payments_outlined, size: 20, color: scheme.primary),
            const SizedBox(width: AppTheme.spaceSm),
            Text(AppLocalizations.of(context).rendasTotalDoMes,
                style: context.texts.labelMedium
                    ?.copyWith(color: scheme.onSurfaceVariant)),
            const Spacer(),
            Text(brl(total),
                style: context.texts.titleLarge
                    ?.copyWith(color: scheme.primary)),
          ],
        ),
      ),
    );
  }
}

class _EntradaForm extends ConsumerStatefulWidget {
  const _EntradaForm({this.entrada});

  final Entrada? entrada;

  @override
  ConsumerState<_EntradaForm> createState() => _EntradaFormState();
}

class _EntradaFormState extends ConsumerState<_EntradaForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _valor;
  late final TextEditingController _dia;
  late TipoEntrada _tipo;
  bool _salvando = false;

  bool get _edicao => widget.entrada != null;

  @override
  void initState() {
    super.initState();
    final e = widget.entrada;
    _nome = TextEditingController(text: e?.nome ?? '');
    _valor = TextEditingController(
        text: e == null ? '' : moedaEdit(e.valorLiquido));
    _dia = TextEditingController(text: (e?.diaRecebimento ?? 5).toString());
    _tipo = e?.tipo ?? TipoEntrada.recorrente;
  }

  @override
  void dispose() {
    _nome.dispose();
    _valor.dispose();
    _dia.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final repo = ref.read(entradasRepoProvider);
    // Entrada pontual nova nasce no mês CORRENTE, não no mês navegado nas
    // abas: senão registrar uma renda enquanto se olha março criaria uma
    // entrada num mês fechado (RN-05). Ao editar, o mês original é preservado.
    final mes = mesCorrente();
    final recorrente = _tipo == TipoEntrada.recorrente;
    final entrada = Entrada(
      id: widget.entrada?.id ?? 0,
      nome: _nome.text.trim(),
      valorLiquido: parseMoeda(_valor.text),
      tipo: _tipo,
      diaRecebimento: recorrente ? int.tryParse(_dia.text) : null,
      mesReferencia: recorrente ? null : (widget.entrada?.mesReferencia ?? mes),
      // A vigência da pausa é preservada: editar nome ou valor não pode
      // despausar. Quem altera a pausa é o botão da lista, que sabe o mês.
      pausadaDesde: widget.entrada?.pausadaDesde,
      retomadaEm: widget.entrada?.retomadaEm,
    );

    final ok = await executarComFeedback(
      context,
      () => _edicao ? repo.atualizar(entrada) : repo.criar(entrada),
      mensagemErro: AppLocalizations.of(context).rendaErroSalvar,
    );
    _concluir(ok);
  }

  Future<void> _excluir() async {
    final l10n = AppLocalizations.of(context);
    // Confirmação como em conta e cartão: a exclusão é imediata e sem desfazer,
    // e o ícone de lixeira fica no cabeçalho da folha, fácil de tocar sem querer.
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.rendaExcluirTitulo),
        content: Text(l10n.rendaExcluirTexto(widget.entrada!.nome)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.acaoCancelar)),
          FilledButton.tonal(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.acaoExcluir)),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;

    setState(() => _salvando = true);
    final ok = await executarComFeedback(
      context,
      () => ref.read(entradasRepoProvider).excluir(widget.entrada!.id),
      mensagemErro: l10n.rendaErroExcluir,
    );
    _concluir(ok);
  }

  /// Fim comum de salvar/excluir: destrava o botão e, só quando a escrita deu
  /// certo, recarrega as leituras afetadas e fecha a folha.
  void _concluir(bool ok) {
    if (!mounted) return;
    setState(() => _salvando = false);
    if (!ok) return;
    ref.invalidate(entradasProvider);
    ref.invalidate(entradasDoMesProvider);
    ref.invalidate(panoramaMesProvider);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final insets = MediaQuery.viewInsetsOf(context).bottom;
    final mes = ref.watch(mesSelecionadoProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + insets),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SheetHeader(
              titulo: _edicao ? l10n.rendaEditar : l10n.rendaNova,
              onExcluir: _edicao ? (_salvando ? null : _excluir) : null,
            ),
            const SizedBox(height: AppTheme.spaceXs),
            TextFormField(
              controller: _nome,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                  labelText: l10n.campoNome, hintText: l10n.rendaNomeHint),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.validacaoInformeNome
                  : null,
            ),
            const SizedBox(height: 12),
            CampoMoeda(
              controller: _valor,
              labelText: l10n.campoValorLiquido,
              obrigatorioPositivo: true,
            ),
            const SizedBox(height: 16),
            SegmentedButton<TipoEntrada>(
              segments: [
                ButtonSegment(
                    value: TipoEntrada.recorrente,
                    label: Text(l10n.rendaTipoRecorrente)),
                ButtonSegment(
                    value: TipoEntrada.pontual,
                    label: Text(l10n.rendaTipoPontual)),
              ],
              selected: {_tipo},
              onSelectionChanged: (s) => setState(() => _tipo = s.first),
            ),
            const SizedBox(height: 12),
            if (_tipo == TipoEntrada.recorrente)
              TextFormField(
                controller: _dia,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: l10n.rendaDiaRecebimento, errorMaxLines: 2),
                validator: (v) {
                  final d = int.tryParse(v ?? '');
                  return (d == null || d < 1 || d > 31)
                      ? l10n.validacaoDia
                      : null;
                },
              )
            else
              Text(l10n.rendaEntraApenasEm(mesAno(mes, l10n.localeName)),
                  style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 20),
            BotaoSalvar(
              salvando: _salvando,
              onPressed: _salvar,
              rotulo: _edicao ? l10n.acaoSalvar : l10n.acaoAdicionar,
            ),
          ],
        ),
      ),
    );
  }
}
