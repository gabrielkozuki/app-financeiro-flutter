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
import '../../domain/entities/conta.dart';
import '../../domain/entities/enums.dart';
import '../../domain/usecases/gerar_parcelas.dart';
import '../mes/mes_panorama.dart';

/// Abre o formulário de nova conta como folha inferior (tela sobreposta, sem
/// virar um novo menu).
Future<void> abrirNovaConta(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _ContaForm(),
  );
}

/// Abre o formulário para editar/excluir uma conta existente e, se estiver paga,
/// ajustar o valor efetivamente pago (RF-09/RN-04).
///
/// Em [apenasOcorrencia] (mês fechado reaberto), a edição fica restrita a ESTE
/// mês: só valor e valor pago da ocorrência; o modelo recorrente (nome, grupo,
/// recorrência) não é tocado, garantindo que a correção não afete outros meses.
Future<void> abrirEditarConta(
  BuildContext context, {
  required Conta conta,
  required OcorrenciaConta ocorrencia,
  bool apenasOcorrencia = false,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _ContaForm(
      conta: conta,
      ocorrencia: ocorrencia,
      apenasOcorrencia: apenasOcorrencia,
    ),
  );
}

class _ContaForm extends ConsumerStatefulWidget {
  const _ContaForm({this.conta, this.ocorrencia, this.apenasOcorrencia = false});

  final Conta? conta;
  final OcorrenciaConta? ocorrencia;
  final bool apenasOcorrencia;

  @override
  ConsumerState<_ContaForm> createState() => _ContaFormState();
}

