import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/feedback.dart';
import '../../core/format/money.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/grupo_visual.dart';
import '../../core/widgets/ui_kit.dart';
import '../../l10n/app_localizations.dart';
import '../cartao/fatura_sheet.dart';
import '../mes/mes_panorama.dart';
import '../mes/seletor_mes.dart';
import 'conta_form.dart';

/// Aba "Contas": seletor de mês, card "pago este mês" e a checklist ordenada
/// por vencimento (RF-08). O painel 50-30-20 fica na aba Gráfico (protótipo).
class ContasTab extends ConsumerWidget {
  const ContasTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mes = ref.watch(mesReferenciaProvider);
    final async = ref.watch(panoramaMesProvider(mes));
    final somenteLeitura = ref.watch(mesSomenteLeituraProvider);
    // Reabrir um mês serve para corrigir o que já existe nele, não para
    // lançar conta nova (RN-05) — por isso o FAB some nos dois casos.
    final editandoFechado = ref.watch(mesEditandoFechadoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tituloMeuMes),
        bottom: seletorMesBar(context),
      ),
      floatingActionButton: (somenteLeitura || editandoFechado)
          ? null
          : FloatingActionButton.extended(
              onPressed: () => abrirNovaConta(context),
              icon: const Icon(Icons.add),
              label: Text(l10n.contasNovaConta),
            ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppTheme.maxLargura),
            child: async.when(
              // Recarregar (após marcar uma conta, por exemplo) mantém a lista
              // na tela em vez de voltar ao spinner — sem piscar.
              skipLoadingOnReload: true,
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, s) => erroAsync(
                e,
                s,
                contexto: 'ContasTab',
                titulo: l10n.erroCarregarMes,
                onTentarNovamente: () => ref.invalidate(panoramaMesProvider),
              ),
              data: (panorama) => _Conteudo(panorama: panorama),
            ),
          ),
        ),
      ),
    );
  }
}

class _Conteudo extends ConsumerWidget {
  const _Conteudo({required this.panorama});

  final PanoramaMes panorama;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (panorama.itens.isEmpty && panorama.faturas.isEmpty) {
      return const _Vazio();
    }

    final somenteLeitura = ref.watch(mesSomenteLeituraProvider);
    final editandoFechado = ref.watch(mesEditandoFechadoProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
      children: [
        if (somenteLeitura) const _BannerMesFechado(),
        if (editandoFechado) const _BannerEditandoFechado(),
        _CardPago(pago: panorama.pago, total: panorama.total),
        _cabecalho(context, panorama.quantidadePagas, panorama.totalLinhas),
        const SizedBox(height: AppTheme.spaceSm),
        for (final item in panorama.itens) _ContaTile(item: item),
        for (final fatura in panorama.faturas) _FaturaTile(item: fatura),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _cabecalho(BuildContext context, int pagas, int total) {
    final l10n = AppLocalizations.of(context);
    final textTheme = context.texts;
    final scheme = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppTheme.spaceXl, AppTheme.spaceSm, AppTheme.spaceXl, AppTheme.spaceXs),
      child: Row(
        children: [
          Text(l10n.contasSecaoMensais, style: textTheme.titleMedium),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceSm, vertical: 3),
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text('$pagas/$total',
                style: textTheme.labelLarge?.copyWith(
                  color: scheme.onSecondaryContainer,
                )),
          ),
        ],
      ),
    );
  }
}

class _Vazio extends ConsumerWidget {
  const _Vazio();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final somenteLeitura = ref.watch(mesSomenteLeituraProvider);
    return EmptyState(
      icone: somenteLeitura ? Icons.history : Icons.checklist_rounded,
      titulo: somenteLeitura
          ? l10n.contasVazioFechadoTitulo
          : l10n.contasVazioTitulo,
      descricao: somenteLeitura
          ? l10n.contasVazioFechadoDescricao
          : l10n.contasVazioDescricao,
    );
  }
}

class _BannerMesFechado extends ConsumerWidget {
  const _BannerMesFechado();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppTheme.spaceLg, AppTheme.spaceSm, AppTheme.spaceLg, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
            AppTheme.spaceMd, AppTheme.spaceMd, AppTheme.spaceSm, AppTheme.spaceXs),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppTheme.raio),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_clock_outlined,
                    size: 18, color: scheme.onSurfaceVariant),
                const SizedBox(width: AppTheme.spaceSm),
                Expanded(
                  child: Text(
                    l10n.contasMesFechadoAviso,
                    style: context.texts.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _confirmarReabrir(context, ref),
                icon: const Icon(Icons.lock_open_outlined, size: 18),
                label: Text(l10n.contasReabrirMes),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmarReabrir(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.contasReabrirTitulo),
        content: Text(l10n.contasReabrirTexto),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.acaoCancelar)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.contasReabrirAcao)),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await reabrirMesSelecionado(context, ref);
    }
  }
}

