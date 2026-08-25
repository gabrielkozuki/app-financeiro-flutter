import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

/// Pequenos blocos de UI reaproveitados entre as telas para manter a
/// identidade visual coesa (cabeçalhos de folha, rótulos de seção, estados
/// vazios e o avatar circular de grupo). Puramente de apresentação.

/// Cabeçalho padrão das folhas (bottom sheets) de formulário: título grande,
/// subtítulo opcional e uma ação opcional (normalmente excluir) alinhada à
/// direita.
class SheetHeader extends StatelessWidget {
  const SheetHeader({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.onExcluir,
  });

  final String titulo;
  final String? subtitulo;
  final VoidCallback? onExcluir;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: context.texts.titleLarge),
                if (subtitulo != null)
                  Padding(
                    // 2px colava o subtítulo no título. Vale para todas as
                    // folhas, não só a de fatura.
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(subtitulo!,
                        style: context.texts.bodyMedium
                            ?.copyWith(color: context.colors.onSurfaceVariant)),
                  ),
              ],
            ),
          ),
          if (onExcluir != null)
            IconButton(
              onPressed: onExcluir,
              icon: const Icon(Icons.delete_outline),
              tooltip: AppLocalizations.of(context).acaoExcluir,
              color: context.colors.error,
            ),
        ],
      ),
    );
  }
}

/// Rótulo de seção em versalete (ex.: "COMO ESTÁ DIVIDIDO"), usado para
/// agrupar conteúdo em listas longas.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppTheme.spaceLg, AppTheme.spaceLg, AppTheme.spaceLg, AppTheme.spaceXs),
      child: Text(
        texto.toUpperCase(),
        style: context.texts.labelMedium
            ?.copyWith(color: context.colors.onSurfaceVariant),
      ),
    );
  }
}

/// Estado vazio padrão: ícone em um círculo suave, título e descrição
/// centralizados. Usado sempre que uma lista não tem nada para mostrar.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icone,
    required this.titulo,
    this.descricao,
  });

  final IconData icone;
  final String titulo;
  final String? descricao;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceXxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                // Mesmo tingimento translúcido de `primary` usado no
                // `GroupAvatar` e nos cards de destaque — mantém o ícone com
                // um tom verde-petróleo suave em vez de um círculo apagado.
                color: scheme.primary.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(icone, size: 40, color: scheme.primary),
            ),
            const SizedBox(height: AppTheme.spaceLg),
            Text(titulo,
                style: context.texts.titleMedium,
                textAlign: TextAlign.center),
            if (descricao != null) ...[
              const SizedBox(height: AppTheme.spaceSm),
              Text(descricao!,
                  style: context.texts.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                  textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}

/// Estado de erro padrão — irmão do [EmptyState], para quando uma leitura
/// falha. Fala a linguagem do usuário (a exceção vai para o log, nunca para a
/// tela) e sempre oferece uma saída: "Tentar novamente" refaz a leitura,
/// normalmente invalidando o provider correspondente.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.onTentarNovamente,
    this.titulo,
  });

  final VoidCallback onTentarNovamente;
  final String? titulo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceXxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: scheme.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.cloud_off_rounded, size: 40, color: scheme.error),
            ),
            const SizedBox(height: AppTheme.spaceLg),
            Text(titulo ?? l10n.erroTituloPadrao,
                style: context.texts.titleMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              l10n.erroDescricaoPadrao,
              style: context.texts.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceLg),
            FilledButton.tonalIcon(
              onPressed: onTentarNovamente,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.acaoTentarNovamente),
            ),
          ],
        ),
      ),
    );
  }
}

/// Monta o [ErrorState] do ramo `error:` de um `AsyncValue`, registrando a
/// exceção no log (`debugPrint`) em vez de jogá-la na tela. [contexto] é só
/// para o log identificar de qual leitura veio a falha.
Widget erroAsync(
  Object erro,
  StackTrace? stack, {
  required String contexto,
  required VoidCallback onTentarNovamente,
  String? titulo,
}) {
  debugPrint('[$contexto] falha ao carregar: $erro\n$stack');
  return ErrorState(onTentarNovamente: onTentarNovamente, titulo: titulo);
}

/// Botão de confirmação padrão das folhas de formulário: ocupa a largura toda,
/// fica desabilitado enquanto [salvando] e troca o rótulo por um spinner do
/// tamanho do texto. Centraliza aqui a geometria do indicador, que estava
/// copiada em seis telas.
class BotaoSalvar extends StatelessWidget {
  const BotaoSalvar({
    super.key,
    required this.salvando,
    required this.onPressed,
    required this.rotulo,
  });

  final bool salvando;
  final VoidCallback? onPressed;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: salvando ? null : onPressed,
        child: salvando
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(rotulo),
      ),
    );
  }
}

/// Fundo tingido de `primary` sobre `surfaceContainerHigh`, usado nos cards e
/// indicadores de destaque (ex.: [HighlightCard], a pílula de soma dos
/// percentuais em `percentuais_page.dart`) para reforçar a identidade
/// verde-petróleo do app de forma consistente. `intensidade` controla o quanto
/// de `primary` é misturado. Deriva sempre do `ColorScheme` atual, então se
/// adapta automaticamente a claro/escuro.
Color highlightTint(BuildContext context, {double intensidade = 0.08}) {
  final scheme = context.colors;
  return Color.alphaBlend(
    scheme.primary.withValues(alpha: intensidade),
    scheme.surfaceContainerHigh,
  );
}

/// Cor de trilha (fundo) das barras de progresso dentro de um [HighlightCard]
/// — tingimento um pouco mais forte que o fundo do card, para a barra ficar
/// visível mas ainda discreta.
Color highlightTrackColor(BuildContext context) =>
    highlightTint(context, intensidade: 0.18);

/// Card de destaque para resumos financeiros no topo das telas (ex.: "Pago
/// este mês" em Contas, "Total do mês" em Rendas): fundo levemente tingido de
/// `primary` (ver [highlightTint]) e borda suave também em `primary`. Mesma
/// linguagem visual reaproveitada em toda a aplicação, evitando repetir o
/// estilo em cada tela — e funciona em claro/escuro por derivar do
/// `ColorScheme` atual.
class HighlightCard extends StatelessWidget {
  const HighlightCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    return Card(
      color: highlightTint(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.raio),
        side: BorderSide(color: scheme.primary.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppTheme.spaceXl),
        child: child,
      ),
    );
  }
}

/// Avatar circular colorido por grupo (Necessidade/Desejo/Investimento) — dá
/// identidade visual forte e consistente às linhas de conta/fatura em toda a
/// checklist e no painel.
class GroupAvatar extends StatelessWidget {
  const GroupAvatar({
    super.key,
    required this.icone,
    required this.cor,
    this.tamanho = 40,
  });

  final IconData icone;
  final Color cor;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      child: Icon(icone, color: cor, size: tamanho * 0.5),
    );
  }
}
