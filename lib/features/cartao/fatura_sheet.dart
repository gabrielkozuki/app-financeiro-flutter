import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/feedback.dart';
import '../../core/format/dates.dart';
import '../../core/format/money.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/grupo_visual.dart';
import '../../core/widgets/campo_moeda.dart';
import '../../core/widgets/ui_kit.dart';
import '../../domain/entities/cartao.dart';
import '../../domain/entities/enums.dart';
import '../../domain/usecases/ratear_fatura.dart';
import '../mes/mes_panorama.dart';

/// Abre o detalhe da fatura: informar o valor total e subdividi-lo entre os
/// grupos (RF-22/RF-23). A conclusão só é liberada quando o rateio soma o total
/// (RN-08), com feedback amigável do quanto falta alocar.
Future<void> abrirFatura(BuildContext context, ItemFatura item) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _FaturaSheet(item: item),
  );
}

class _FaturaSheet extends ConsumerStatefulWidget {
  const _FaturaSheet({required this.item});

  final ItemFatura item;

  @override
  ConsumerState<_FaturaSheet> createState() => _FaturaSheetState();
}

class _FaturaSheetState extends ConsumerState<_FaturaSheet> {
  late final TextEditingController _total;
  final _grupos = <Grupo, TextEditingController>{};
  bool _salvando = false;

  FaturaCartao get _fatura => widget.item.fatura;

  @override
  void initState() {
    super.initState();
    _total = TextEditingController(
        text: _fatura.valorTotal != null ? moedaEdit(_fatura.valorTotal!) : '');
    final porGrupo = {
      for (final r in widget.item.rateios) r.grupo: r.valor,
    };
    for (final g in Grupo.values) {
      _grupos[g] = TextEditingController(
          text: porGrupo[g] != null ? moedaEdit(porGrupo[g]!) : '');
    }
  }

  @override
  void dispose() {
    _total.dispose();
    for (final c in _grupos.values) {
      c.dispose();
    }
    super.dispose();
  }

  double get _totalValor => parseMoeda(_total.text);

  /// Valores digitados por grupo no formato do domínio (ids irrelevantes aqui:
  /// só o par grupo/valor é usado na validação).
  List<RateioFatura> get _rateiosDigitados => [
        for (final e in _grupos.entries)
          RateioFatura(
            id: 0,
            faturaCartaoId: _fatura.id,
            grupo: e.key,
            valor: parseMoeda(e.value.text),
          ),
      ];

  /// RN-08 vem do usecase (o mesmo coberto por teste), não de uma segunda
  /// implementação com epsilon próprio aqui na tela.
  ValidacaoRateio get _validacao => const RatearFatura()
      .validar(valorTotal: _totalValor, rateios: _rateiosDigitados);

  bool get _valido => _totalValor > 0 && _validacao.valido;

  Future<void> _salvar() async {
    setState(() => _salvando = true);
    final repo = ref.read(cartoesRepoProvider);
    final ok = await executarComFeedback(context, () async {
      await repo.definirValorFatura(_fatura.id, _totalValor);
      await repo.salvarRateio(_fatura.id, {
        for (final g in Grupo.values) g: parseMoeda(_grupos[g]!.text),
      });
      // Normaliza o valor pago junto do novo total: fatura paga acompanha o
      // valor informado agora (senão a linha continuaria exibindo o pago
      // antigo — R$ 0,00 de "não usei este cartão"), e fatura pendente nunca
      // guarda valor pago (invariante de `FaturaCartao`).
      if (_fatura.paga) {
        await repo.marcarFaturaPaga(_fatura.id, valorPago: _totalValor);
      } else {
        await repo.desmarcarFatura(_fatura.id);
      }
    }, mensagemErro: 'Não foi possível salvar esta fatura.');
    _concluir(ok);
  }

  /// Cartão sem uso no mês: fatura zerada (sem rateio) e já marcada como
  /// resolvida, para não pesar no painel nem ficar pendente sem motivo.
  Future<void> _naoUsei() async {
    setState(() => _salvando = true);
    final repo = ref.read(cartoesRepoProvider);
    final ok = await executarComFeedback(context, () async {
      await repo.definirValorFatura(_fatura.id, 0);
      await repo.salvarRateio(_fatura.id, const {});
      await repo.marcarFaturaPaga(_fatura.id, valorPago: 0);
    }, mensagemErro: 'Não foi possível salvar esta fatura.');
    _concluir(ok);
  }

  /// Fim comum das duas escritas: destrava o botão e, só quando deu certo,
  /// recarrega o panorama e fecha a folha.
  void _concluir(bool ok) {
    if (!mounted) return;
    setState(() => _salvando = false);
    if (!ok) return;
    ref.invalidate(panoramaMesProvider);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets.bottom;
    final textTheme = Theme.of(context).textTheme;
    final mes = ref.watch(mesSelecionadoProvider);
    final validacao = _validacao;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, AppTheme.spaceXl + insets),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SheetHeader(
              titulo: 'Fatura ${widget.item.cartao.nome}',
              subtitulo: mesAno(mes),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            CampoMoeda(
              controller: _total,
              labelText: 'Valor total da fatura',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppTheme.spaceXl),
            Text('Como dividir entre os grupos', style: textTheme.titleMedium),
            const SizedBox(height: AppTheme.spaceXs),
            Text(
              'Divida de cabeça, sem itemizar. É o que mantém o painel fiel '
              'quando quase tudo é pago no cartão.',
              style: textTheme.bodySmall
                  ?.copyWith(color: context.colors.onSurfaceVariant),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            for (final g in Grupo.values)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceXs),
                child: CampoMoeda(
                  controller: _grupos[g]!,
                  labelText: g.rotulo,
                  prefixIcon: Icon(g.icone, color: g.cor),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            const SizedBox(height: AppTheme.spaceMd),
            _feedback(validacao, textTheme),
            const SizedBox(height: AppTheme.spaceLg),
            BotaoSalvar(
              salvando: _salvando,
              onPressed: _valido ? _salvar : null,
              rotulo: 'Salvar fatura',
            ),
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: _salvando ? null : _naoUsei,
              icon: const Icon(Icons.block_flipped, size: 18),
              label: const Text('Não usei este cartão neste mês'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _feedback(ValidacaoRateio validacao, TextTheme textTheme) {
    final scheme = Theme.of(context).colorScheme;
    final falta = validacao.faltaAlocar;
    if (_totalValor <= 0) {
      return Text('Informe o valor total da fatura.',
          style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant));
    }
    if (validacao.valido) {
      return Row(
        children: [
          Icon(Icons.check_circle_outline, color: scheme.primary),
          const SizedBox(width: AppTheme.spaceSm),
          Text('Tudo alocado!', style: textTheme.bodyMedium),
        ],
      );
    }
    // Feedback neutro (não é um erro nem um julgamento sobre o gasto): apenas
    // indica que a divisão ainda não fecha com o valor total.
    final texto = falta > 0
        ? 'Falta alocar ${brl(falta)}'
        : 'Você alocou ${brl(-falta)} a mais que o total';
    return Row(
      children: [
        Icon(Icons.info_outline, size: 18, color: scheme.onSurfaceVariant),
        const SizedBox(width: AppTheme.spaceSm),
        Expanded(
          child: Text(texto,
              style: textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant)),
        ),
      ],
    );
  }
}
