import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/money.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/grupo_visual.dart';
import '../../core/widgets/ui_kit.dart';
import '../../domain/usecases/calcular_metodologia.dart';
import '../../l10n/app_localizations.dart';
import '../mes/mes_panorama.dart';
import '../mes/seletor_mes.dart';

/// Aba "Gráfico" (Direcionamento): rosca 50-30-20 com o total no centro e as
/// linhas por grupo (Necessidade/Desejo/Investimento/Livre) com % e sinalização
/// neutra "meta X% · acima/abaixo" (RF-12..14).
class GraficoTab extends ConsumerWidget {
  const GraficoTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mes = ref.watch(mesReferenciaProvider);
    final async = ref.watch(panoramaMesProvider(mes));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tituloDirecionamento),
        bottom: seletorMesBar(context),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppTheme.maxLargura),
            child: async.when(
              // Recarregar mantém a rosca na tela em vez de voltar ao spinner.
              skipLoadingOnReload: true,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => erroAsync(
                e,
                s,
                contexto: 'GraficoTab',
                titulo: l10n.erroCarregarMes,
                onTentarNovamente: () => ref.invalidate(panoramaMesProvider),
              ),
              data: (panorama) {
              // Mês fechado sem nada registrado: estado neutro, sem projetar
              // a renda recorrente atual sobre um período que não a teve.
              final somenteLeitura = ref.watch(mesSomenteLeituraProvider);
              final semRegistros =
                  panorama.itens.isEmpty && panorama.faturas.isEmpty;
              if (somenteLeitura && semRegistros) {
                return EmptyState(
                  icone: Icons.history,
                  titulo: l10n.graficoSemRegistrosTitulo,
                  descricao: l10n.graficoSemRegistrosDescricao,
                );
              }
              return _Conteudo(metodologia: panorama.metodologia);
            },
            ),
          ),
        ),
      ),
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({required this.metodologia});

  final ResultadoMetodologia metodologia;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (metodologia.renda <= 0) {
      return EmptyState(
        icone: Icons.donut_large_outlined,
        titulo: l10n.graficoSemRendaTitulo,
        descricao: l10n.graficoSemRendaDescricao,
      );
    }
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
      children: [
        const SizedBox(height: AppTheme.spaceSm),
        _Rosca(metodologia: metodologia),
        const SizedBox(height: AppTheme.spaceXl),
        SectionLabel(l10n.graficoComoEstaDividido),
        const SizedBox(height: AppTheme.spaceSm),
        for (final item in metodologia.itens) _LinhaGrupo(item: item),
        _LinhaLivre(metodologia: metodologia),
        const SizedBox(height: AppTheme.spaceXl),
      ],
    );
  }
}

class _Rosca extends StatelessWidget {
  const _Rosca({required this.metodologia});

  final ResultadoMetodologia metodologia;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.colors;
    final secoes = <PieChartSectionData>[
      for (final item in metodologia.itens)
        if (item.comprometido > 0)
          PieChartSectionData(
            value: item.comprometido,
            color: item.grupo.cor,
            radius: 26,
            showTitle: false,
          ),
      if (metodologia.livreParaGastar > 0)
        PieChartSectionData(
          value: metodologia.livreParaGastar,
          color: corLivre,
          radius: 26,
          showTitle: false,
        ),
    ];

    // Quando o mês estoura, a fatia "Livre" some e a rosca fica visualmente
    // idêntica à de um mês dentro do orçamento. O texto central passa a dizer
    // o quanto da renda foi comprometido — informativo, sem cor de erro nem
    // ícone de alerta (RF-13): o cenário do Rafael (renda variável) é o que o
    // app existe para tornar visível, não para repreender.
    final estourou = metodologia.livreParaGastar < 0 && metodologia.renda > 0;
    final percentualComprometido =
        metodologia.renda > 0 ? metodologia.totalComprometido / metodologia.renda * 100 : 0.0;

    return Semantics(
      label: estourou
          ? l10n.graficoSemanticaRoscaComprometido(
              percentualComprometido.round(),
              brl(metodologia.totalComprometido),
              brl(metodologia.renda))
          : l10n.graficoSemanticaRosca(
              brl(metodologia.renda),
              [for (final i in metodologia.itens) i.grupo.rotulo(context)]
                  .join(", ")),
      // Sem isso, o leitor de tela lê o rótulo-resumo e depois os dois Text
      // internos ("Renda do mês" / valor) de novo, em sequência.
      excludeSemantics: true,
      child: SizedBox(
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                sections: secoes.isEmpty
                    ? [
                        PieChartSectionData(
                            value: 1,
                            color: corLivre,
                            radius: 26,
                            showTitle: false)
                      ]
                    : secoes,
                centerSpaceRadius: 72,
                sectionsSpace: 2,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(estourou ? l10n.graficoComprometido : l10n.graficoRendaDoMes,
                    style: context.texts.labelMedium
                        ?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(
                  estourou
                      ? l10n.graficoPercentualDaRenda(
                          percentualComprometido.round())
                      : brl(metodologia.renda),
                  style: context.texts.headlineSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LinhaGrupo extends StatelessWidget {
  const _LinhaGrupo({required this.item});

  final ItemGrupo item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = context.texts;
    final scheme = context.colors;
    final meta = item.metaPercentual.round();
    final situacaoTexto = switch (item.situacao) {
      Situacao.acima => l10n.graficoMetaAcima(meta),
      Situacao.abaixo => l10n.graficoMetaAbaixo(meta),
      Situacao.dentro => l10n.graficoMetaDentro(meta),
    };
    final situacaoIcone = switch (item.situacao) {
      Situacao.acima => Icons.arrow_upward_rounded,
      Situacao.abaixo => Icons.arrow_downward_rounded,
      Situacao.dentro => Icons.check_rounded,
    };
    final fracao = item.metaPercentual <= 0
        ? 0.0
        : (item.percentualRealizado / item.metaPercentual).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceLg, vertical: AppTheme.spaceXs),
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.raio),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GroupAvatar(icone: item.grupo.icone, cor: item.grupo.cor),
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.grupo.rotulo(context),
                        style: textTheme.titleMedium),
                    Text(brl(item.comprometido),
                        style: textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${item.percentualRealizado.round()}%',
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(situacaoIcone,
                          size: 13, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 2),
                      Text(situacaoTexto,
                          style: textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fracao,
              minHeight: 6,
              backgroundColor: item.grupo.cor.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(item.grupo.cor),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinhaLivre extends StatelessWidget {
  const _LinhaLivre({required this.metodologia});

  final ResultadoMetodologia metodologia;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = context.texts;
    final scheme = context.colors;
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceLg, vertical: AppTheme.spaceXs),
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.raio),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          GroupAvatar(icone: Icons.savings_outlined, cor: corLivre),
          const SizedBox(width: AppTheme.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.graficoLivre, style: textTheme.titleMedium),
                Text(brl(metodologia.livreParaGastar),
                    style: textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
          Text('${metodologia.percentualLivre.round()}%',
              style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