class _BannerEditandoFechado extends ConsumerWidget {
  const _BannerEditandoFechado();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppTheme.spaceLg, AppTheme.spaceSm, AppTheme.spaceLg, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
            AppTheme.spaceMd, AppTheme.spaceMd, AppTheme.spaceSm, AppTheme.spaceXs),
        decoration: BoxDecoration(
          color: scheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(AppTheme.raio),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_open_outlined,
                    size: 18, color: scheme.onTertiaryContainer),
                const SizedBox(width: AppTheme.spaceSm),
                Expanded(
                  child: Text(
                    l10n.contasEditandoFechadoAviso,
                    style: context.texts.bodySmall
                        ?.copyWith(color: scheme.onTertiaryContainer),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => concluirEdicaoMesSelecionado(context, ref),
                icon: const Icon(Icons.check, size: 18),
                label: Text(l10n.contasConcluirEdicao),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardPago extends StatelessWidget {
  const _CardPago({required this.pago, required this.total});

  final double pago;
  final double total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = context.texts;
    final scheme = context.colors;
    final fracao = total == 0 ? 0.0 : (pago / total).clamp(0.0, 1.0);
    final percentual = (fracao * 100).round();

    // `HighlightCard` centraliza no tema/ui_kit o mesmo fundo tingido de
    // verde-petróleo usado no card "Total do mês" (Rendas) — se adapta ao
    // tema claro/escuro por derivar do `ColorScheme` atual. O destaque de
    // marca fica no ícone, no valor pago e na barra de progresso, todos em
    // `scheme.primary`, com texto de apoio em `onSurfaceVariant` para manter
    // contraste garantido pelo Material 3 em qualquer tema.
    return Semantics(
      label: l10n.contasPagoSemantica(brl(pago), brl(total), percentual),
      // Sem isso, o leitor de tela lê o rótulo-resumo e, em seguida, os
      // textos internos (valor, "de X · Y%") de novo — mesma duplicidade
      // corrigida na rosca de Direcionamento.
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppTheme.spaceLg, AppTheme.spaceSm, AppTheme.spaceLg, AppTheme.spaceSm),
        child: HighlightCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.task_alt_rounded,
                        size: 16, color: scheme.primary),
                  ),
                  const SizedBox(width: AppTheme.spaceSm),
                  Text(l10n.contasPagoEsteMes,
                      style: textTheme.labelMedium
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: AppTheme.spaceSm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  // Expanded + ellipsis: o valor pode ser grande; o texto de
                  // apoio ("de X · Y%") tem largura intrínseca e sempre cabe,
                  // evitando estouro horizontal do Row.
                  Expanded(
                    child: Text(brl(pago),
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.headlineMedium?.copyWith(
                          color: scheme.primary,
                        )),
                  ),
                  const SizedBox(width: AppTheme.spaceSm),
                  Text(l10n.contasPagoDeTotal(brl(total), percentual),
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      )),
                ],
              ),
              const SizedBox(height: AppTheme.spaceLg),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: fracao,
                  minHeight: 10,
                  backgroundColor: highlightTrackColor(context),
                  valueColor: AlwaysStoppedAnimation(scheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card de linha da checklist.
///
/// A faixa colorida à esquerda foi removida em 25/08/2026: o grupo já aparece
/// no pontinho + rótulo do subtítulo, e a faixa duplicava esse sinal enquanto
/// apertava o conteúdo contra a borda. O que separa uma linha da outra passa a
/// ser contorno e espaçamento, não uma marca colorida.
///
/// Reaproveitado por [_ContaTile] e [_FaturaTile] para manter o mesmo padrão.
class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.raio),
        side: BorderSide(color: context.colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceXs),
        child: child,
      ),
    );
  }
}

class _ContaTile extends ConsumerWidget {
  const _ContaTile({required this.item});

  final ItemChecklist item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = context.texts;
    final onSurfaceVariant = context.colors.onSurfaceVariant;
    final conta = item.conta;
    final ocorrencia = item.ocorrencia;
    final paga = ocorrencia.paga;

    final somenteLeitura = ref.watch(mesSomenteLeituraProvider);
    final editandoFechado = ref.watch(mesEditandoFechadoProvider);

