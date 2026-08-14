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
import '../../l10n/app_localizations.dart';
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
    }, mensagemErro: AppLocalizations.of(context).faturaErroSalvar);
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
    }, mensagemErro: AppLocalizations.of(context).faturaErroSalvar);
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
    final l10n = AppLocalizations.of(context);
    final insets = MediaQuery.viewInsetsOf(context).bottom;
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
              titulo: l10n.faturaTitulo(widget.item.cartao.nome),
              subtitulo: mesAno(mes, l10n.localeName),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            CampoMoeda(
              controller: _total,
              labelText: l10n.faturaValorTotal,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppTheme.spaceXl),
            Text(l10n.faturaComoDividir, style: textTheme.titleMedium),
            const SizedBox(height: AppTheme.spaceXs),
            Text(
              l10n.faturaComoDividirTexto,
              style: textTheme.bodySmall
                  ?.copyWith(color: context.colors.onSurfaceVariant),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            for (final g in Grupo.values)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceXs),
                child: CampoMoeda(
                  controller: _grupos[g]!,
                  labelText: g.rotulo(context),
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
              rotulo: l10n.faturaSalvar,
            ),
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: _salvando ? null : _naoUsei,
              icon: const Icon(Icons.block_flipped, size: 18),
              label: Text(l10n.faturaNaoUsei),
            ),
          ],
        ),
      ),
    );
  }

  Widget _feedback(ValidacaoRateio validacao, TextTheme textTheme) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final falta = validacao.faltaAlocar;
    if (_totalValor <= 0) {
      return Text(l10n.faturaInformeTotal,
          style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant));
    }
    if (validacao.valido) {
      return Row(
        children: [
          Icon(Icons.check_circle_outline, color: scheme.primary),
          const SizedBox(width: AppTheme.spaceSm),
          Text(l10n.faturaTudoAlocado, style: textTheme.bodyMedium),
        ],
      );
    }
    // Feedback neutro (não é um erro nem um julgamento sobre o gasto): apenas
    // indica que a divisão ainda não fecha com o valor total.
    final texto = falta > 0
        ? l10n.faturaFaltaAlocar(brl(falta))
        : l10n.faturaAlocouAMais(brl(-falta));
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
