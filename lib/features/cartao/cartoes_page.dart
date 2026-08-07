import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/feedback.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/ui_kit.dart';
import '../../domain/entities/cartao.dart';
import '../mes/mes_panorama.dart';

/// Tela (sobreposta) de gestão de cartões de crédito (RF-21). Acessada pela aba
/// Configurações. Ao criar um cartão, já gera a fatura do mês selecionado.
class CartoesPage extends ConsumerWidget {
  const CartoesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(cartoesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cartões')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Novo cartão'),
      ),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => erroAsync(
            e,
            s,
            contexto: 'CartoesPage',
            titulo: 'Não conseguimos carregar seus cartões',
            onTentarNovamente: () => ref.invalidate(cartoesProvider),
          ),
          data: (cartoes) {
            if (cartoes.isEmpty) {
              return const EmptyState(
                icone: Icons.credit_card_outlined,
                titulo: 'Nenhum cartão cadastrado',
                descricao: 'Toque em "Novo cartão" para acompanhar as '
                    'faturas na sua checklist mensal.',
              );
            }
            return ListView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceLg, vertical: AppTheme.spaceSm),
              children: [
                for (final c in cartoes)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spaceXs),
                    child: Card(
                      child: ListTile(
                        leading: GroupAvatar(
                          icone: Icons.credit_card,
                          cor: context.colors.primary,
                          tamanho: 36,
                        ),
                        title: Text(c.nome),
                        subtitle: Text('Fatura vence dia ${c.diaVencimento}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _abrirForm(context, cartao: c),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _abrirForm(BuildContext context, {Cartao? cartao}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _CartaoForm(cartao: cartao),
    );
  }
}

class _CartaoForm extends ConsumerStatefulWidget {
  const _CartaoForm({this.cartao});

  final Cartao? cartao;

  @override
  ConsumerState<_CartaoForm> createState() => _CartaoFormState();
}

class _CartaoFormState extends ConsumerState<_CartaoForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _dia;
  bool _salvando = false;

  bool get _edicao => widget.cartao != null;

  @override
  void initState() {
    super.initState();
    _nome = TextEditingController(text: widget.cartao?.nome ?? '');
    _dia = TextEditingController(
        text: (widget.cartao?.diaVencimento ?? 10).toString());
  }

  @override
  void dispose() {
    _nome.dispose();
    _dia.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);
    final repo = ref.read(cartoesRepoProvider);
    final mes = ref.read(mesReferenciaProvider);

    final ok = await executarComFeedback(context, () async {
      if (_edicao) {
        await repo.atualizar(widget.cartao!.copyWith(
          nome: _nome.text.trim(),
          diaVencimento: int.parse(_dia.text),
        ));
      } else {
        final id = await repo.criar(Cartao(
          id: 0,
          nome: _nome.text.trim(),
          diaVencimento: int.parse(_dia.text),
        ));
        // Gera já a fatura do mês corrente para aparecer na checklist.
        final comFatura = await repo.cartaoIdsComFaturaNoMes(mes);
        if (!comFatura.contains(id)) {
          await repo.criarFatura(cartaoId: id, mesReferencia: mes);
        }
      }
    }, mensagemErro: 'Não foi possível salvar este cartão.');
    _concluir(ok);
  }

  Future<void> _excluir() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir cartão?'),
        content: Text(
            'O cartão "${widget.cartao!.nome}" e suas faturas serão removidos.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton.tonal(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Excluir')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _salvando = true);
    final excluiu = await executarComFeedback(
      context,
      () => ref.read(cartoesRepoProvider).excluir(widget.cartao!.id),
      mensagemErro: 'Não foi possível excluir este cartão.',
    );
    _concluir(excluiu);
  }

  /// Fim comum de salvar/excluir: destrava o botão e, só quando a escrita deu
  /// certo, recarrega as leituras afetadas e fecha a folha.
  void _concluir(bool ok) {
    if (!mounted) return;
    setState(() => _salvando = false);
    if (!ok) return;
    ref.invalidate(cartoesProvider);
    ref.invalidate(panoramaMesProvider);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + insets),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SheetHeader(
              titulo: _edicao ? 'Editar cartão' : 'Novo cartão',
              onExcluir: _edicao ? (_salvando ? null : _excluir) : null,
            ),
            const SizedBox(height: AppTheme.spaceXs),
            TextFormField(
              controller: _nome,
              textCapitalization: TextCapitalization.sentences,
              // Nome sem limite estourava a linha da checklist (RF-08); os
              // títulos de conta/fatura agora truncam com "…", mas evitar um
              // nome absurdamente longo já na origem é mais amigável.
              maxLength: 40,
              decoration: const InputDecoration(
                  labelText: 'Nome', hintText: 'Ex.: Nubank'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe um nome' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _dia,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Dia de vencimento'),
              validator: (v) {
                final d = int.tryParse(v ?? '');
                return (d == null || d < 1 || d > 31) ? 'Dia inválido' : null;
              },
            ),
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
