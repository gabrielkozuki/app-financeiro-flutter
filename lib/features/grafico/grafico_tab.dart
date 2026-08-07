import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/money.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/grupo_visual.dart';
import '../../core/widgets/ui_kit.dart';
import '../../domain/usecases/calcular_metodologia.dart';
import '../mes/mes_panorama.dart';
import '../mes/seletor_mes.dart';

/// Aba "Gráfico" (Direcionamento): rosca 50-30-20 com o total no centro e as
/// linhas por grupo (Necessidade/Desejo/Investimento/Livre) com % e sinalização
/// neutra "meta X% · acima/abaixo" (RF-12..14).
class GraficoTab extends ConsumerWidget {
  const GraficoTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mes = ref.watch(mesReferenciaProvider);
    final async = ref.watch(panoramaMesProvider(mes));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Direcionamento'),
        // Altura calculada a partir do textScaler do usuário (RNF-05): 48dp
        // fixos cortavam o rótulo do mês em fontes grandes. Ver SeletorMesBar.
        bottom: SeletorMesBar(
          preferredSize:
              Size.fromHeight(MediaQuery.textScalerOf(context).scale(48)),
        ),
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
                titulo: 'Não conseguimos carregar este mês',
                onTentarNovamente: () => ref.invalidate(panoramaMesProvider),
              ),
              data: (panorama) {
              // Mês fechado sem nada registrado: estado neutro, sem projetar
              // a renda recorrente atual sobre um período que não a teve.
              final somenteLeitura = ref.watch(mesSomenteLeituraProvider);
              final semRegistros =
                  panorama.itens.isEmpty && panorama.faturas.isEmpty;
              if (somenteLeitura && semRegistros) {
                return const EmptyState(
                  icone: Icons.history,
                  titulo: 'Sem registros neste mês',
                  descricao: 'Este mês faz parte do histórico e não teve '
                      'contas nem rendas registradas para calcular o '
                      'direcionamento.',
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
    if (metodologia.renda <= 0) {
      return const EmptyState(
        icone: Icons.donut_large_outlined,
        titulo: 'Sem renda cadastrada neste mês',
        descricao: 'Cadastre sua renda em Configurações → Rendas para ver o '
            'direcionamento do seu dinheiro.',
      );
    }
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
      children: [
        const SizedBox(height: AppTheme.spaceSm),
        _Rosca(metodologia: metodologia),
        const SizedBox(height: AppTheme.spaceXl),
        const SectionLabel('Como está dividido'),
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

    return Semantics(
      label: 'Renda do mês: ${brl(metodologia.renda)}, dividida entre '
          '${[for (final i in metodologia.itens) i.grupo.rotulo].join(", ")} '
          'e Livre',
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
                Text('Renda do mês',
                    style: context.texts.labelMedium
                        ?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(
                  brl(metodologia.renda),
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
    final textTheme = context.texts;
    final scheme = context.colors;
    final situacaoTexto = switch (item.situacao) {
      Situacao.acima => 'acima da meta',
      Situacao.abaixo => 'abaixo da meta',
      Situacao.dentro => 'na meta',
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
                    Text(item.grupo.rotulo, style: textTheme.titleMedium),
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
                      Text('meta ${item.metaPercentual.round()}% · $situacaoTexto',
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
                Text('Livre', style: textTheme.titleMedium),
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