class _ContaFormState extends ConsumerState<_ContaForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _valor;
  late final TextEditingController _dia;
  late final TextEditingController _parcelas;
  late final TextEditingController _valorPago;
  late Grupo _grupo;
  late Recorrencia _recorrencia;
  bool _salvando = false;

  /// Ao editar o valor de uma conta recorrente, se ligado também atualiza o
  /// valor padrão do modelo (vale para os próximos meses). Desligado (padrão),
  /// o novo valor vale só para o mês atual (RF-05 — valor variável por mês).
  bool _aplicarProximos = false;

  bool get _edicao => widget.conta != null;
  bool get _parcelada => _recorrencia == Recorrencia.parcelada;

  @override
  void initState() {
    super.initState();
    final c = widget.conta;
    _nome = TextEditingController(text: c?.nome ?? '');
    _valor = TextEditingController(
        text: c == null
            ? ''
            : moedaEdit(widget.ocorrencia?.valorPlanejado ?? c.valorPlanejado));
    _dia = TextEditingController(text: (c?.diaVencimento ?? 5).toString());
    _parcelas =
        TextEditingController(text: (c?.totalParcelas ?? 12).toString());
    _valorPago = TextEditingController(
        text: widget.ocorrencia?.valorPago != null
            ? moedaEdit(widget.ocorrencia!.valorPago!)
            : '');
    _grupo = c?.grupo ?? Grupo.necessidade;
    _recorrencia = c?.recorrencia ?? Recorrencia.fixa;
  }

  @override
  void dispose() {
    _nome.dispose();
    _valor.dispose();
    _dia.dispose();
    _parcelas.dispose();
    _valorPago.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    final repo = ref.read(contasRepoProvider);
    final emTransacao = ref.read(emTransacaoProvider);
    final mesData = ref.read(mesSelecionadoProvider);
    final mes = ref.read(mesReferenciaProvider);
    final valor = parseMoeda(_valor.text);
    final dia = int.parse(_dia.text);

    final ok = await executarComFeedback(context, () async {
      if (_edicao) {
        // Em mês reaberto (apenasOcorrencia) NÃO tocamos no modelo recorrente —
        // só na ocorrência deste mês, para a correção não vazar a outros meses.
        if (!widget.apenasOcorrencia) {
          await repo.atualizar(widget.conta!.copyWith(
            nome: _nome.text.trim(),
            grupo: _grupo,
            // O valor padrão (próximos meses) só muda se o usuário pedir; caso
            // contrário, o novo valor vale só para a ocorrência deste mês.
            valorPlanejado:
                _aplicarProximos ? valor : widget.conta!.valorPlanejado,
            diaVencimento: dia,
          ));
          // Mudar o modelo só afeta os meses que a virada AINDA não gerou.
          // Como navegar para um mês futuro já o materializa, sem isto o
          // switch prometia "próximos meses" e entregava "os que você ainda
          // não abriu" — e em conta parcelada não fazia nada.
          if (_aplicarProximos) {
            await repo.atualizarValorOcorrenciasAPartirDe(
                widget.conta!.id, mes, valor);
          }
        }
        // Campo de valor pago apagado numa ocorrência paga = "voltar a usar o
        // planejado". Sem o flag isso seria lido como "não informado" e o valor
        // errado continuaria valendo no mês (RN-04).
        final paga = widget.ocorrencia!.paga;
        final textoPago = _valorPago.text.trim();
        await repo.atualizarOcorrencia(
          widget.ocorrencia!.id,
          valorPlanejado: valor,
          valorPago:
              paga && textoPago.isNotEmpty ? parseMoeda(textoPago) : null,
          limparValorPago: paga && textoPago.isEmpty,
        );
      } else if (_parcelada) {
        final total = int.parse(_parcelas.text);
        // Conta + N ocorrências como unidade: uma falha no meio de 60 parcelas
        // deixaria uma conta com totalParcelas=60 e parte das parcelas —
        // estado que nenhuma tela corrige e que a virada não reconstrói.
        await emTransacao(() async {
          final id = await repo.criar(Conta(
            id: 0,
            nome: _nome.text.trim(),
            grupo: _grupo,
            valorPlanejado: valor,
            diaVencimento: dia,
            recorrencia: Recorrencia.parcelada,
            totalParcelas: total,
          ));
          final parcelas = const GerarParcelas()(
            anoInicial: mesData.year,
            mesInicial: mesData.month,
            valorParcela: valor,
            totalParcelas: total,
          );
          for (final p in parcelas) {
            await repo.inserirOcorrencia(
              contaId: id,
              mesReferencia: p.mesReferencia,
              valorPlanejado: p.valorPlanejado,
              parcelaAtual: p.parcelaAtual,
            );
          }
        });
      } else {
        final id = await repo.criar(Conta(
          id: 0,
          nome: _nome.text.trim(),
          grupo: _grupo,
          valorPlanejado: valor,
          diaVencimento: dia,
          recorrencia: _recorrencia,
        ));
        await repo.inserirOcorrencia(
            contaId: id, mesReferencia: mes, valorPlanejado: valor);
      }
    }, mensagemErro: 'Não foi possível salvar esta conta.');

    if (!mounted) return;
    setState(() => _salvando = false);
    if (!ok) return;
    ref.invalidate(panoramaMesProvider);
    Navigator.of(context).pop();
  }

  Future<void> _excluir() async {
    final conta = widget.conta!;
    final repo = ref.read(contasRepoProvider);

    // Chamada depois de um diálogo de confirmação: a folha pode já não estar
    // montada se o usuário fechou tudo enquanto o diálogo estava aberto.
    Future<void> aplicar(Future<void> Function() acao) async {
      if (!mounted) return;
      setState(() => _salvando = true);
      final ok = await executarComFeedback(context, acao,
          mensagemErro: 'Não foi possível excluir esta conta.');
      if (!mounted) return;
      setState(() => _salvando = false);
      if (!ok) return;
      ref.invalidate(panoramaMesProvider);
      Navigator.of(context).pop();
    }

    // Conta pontual: existe só neste mês → remove por completo (sem afetar
    // nenhum outro mês, pois não há outros).
    // Mês reaberto: edição restrita a este mês → só "remover deste mês".
    final pontual = conta.recorrencia == Recorrencia.pontual;
    if (pontual || widget.apenasOcorrencia) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Remover deste mês?'),
          content: Text(
              '"${conta.nome}" sai apenas deste mês. Nenhum outro mês é afetado.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            FilledButton.tonal(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Remover')),
          ],
        ),
      );
      if (ok != true) return;
      await aplicar(() => pontual
          ? repo.excluir(conta.id)
          : repo.removerOcorrenciaDoMes(widget.ocorrencia!.id));
      return;
    }

    // Recorrente/parcelada: duas opções, NUNCA tocando meses anteriores.
    final acao = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir conta'),
        content: const Text(
            'O que você quer excluir? Meses anteriores nunca são afetados.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, 'mes'),
              child: const Text('Só deste mês')),
          FilledButton.tonal(
              onPressed: () => Navigator.pop(ctx, 'futuras'),
              child: const Text('Deste mês em diante')),
        ],
      ),
    );
    if (acao == null) return;

    await aplicar(() async {
      switch (acao) {
        case 'mes':
          await repo.removerOcorrenciaDoMes(widget.ocorrencia!.id);
        case 'futuras':
          // Apaga as ocorrências deste mês em diante e desativa o modelo para
          // não gerar meses futuros. As ocorrências passadas permanecem.
          await repo.excluirOcorrenciasDaContaAPartirDe(
              conta.id, widget.ocorrencia!.mesReferencia);
          await repo.definirAtiva(conta.id, false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mes = ref.watch(mesSelecionadoProvider);
    final insets = MediaQuery.of(context).viewInsets.bottom;
    final ocorrencia = widget.ocorrencia;
    final mostrarValorPago = _edicao && (ocorrencia?.paga ?? false);
    final ehParcelaEdicao = _edicao && _parcelada;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, AppTheme.spaceXl + insets),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SheetHeader(
                titulo: widget.apenasOcorrencia
                    ? 'Ajustar neste mês'
                    : _edicao
                        ? (ehParcelaEdicao ? 'Editar parcela' : 'Editar conta')
                        : 'Nova conta',
                subtitulo: ehParcelaEdicao && ocorrencia?.parcelaAtual != null
                    ? 'Parcela ${ocorrencia!.parcelaAtual}/${widget.conta!.totalParcelas}'
                    : null,
                onExcluir: _edicao ? (_salvando ? null : _excluir) : null,
              ),
              const SizedBox(height: AppTheme.spaceXs),
              TextFormField(
                controller: _nome,
                readOnly: widget.apenasOcorrencia,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  hintText: 'Ex.: Aluguel',
                  helperText: widget.apenasOcorrencia
                      ? 'Nome não editável ao ajustar um mês fechado'
                      : null,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Informe um nome'
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CampoMoeda(
                      controller: _valor,
                      labelText: widget.apenasOcorrencia
                          ? 'Valor deste mês'
                          : _parcelada
                              ? 'Valor da parcela'
                              : 'Valor',
                      obrigatorioPositivo: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 110,
                    child: TextFormField(
                      controller: _dia,
                      // O vencimento vive na Conta, não na ocorrência: ao
                      // ajustar um mês fechado ele seria digitado e descartado
                      // em silêncio, então fica só de leitura.
                      readOnly: widget.apenasOcorrencia,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Vence dia',
                        helperText: widget.apenasOcorrencia
                            ? 'Não editável neste ajuste'
                            : null,
                        helperMaxLines: 2,
                        errorMaxLines: 2,
                      ),
                      validator: (v) {
                        final d = int.tryParse(v ?? '');
                        return (d == null || d < 1 || d > 31)
                            ? 'Informe um dia entre 1 e 31'
                            : null;
                      },
                    ),
                  ),
                ],
              ),
              if (mostrarValorPago) ...[
                const SizedBox(height: 12),
                CampoMoeda(
                  controller: _valorPago,
                  labelText: 'Valor pago (se diferente do planejado)',
                ),
              ],
              if (_edicao &&
                  !widget.apenasOcorrencia &&
                  _recorrencia != Recorrencia.pontual)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _aplicarProximos,
                  onChanged: (v) => setState(() => _aplicarProximos = v),
                  title: const Text('Aplicar valor aos próximos meses'),
                  subtitle: const Text(
                      'Desligado, o valor muda só neste mês'),
                ),
              if (!widget.apenasOcorrencia) ...[
                const SizedBox(height: AppTheme.spaceLg),
                Text('Grupo', style: context.texts.labelLarge),
                const SizedBox(height: AppTheme.spaceSm),
                Wrap(
                  spacing: AppTheme.spaceSm,
                  runSpacing: AppTheme.spaceSm,
                  children: [
                    for (final g in Grupo.values)
                      ChoiceChip(
                        label: Text(g.rotulo),
                        avatar: Icon(g.icone, size: 18, color: g.cor),
                        // O ícone do grupo já indica a cor/identidade; sem o
                        // checkmark padrão, ele não fica sobreposto pelo "✓".
                        showCheckmark: false,
                        selected: _grupo == g,
                        onSelected: (_) => setState(() => _grupo = g),
                      ),
                  ],
                ),
              ],
              // Recorrência só é escolhida na criação (não muda em edição).
              if (!_edicao) ...[
                const SizedBox(height: AppTheme.spaceLg),
                SegmentedButton<Recorrencia>(
                  segments: const [
                    ButtonSegment(
                        value: Recorrencia.fixa, label: Text('Fixa')),
                    ButtonSegment(
                        value: Recorrencia.pontual, label: Text('Só este mês')),
                    ButtonSegment(
                        value: Recorrencia.parcelada, label: Text('Parcelada')),
                  ],
                  selected: {_recorrencia},
                  onSelectionChanged: (s) =>
                      setState(() => _recorrencia = s.first),
                ),
                if (_parcelada) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _parcelas,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Nº de parcelas'),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      return (n == null || n < 1 || n > 120)
                          ? 'Entre 1 e 120'
                          : null;
                    },
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  switch (_recorrencia) {
                    Recorrencia.fixa =>
                      'Repete todo mês a partir de ${mesAno(mes)}.',
                    Recorrencia.pontual => 'Aparece apenas em ${mesAno(mes)}.',
                    Recorrencia.parcelada =>
                      'Gera uma parcela por mês a partir de ${mesAno(mes)}.',
                  },
                  style: context.texts.bodySmall,
                ),
              ],
              const SizedBox(height: AppTheme.spaceXl),
              BotaoSalvar(
                salvando: _salvando,
                onPressed: _salvar,
                rotulo: _edicao ? 'Salvar alterações' : 'Salvar',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
