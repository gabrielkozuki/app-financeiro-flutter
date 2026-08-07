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
    final async = ref.watch(entradasDoMesProvider);
    final mes = ref.watch(mesSelecionadoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rendas'),
        // Altura calculada a partir do textScaler do usuário (RNF-05): 48dp
        // fixos cortavam o rótulo do mês em fontes grandes. Ver SeletorMesBar.
        bottom: SeletorMesBar(
          preferredSize:
              Size.fromHeight(MediaQuery.textScalerOf(context).scale(48)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Nova entrada'),
      ),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => erroAsync(
            e,
            s,
            contexto: 'EntradasPage',
            titulo: 'Não conseguimos carregar suas rendas',
            onTentarNovamente: () => ref.invalidate(entradasDoMesProvider),
          ),
          data: (entradas) {
            final recorrentes = entradas
                .where((e) => e.tipo == TipoEntrada.recorrente)
                .toList();
            final pontuais =
                entradas.where((e) => e.tipo == TipoEntrada.pontual).toList();
            final total = entradas.fold<double>(0, (s, e) => s + e.valorLiquido);

            if (entradas.isEmpty) {
              return const EmptyState(
                icone: Icons.attach_money,
                titulo: 'Nenhuma renda neste mês',
                descricao: 'Toque em "Nova entrada" para cadastrar seu '
                    'salário ou outra entrada.',
              );
            }

            return ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                _CardTotal(total: total),
                if (recorrentes.isNotEmpty) ...[
                  const SectionLabel('Recorrentes (todo mês)'),
                  for (final e in recorrentes) _tile(context, e),
                ],
                if (pontuais.isNotEmpty) ...[
                  SectionLabel('Pontuais de ${mesAno(mes)}'),
                  for (final e in pontuais) _tile(context, e),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, Entrada e) {
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
          title: Text(e.nome),
          subtitle: Text(e.tipo == TipoEntrada.recorrente
              ? 'Recebe dia ${e.diaRecebimento ?? '-'}'
              : 'Só em ${e.mesReferencia ?? '-'}'),
          trailing: Text(brl(e.valorLiquido),
              style: const TextStyle(fontWeight: FontWeight.w600)),
          onTap: () => _abrirForm(context, entrada: e),
        ),
      ),
    );
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
            Text('TOTAL DO MÊS',
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
    final mes = ref.read(mesReferenciaProvider);
    final recorrente = _tipo == TipoEntrada.recorrente;
    final entrada = Entrada(
      id: widget.entrada?.id ?? 0,
      nome: _nome.text.trim(),
      valorLiquido: parseMoeda(_valor.text),
      tipo: _tipo,
      diaRecebimento: recorrente ? int.tryParse(_dia.text) : null,
      mesReferencia: recorrente ? null : (widget.entrada?.mesReferencia ?? mes),
    );

    final ok = await executarComFeedback(
      context,
      () => _edicao ? repo.atualizar(entrada) : repo.criar(entrada),
      mensagemErro: 'Não foi possível salvar esta entrada.',
    );
    _concluir(ok);
  }

  Future<void> _excluir() async {
    setState(() => _salvando = true);
    final ok = await executarComFeedback(
      context,
      () => ref.read(entradasRepoProvider).excluir(widget.entrada!.id),
      mensagemErro: 'Não foi possível excluir esta entrada.',
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
    final insets = MediaQuery.of(context).viewInsets.bottom;
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
              titulo: _edicao ? 'Editar entrada' : 'Nova entrada',
              onExcluir: _edicao ? (_salvando ? null : _excluir) : null,
            ),
            const SizedBox(height: AppTheme.spaceXs),
            TextFormField(
              controller: _nome,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                  labelText: 'Nome', hintText: 'Ex.: Salário'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe um nome' : null,
            ),
            const SizedBox(height: 12),
            CampoMoeda(
              controller: _valor,
              labelText: 'Valor líquido',
              obrigatorioPositivo: true,
            ),
            const SizedBox(height: 16),
            SegmentedButton<TipoEntrada>(
              segments: const [
                ButtonSegment(
                    value: TipoEntrada.recorrente, label: Text('Recorrente')),
                ButtonSegment(
                    value: TipoEntrada.pontual, label: Text('Só este mês')),
              ],
              selected: {_tipo},
              onSelectionChanged: (s) => setState(() => _tipo = s.first),
            ),
            const SizedBox(height: 12),
            if (_tipo == TipoEntrada.recorrente)
              TextFormField(
                controller: _dia,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Dia do recebimento', errorMaxLines: 2),
                validator: (v) {
                  final d = int.tryParse(v ?? '');
                  return (d == null || d < 1 || d > 31)
                      ? 'Informe um dia entre 1 e 31'
                      : null;
                },
              )
            else
              Text('Entra apenas em ${mesAno(mes)}.',
                  style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _salvando ? null : _salvar,
                child: _salvando
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_edicao ? 'Salvar' : 'Adicionar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