    Future<void> alternar(bool? v) async {
      final repo = ref.read(contasRepoProvider);
      // Sem otimismo: o checkbox só muda quando o banco confirma. Se falhar,
      // ele volta ao estado anterior e o SnackBar explica o porquê.
      final ok = await executarComFeedback(
        context,
        () => (v ?? false)
            ? repo.marcarPaga(ocorrencia.id)
            : repo.desmarcar(ocorrencia.id),
        mensagemErro: l10n.contaErroMarcar(conta.nome),
      );
      // `ref` só é utilizável enquanto o tile estiver montado.
      if (ok && context.mounted) ref.invalidate(panoramaMesProvider);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceLg, vertical: 5),
      child: Semantics(
        label: l10n.contaSemantica(
            conta.nome,
            conta.grupo.rotulo(context),
            brl(ocorrencia.valorEfetivo),
            paga ? l10n.estadoPaga : l10n.estadoPendente),
        child: _ChecklistCard(
          child: ListTile(
            onTap: somenteLeitura
                ? null
                : () => abrirEditarConta(context,
                    conta: conta,
                    ocorrencia: ocorrencia,
                    apenasOcorrencia: editandoFechado),
            // O checkbox é a única ação de destaque à esquerda — o grupo vira
            // um sinal discreto (faixa colorida do card + pontinho/rótulo no
            // subtítulo), sem competir por atenção com o "pago". Ele não
            // herda o rótulo do Semantics externo (é um nó interativo próprio
            // para o leitor de tela), por isso recebe o seu.
            leading: Transform.scale(
              scale: 1.3,
              child: Checkbox(
                  value: paga,
                  onChanged: somenteLeitura ? null : alternar,
                  semanticLabel: l10n.contaMarcarPaga(conta.nome)),
            ),
            // O `Expanded` preenche até a borda e corta com reticências
            // exatamente ali, então nome longo encostava no valor. O que separa
            // é o SizedBox — diminuir a fonte sozinho só adiaria o encontro.
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    conta.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      decoration: paga ? TextDecoration.lineThrough : null,
                      color: paga ? onSurfaceVariant : null,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spaceSm),
                Text(brl(ocorrencia.valorEfetivo),
                    style: textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: conta.grupo.cor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceXs + 2),
                  Expanded(
                    child: Text(
                      ocorrencia.parcelaAtual != null
                          ? l10n.contaSubtituloParcela(
                              conta.grupo.rotulo(context),
                              conta.diaVencimento,
                              ocorrencia.parcelaAtual!,
                              conta.totalParcelas ?? 0)
                          : l10n.contaSubtitulo(
                              conta.grupo.rotulo(context), conta.diaVencimento),
                      style:
                          textTheme.bodyMedium?.copyWith(color: onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FaturaTile extends ConsumerWidget {
  const _FaturaTile({required this.item});

  final ItemFatura item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = context.texts;
    final scheme = context.colors;
    final onSurfaceVariant = scheme.onSurfaceVariant;
    final fatura = item.fatura;
    final paga = fatura.paga;
    final temValor = fatura.valorTotal != null;
    final somenteLeitura = ref.watch(mesSomenteLeituraProvider);

    Future<void> alternar(bool? v) async {
      if (!temValor) {
        // Sem valor informado não dá para marcar: abre o detalhe.
        await abrirFatura(context, item);
        return;
      }
      final repo = ref.read(cartoesRepoProvider);
      final ok = await executarComFeedback(
        context,
        () => (v ?? false)
            ? repo.marcarFaturaPaga(fatura.id)
            : repo.desmarcarFatura(fatura.id),
        mensagemErro: l10n.faturaErroMarcar(item.cartao.nome),
      );
      // `ref` só é utilizável enquanto o tile estiver montado.
      if (ok && context.mounted) ref.invalidate(panoramaMesProvider);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceLg, vertical: 5),
      child: _ChecklistCard(
        child: ListTile(
          onTap: somenteLeitura ? null : () => abrirFatura(context, item),
          // O tile de fatura não tem Semantics externo (diferente do de
          // conta), então o checkbox precisa do próprio rótulo com o nome
          // do cartão para o leitor de tela.
          leading: Transform.scale(
            scale: 1.3,
            child: Checkbox(
                value: paga,
                onChanged: somenteLeitura ? null : alternar,
                semanticLabel: l10n.faturaMarcarPaga(item.cartao.nome)),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.faturaTitulo(item.cartao.nome),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.bodyMedium?.copyWith(
                    decoration: paga ? TextDecoration.lineThrough : null,
                    color: paga ? onSurfaceVariant : null,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spaceSm),
              Text(
                temValor ? brl(item.valorEfetivo) : l10n.faturaInformar,
                style: context.texts.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: temValor ? null : scheme.primary,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(Icons.credit_card, size: 14, color: onSurfaceVariant),
                const SizedBox(width: AppTheme.spaceXs + 2),
                Expanded(
                  child: Text(
                    item.rateios.isEmpty && temValor
                        ? l10n.faturaSubtituloRatear(item.cartao.diaVencimento)
                        : l10n.faturaSubtitulo(item.cartao.diaVencimento),
                    style:
                        textTheme.bodyMedium?.copyWith(color: onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
