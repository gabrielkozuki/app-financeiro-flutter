import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/feedback.dart';
import '../../core/format/dates.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/grupo_visual.dart';
import '../../core/widgets/ui_kit.dart';
import '../../domain/entities/configuracao.dart';
import '../../domain/entities/enums.dart';
import '../../domain/usecases/percentuais.dart';
import '../../l10n/app_localizations.dart';
import '../mes/mes_panorama.dart';

/// Tela (sobreposta) de ajuste dos percentuais da metodologia (RF-15). A soma
/// precisa ser 100%. A alteração vale para o mês corrente e os futuros (RN-06),
/// preservando o histórico via snapshot de vigência por mês.
class PercentuaisPage extends ConsumerStatefulWidget {
  const PercentuaisPage({super.key});

  @override
  ConsumerState<PercentuaisPage> createState() => _PercentuaisPageState();
}

class _PercentuaisPageState extends ConsumerState<PercentuaisPage> {
  /// Percentuais digitados. Guardar o número (e não um `TextEditingController`)
  /// deixa o próprio `TextFormField` criar e descartar o controller dele —
  /// nada para vazar, nada para inicializar dentro do `build`.
  final _valores = <Grupo, double>{};
  bool _carregado = false;
  bool _salvando = false;

  /// Mês de vigência da alteração: sempre o mês CORRENTE, nunca o mês navegado
  /// na aba Contas (RN-06). A tela não fala de mês nenhum, então gravar com a
  /// vigência do mês visitado reescreveria meses passados — ou, se já houvesse
  /// vigência posterior, viraria um no-op silencioso.
  String get _mesVigencia => mesCorrente();

  double _valor(Grupo g) => _valores[g] ?? 0;

  /// Configuração montada com o que está digitado agora — a mesma que valida
  /// (via [ValidarPercentuais]) e que é gravada, sem regra duplicada na tela.
  ConfiguracaoMetodologia get _configDigitada => ConfiguracaoMetodologia(
        mesVigenciaInicial: _mesVigencia,
        percentualNecessidades: _valor(Grupo.necessidade),
        percentualDesejos: _valor(Grupo.desejo),
        percentualPoupanca: _valor(Grupo.investimento),
      );

  /// Preenchimento do campo: sem casas decimais quando o valor gravado é
  /// inteiro, preservando a precisão quando não é (33,3 não pode virar 33 —
  /// a soma exibida cairia para 99% e travaria o Salvar sem o usuário mexer).
  String _formatarPercentual(double v) => v == v.roundToDouble()
      ? v.round().toString()
      : v.toString().replaceAll('.', ',');

  Future<void> _salvar() async {
    final config = _configDigitada;
    if (!const ValidarPercentuais()(config)) return;

    setState(() => _salvando = true);
    final l10n = AppLocalizations.of(context);
    final ok = await executarComFeedback(
      context,
      () => ref.read(configRepoProvider).salvar(config),
      mensagemErro: l10n.percentuaisErroSalvar,
    );
    if (!mounted) return;
    setState(() => _salvando = false);
    if (!ok) return;
    ref.invalidate(panoramaMesProvider);
    // Sem isto, reabrir a tela mostraria o percentual antigo em cache.
    ref.invalidate(_configVigenteProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.percentuaisAtualizados)),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final configAsync = ref.watch(_configVigenteProvider(_mesVigencia));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.percentuaisTitulo)),
      body: SafeArea(
        child: configAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => erroAsync(
            e,
            s,
            contexto: 'PercentuaisPage',
            titulo: l10n.erroCarregarPercentuais,
            onTentarNovamente: () => ref.invalidate(_configVigenteProvider),
          ),
          data: (config) {
            if (!_carregado) {
              _valores[Grupo.necessidade] = config.percentualNecessidades;
              _valores[Grupo.desejo] = config.percentualDesejos;
              _valores[Grupo.investimento] = config.percentualPoupanca;
              _carregado = true;
            }
            final digitada = _configDigitada;
            final somaOk = const ValidarPercentuais()(digitada);
            final scheme = Theme.of(context).colorScheme;
            final textTheme = Theme.of(context).textTheme;
            return ListView(
              padding: const EdgeInsets.all(AppTheme.spaceXl),
              children: [
                Text(
                  l10n.percentuaisIntro,
                  style: textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppTheme.spaceXl),
                for (final g in Grupo.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spaceXs),
                    child: TextFormField(
                      initialValue: _formatarPercentual(_valor(g)),
                      keyboardType: TextInputType.number,
                      onChanged: (t) => setState(() =>
                          _valores[g] = double.tryParse(
                                  t.replaceAll(',', '.')) ??
                              0),
                      decoration: InputDecoration(
                        labelText: g.rotulo(context),
                        prefixIcon: Icon(g.icone, color: g.cor),
                        suffixText: '%',
                      ),
                    ),
                  ),
                const SizedBox(height: AppTheme.spaceMd),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spaceMd, vertical: AppTheme.spaceSm),
                  decoration: BoxDecoration(
                    // Mesmo tingimento de `primary` do `HighlightCard` ("Pago
                    // este mês", "Total do mês") quando a soma fecha em 100% —
                    // linguagem visual consistente entre as telas.
                    color: somaOk
                        ? highlightTint(context, intensidade: 0.14)
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppTheme.raio),
                    border: somaOk
                        ? Border.all(
                            color: scheme.primary.withValues(alpha: 0.18))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        somaOk ? Icons.check_circle_outline : Icons.info_outline,
                        size: 18,
                        color: somaOk ? scheme.primary : scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppTheme.spaceSm),
                      Text(
                        somaOk
                            ? l10n.percentuaisSomaOk(digitada.soma.round())
                            : l10n.percentuaisSomaInvalida(
                                digitada.soma.round()),
                        style: textTheme.bodyMedium?.copyWith(
                          color: somaOk ? scheme.primary : scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spaceXl),
                BotaoSalvar(
                  salvando: _salvando,
                  onPressed: somaOk ? _salvar : null,
                  rotulo: l10n.percentuaisSalvar,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Config vigente no mês, apenas para pré-preencher o formulário.
final _configVigenteProvider =
    FutureProvider.family<ConfiguracaoMetodologia, String>(
        (ref, mes) => ref.watch(configRepoProvider).vigenteEm(mes));
