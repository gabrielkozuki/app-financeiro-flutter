import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// Nome do app. NÃO é tradução literal entre idiomas: cada locale escolhe um nome que a busca do launcher encontre (pt: 'conta'/'contas'; en: 'bill'/'bills').
  ///
  /// In pt, this message translates to:
  /// **'Conta em Dia'**
  String get appTitulo;

  /// No description provided for @abaContas.
  ///
  /// In pt, this message translates to:
  /// **'Contas'**
  String get abaContas;

  /// No description provided for @abaGrafico.
  ///
  /// In pt, this message translates to:
  /// **'Gráfico'**
  String get abaGrafico;

  /// No description provided for @abaConfiguracoes.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get abaConfiguracoes;

  /// No description provided for @tituloMeuMes.
  ///
  /// In pt, this message translates to:
  /// **'Meu mês'**
  String get tituloMeuMes;

  /// No description provided for @tituloDirecionamento.
  ///
  /// In pt, this message translates to:
  /// **'Direcionamento'**
  String get tituloDirecionamento;

  /// No description provided for @acaoCancelar.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get acaoCancelar;

  /// No description provided for @acaoSalvar.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get acaoSalvar;

  /// No description provided for @acaoExcluir.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get acaoExcluir;

  /// No description provided for @acaoAdicionar.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar'**
  String get acaoAdicionar;

  /// No description provided for @acaoTentarNovamente.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get acaoTentarNovamente;

  /// No description provided for @erroTituloPadrao.
  ///
  /// In pt, this message translates to:
  /// **'Não conseguimos carregar seus dados'**
  String get erroTituloPadrao;

  /// No description provided for @erroDescricaoPadrao.
  ///
  /// In pt, this message translates to:
  /// **'Algo deu errado ao ler os dados deste aparelho. Nada foi perdido — tente de novo.'**
  String get erroDescricaoPadrao;

  /// No description provided for @acaoContinuar.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get acaoContinuar;

  /// No description provided for @acaoRemover.
  ///
  /// In pt, this message translates to:
  /// **'Remover'**
  String get acaoRemover;

  /// No description provided for @acaoVoltar.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get acaoVoltar;

  /// No description provided for @acaoSair.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get acaoSair;

  /// No description provided for @acaoRestaurar.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar'**
  String get acaoRestaurar;

  /// No description provided for @acaoConcluir.
  ///
  /// In pt, this message translates to:
  /// **'Concluir'**
  String get acaoConcluir;

  /// No description provided for @acaoComecar.
  ///
  /// In pt, this message translates to:
  /// **'Começar'**
  String get acaoComecar;

  /// No description provided for @acaoSalvarAlteracoes.
  ///
  /// In pt, this message translates to:
  /// **'Salvar alterações'**
  String get acaoSalvarAlteracoes;

  /// No description provided for @campoNome.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get campoNome;

  /// No description provided for @campoValor.
  ///
  /// In pt, this message translates to:
  /// **'Valor'**
  String get campoValor;

  /// No description provided for @campoValorLiquido.
  ///
  /// In pt, this message translates to:
  /// **'Valor líquido'**
  String get campoValorLiquido;

  /// No description provided for @campoGrupo.
  ///
  /// In pt, this message translates to:
  /// **'Grupo'**
  String get campoGrupo;

  /// No description provided for @campoVenceDia.
  ///
  /// In pt, this message translates to:
  /// **'Vence dia'**
  String get campoVenceDia;

  /// No description provided for @validacaoInformeNome.
  ///
  /// In pt, this message translates to:
  /// **'Informe um nome'**
  String get validacaoInformeNome;

  /// No description provided for @validacaoDia.
  ///
  /// In pt, this message translates to:
  /// **'Informe um dia entre 1 e 31'**
  String get validacaoDia;

  /// No description provided for @validacaoValorInvalido.
  ///
  /// In pt, this message translates to:
  /// **'Valor inválido'**
  String get validacaoValorInvalido;

  /// No description provided for @venceDia.
  ///
  /// In pt, this message translates to:
  /// **'Vence dia {dia}'**
  String venceDia(int dia);

  /// No description provided for @grupoNecessidade.
  ///
  /// In pt, this message translates to:
  /// **'Necessidade'**
  String get grupoNecessidade;

  /// No description provided for @grupoDesejo.
  ///
  /// In pt, this message translates to:
  /// **'Desejo'**
  String get grupoDesejo;

  /// No description provided for @grupoInvestimento.
  ///
  /// In pt, this message translates to:
  /// **'Investimento'**
  String get grupoInvestimento;

  /// No description provided for @erroCarregarMes.
  ///
  /// In pt, this message translates to:
  /// **'Não conseguimos carregar este mês'**
  String get erroCarregarMes;

  /// No description provided for @erroCarregarRendas.
  ///
  /// In pt, this message translates to:
  /// **'Não conseguimos carregar suas rendas'**
  String get erroCarregarRendas;

  /// No description provided for @erroCarregarCartoes.
  ///
  /// In pt, this message translates to:
  /// **'Não conseguimos carregar seus cartões'**
  String get erroCarregarCartoes;

  /// No description provided for @erroCarregarPercentuais.
  ///
  /// In pt, this message translates to:
  /// **'Não conseguimos carregar seus percentuais'**
  String get erroCarregarPercentuais;

  /// No description provided for @erroAbrirDados.
  ///
  /// In pt, this message translates to:
  /// **'Não conseguimos abrir seus dados'**
  String get erroAbrirDados;

  /// No description provided for @mesAnterior.
  ///
  /// In pt, this message translates to:
  /// **'Mês anterior'**
  String get mesAnterior;

  /// No description provided for @mesProximo.
  ///
  /// In pt, this message translates to:
  /// **'Próximo mês'**
  String get mesProximo;

  /// No description provided for @mesEscolher.
  ///
  /// In pt, this message translates to:
  /// **'Escolher mês'**
  String get mesEscolher;

  /// No description provided for @mesAnoAnterior.
  ///
  /// In pt, this message translates to:
  /// **'Ano anterior'**
  String get mesAnoAnterior;

  /// No description provided for @mesAnoProximo.
  ///
  /// In pt, this message translates to:
  /// **'Próximo ano'**
  String get mesAnoProximo;

  /// No description provided for @mesSemanticaSeletor.
  ///
  /// In pt, this message translates to:
  /// **'Mês selecionado: {mes}. Toque para escolher outro.'**
  String mesSemanticaSeletor(String mes);

  /// No description provided for @mesSemanticaAtual.
  ///
  /// In pt, this message translates to:
  /// **'{mes}, mês atual'**
  String mesSemanticaAtual(String mes);

  /// No description provided for @mesErroReabrir.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível reabrir o mês.'**
  String get mesErroReabrir;

  /// No description provided for @mesErroConcluirEdicao.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível concluir a edição do mês.'**
  String get mesErroConcluirEdicao;

  /// No description provided for @contasNovaConta.
  ///
  /// In pt, this message translates to:
  /// **'Nova conta'**
  String get contasNovaConta;

  /// No description provided for @contasSecaoMensais.
  ///
  /// In pt, this message translates to:
  /// **'Contas mensais'**
  String get contasSecaoMensais;

  /// No description provided for @contasVazioTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma conta neste mês'**
  String get contasVazioTitulo;

  /// No description provided for @contasVazioDescricao.
  ///
  /// In pt, this message translates to:
  /// **'Toque em \"Nova conta\" para começar a organizar seu mês.'**
  String get contasVazioDescricao;

  /// No description provided for @contasVazioFechadoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma conta neste mês fechado'**
  String get contasVazioFechadoTitulo;

  /// No description provided for @contasVazioFechadoDescricao.
  ///
  /// In pt, this message translates to:
  /// **'Este mês faz parte do histórico e não teve contas registradas.'**
  String get contasVazioFechadoDescricao;

  /// No description provided for @contasMesFechadoAviso.
  ///
  /// In pt, this message translates to:
  /// **'Mês fechado — somente leitura. Este é o registro do que foi pago naquele mês.'**
  String get contasMesFechadoAviso;

  /// No description provided for @contasReabrirMes.
  ///
  /// In pt, this message translates to:
  /// **'Reabrir mês'**
  String get contasReabrirMes;

  /// No description provided for @contasReabrirTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Reabrir este mês?'**
  String get contasReabrirTitulo;

  /// No description provided for @contasReabrirTexto.
  ///
  /// In pt, this message translates to:
  /// **'O mês volta a ser editável para você corrigir contas e faturas deste mês. Nada nos outros meses é afetado. Ao concluir, um novo registro do mês é gravado.'**
  String get contasReabrirTexto;

  /// No description provided for @contasReabrirAcao.
  ///
  /// In pt, this message translates to:
  /// **'Reabrir'**
  String get contasReabrirAcao;

  /// No description provided for @contasEditandoFechadoAviso.
  ///
  /// In pt, this message translates to:
  /// **'Editando um mês fechado. As alterações valem só para este mês.'**
  String get contasEditandoFechadoAviso;

  /// No description provided for @contasConcluirEdicao.
  ///
  /// In pt, this message translates to:
  /// **'Concluir edição'**
  String get contasConcluirEdicao;

  /// No description provided for @contasPagoEsteMes.
  ///
  /// In pt, this message translates to:
  /// **'PAGO ESTE MÊS'**
  String get contasPagoEsteMes;

  /// No description provided for @contasPagoSemantica.
  ///
  /// In pt, this message translates to:
  /// **'Pago este mês: {pago} de {total}, {percentual} por cento'**
  String contasPagoSemantica(String pago, String total, int percentual);

  /// No description provided for @contasPagoDeTotal.
  ///
  /// In pt, this message translates to:
  /// **'de {total} · {percentual}%'**
  String contasPagoDeTotal(String total, int percentual);

  /// No description provided for @estadoPaga.
  ///
  /// In pt, this message translates to:
  /// **'paga'**
  String get estadoPaga;

  /// No description provided for @estadoPendente.
  ///
  /// In pt, this message translates to:
  /// **'pendente'**
  String get estadoPendente;

  /// No description provided for @contaSemantica.
  ///
  /// In pt, this message translates to:
  /// **'{nome}, {grupo}, {valor}, {estado}'**
  String contaSemantica(String nome, String grupo, String valor, String estado);

  /// No description provided for @contaMarcarPaga.
  ///
  /// In pt, this message translates to:
  /// **'Marcar {nome} como paga'**
  String contaMarcarPaga(String nome);

  /// No description provided for @contaSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'{grupo} · vencimento dia {dia}'**
  String contaSubtitulo(String grupo, int dia);

  /// No description provided for @contaSubtituloParcela.
  ///
  /// In pt, this message translates to:
  /// **'{grupo} · vencimento dia {dia} · {parcela}/{total}'**
  String contaSubtituloParcela(String grupo, int dia, int parcela, int total);

  /// No description provided for @contaErroMarcar.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível marcar \"{nome}\".'**
  String contaErroMarcar(String nome);

  /// No description provided for @faturaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Fatura {cartao}'**
  String faturaTitulo(String cartao);

  /// No description provided for @faturaMarcarPaga.
  ///
  /// In pt, this message translates to:
  /// **'Marcar a fatura {cartao} como paga'**
  String faturaMarcarPaga(String cartao);

  /// No description provided for @faturaInformar.
  ///
  /// In pt, this message translates to:
  /// **'Informar'**
  String get faturaInformar;

  /// No description provided for @faturaSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'vence dia {dia}'**
  String faturaSubtitulo(int dia);

  /// No description provided for @faturaSubtituloRatear.
  ///
  /// In pt, this message translates to:
  /// **'vence dia {dia} · toque para ratear'**
  String faturaSubtituloRatear(int dia);

  /// No description provided for @faturaErroMarcar.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível marcar a fatura {cartao}.'**
  String faturaErroMarcar(String cartao);

  /// No description provided for @faturaValorTotal.
  ///
  /// In pt, this message translates to:
  /// **'Valor total da fatura'**
  String get faturaValorTotal;

  /// No description provided for @faturaComoDividir.
  ///
  /// In pt, this message translates to:
  /// **'Como dividir entre os grupos'**
  String get faturaComoDividir;

  /// No description provided for @faturaComoDividirTexto.
  ///
  /// In pt, this message translates to:
  /// **'Divida de cabeça, sem itemizar. É o que mantém o painel fiel quando quase tudo é pago no cartão.'**
  String get faturaComoDividirTexto;

  /// No description provided for @faturaSalvar.
  ///
  /// In pt, this message translates to:
  /// **'Salvar fatura'**
  String get faturaSalvar;

  /// No description provided for @faturaNaoUsei.
  ///
  /// In pt, this message translates to:
  /// **'Não usei este cartão neste mês'**
  String get faturaNaoUsei;

  /// No description provided for @faturaInformeTotal.
  ///
  /// In pt, this message translates to:
  /// **'Informe o valor total da fatura.'**
  String get faturaInformeTotal;

  /// No description provided for @faturaTudoAlocado.
  ///
  /// In pt, this message translates to:
  /// **'Tudo alocado!'**
  String get faturaTudoAlocado;

  /// No description provided for @faturaFaltaAlocar.
  ///
  /// In pt, this message translates to:
  /// **'Falta alocar {valor}'**
  String faturaFaltaAlocar(String valor);

  /// No description provided for @faturaAlocouAMais.
  ///
  /// In pt, this message translates to:
  /// **'Você alocou {valor} a mais que o total'**
  String faturaAlocouAMais(String valor);

  /// No description provided for @faturaErroSalvar.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar esta fatura.'**
  String get faturaErroSalvar;

  /// No description provided for @contaFormTituloNova.
  ///
  /// In pt, this message translates to:
  /// **'Nova conta'**
  String get contaFormTituloNova;

  /// No description provided for @contaFormTituloEditar.
  ///
  /// In pt, this message translates to:
  /// **'Editar conta'**
  String get contaFormTituloEditar;

  /// No description provided for @contaFormTituloParcela.
  ///
  /// In pt, this message translates to:
  /// **'Editar parcela'**
  String get contaFormTituloParcela;

  /// No description provided for @contaFormTituloAjustar.
  ///
  /// In pt, this message translates to:
  /// **'Ajustar neste mês'**
  String get contaFormTituloAjustar;

  /// No description provided for @contaFormSubtituloParcela.
  ///
  /// In pt, this message translates to:
  /// **'Parcela {atual}/{total}'**
  String contaFormSubtituloParcela(int atual, int total);

  /// No description provided for @contaFormNomeHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Aluguel'**
  String get contaFormNomeHint;

  /// No description provided for @contaFormNomeBloqueado.
  ///
  /// In pt, this message translates to:
  /// **'Nome não editável ao ajustar um mês fechado'**
  String get contaFormNomeBloqueado;

  /// No description provided for @contaFormValorDoMes.
  ///
  /// In pt, this message translates to:
  /// **'Valor deste mês'**
  String get contaFormValorDoMes;

  /// No description provided for @contaFormValorParcela.
  ///
  /// In pt, this message translates to:
  /// **'Valor da parcela'**
  String get contaFormValorParcela;

  /// No description provided for @contaFormDiaBloqueado.
  ///
  /// In pt, this message translates to:
  /// **'Não editável neste ajuste'**
  String get contaFormDiaBloqueado;

  /// No description provided for @contaFormValorPago.
  ///
  /// In pt, this message translates to:
  /// **'Valor pago (se diferente do planejado)'**
  String get contaFormValorPago;

  /// No description provided for @contaFormAplicarProximos.
  ///
  /// In pt, this message translates to:
  /// **'Aplicar valor aos próximos meses'**
  String get contaFormAplicarProximos;

  /// No description provided for @contaFormAplicarProximosDescricao.
  ///
  /// In pt, this message translates to:
  /// **'Desligado, o valor muda só neste mês'**
  String get contaFormAplicarProximosDescricao;

  /// No description provided for @contaFormRecorrenciaFixa.
  ///
  /// In pt, this message translates to:
  /// **'Fixa'**
  String get contaFormRecorrenciaFixa;

  /// No description provided for @contaFormRecorrenciaPontual.
  ///
  /// In pt, this message translates to:
  /// **'Só este mês'**
  String get contaFormRecorrenciaPontual;

  /// No description provided for @contaFormRecorrenciaParcelada.
  ///
  /// In pt, this message translates to:
  /// **'Parcelada'**
  String get contaFormRecorrenciaParcelada;

  /// No description provided for @contaFormNumeroParcelas.
  ///
  /// In pt, this message translates to:
  /// **'Nº de parcelas'**
  String get contaFormNumeroParcelas;

  /// No description provided for @contaFormValidacaoParcelas.
  ///
  /// In pt, this message translates to:
  /// **'Entre 1 e 120'**
  String get contaFormValidacaoParcelas;

  /// No description provided for @contaFormExplicacaoFixa.
  ///
  /// In pt, this message translates to:
  /// **'Repete todo mês a partir de {mes}.'**
  String contaFormExplicacaoFixa(String mes);

  /// No description provided for @contaFormExplicacaoPontual.
  ///
  /// In pt, this message translates to:
  /// **'Aparece apenas em {mes}.'**
  String contaFormExplicacaoPontual(String mes);

  /// No description provided for @contaFormExplicacaoParcelada.
  ///
  /// In pt, this message translates to:
  /// **'Gera uma parcela por mês a partir de {mes}.'**
  String contaFormExplicacaoParcelada(String mes);

  /// No description provided for @contaFormRemoverTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Remover deste mês?'**
  String get contaFormRemoverTitulo;

  /// No description provided for @contaFormRemoverTexto.
  ///
  /// In pt, this message translates to:
  /// **'\"{nome}\" sai apenas deste mês. Nenhum outro mês é afetado.'**
  String contaFormRemoverTexto(String nome);

  /// No description provided for @contaFormExcluirTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Excluir conta'**
  String get contaFormExcluirTitulo;

  /// No description provided for @contaFormExcluirTexto.
  ///
  /// In pt, this message translates to:
  /// **'O que você quer excluir? Meses anteriores nunca são afetados.'**
  String get contaFormExcluirTexto;

  /// No description provided for @contaFormExcluirSoEsteMes.
  ///
  /// In pt, this message translates to:
  /// **'Só deste mês'**
  String get contaFormExcluirSoEsteMes;

  /// No description provided for @contaFormExcluirDaquiEmDiante.
  ///
  /// In pt, this message translates to:
  /// **'Deste mês em diante'**
  String get contaFormExcluirDaquiEmDiante;

  /// No description provided for @contaFormErroSalvar.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar esta conta.'**
  String get contaFormErroSalvar;

  /// No description provided for @contaFormErroExcluir.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível excluir esta conta.'**
  String get contaFormErroExcluir;

  /// No description provided for @graficoSemRegistrosTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Sem registros neste mês'**
  String get graficoSemRegistrosTitulo;

  /// No description provided for @graficoSemRegistrosDescricao.
  ///
  /// In pt, this message translates to:
  /// **'Este mês faz parte do histórico e não teve contas nem rendas registradas para calcular o direcionamento.'**
  String get graficoSemRegistrosDescricao;

  /// No description provided for @graficoSemRendaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Sem renda cadastrada neste mês'**
  String get graficoSemRendaTitulo;

  /// No description provided for @graficoSemRendaDescricao.
  ///
  /// In pt, this message translates to:
  /// **'Cadastre sua renda em Configurações → Rendas para ver o direcionamento do seu dinheiro.'**
  String get graficoSemRendaDescricao;

  /// No description provided for @graficoComoEstaDividido.
  ///
  /// In pt, this message translates to:
  /// **'Como está dividido'**
  String get graficoComoEstaDividido;

  /// No description provided for @graficoComprometido.
  ///
  /// In pt, this message translates to:
  /// **'Comprometido'**
  String get graficoComprometido;

  /// No description provided for @graficoRendaDoMes.
  ///
  /// In pt, this message translates to:
  /// **'Renda do mês'**
  String get graficoRendaDoMes;

  /// No description provided for @graficoLivre.
  ///
  /// In pt, this message translates to:
  /// **'Livre'**
  String get graficoLivre;

  /// No description provided for @graficoPercentualDaRenda.
  ///
  /// In pt, this message translates to:
  /// **'{percentual}% da renda'**
  String graficoPercentualDaRenda(int percentual);

  /// No description provided for @graficoSemanticaRosca.
  ///
  /// In pt, this message translates to:
  /// **'Renda do mês: {renda}, dividida entre {grupos} e Livre'**
  String graficoSemanticaRosca(String renda, String grupos);

  /// No description provided for @graficoSemanticaRoscaComprometido.
  ///
  /// In pt, this message translates to:
  /// **'Comprometido {percentual}% da renda do mês, {comprometido} de {renda}'**
  String graficoSemanticaRoscaComprometido(
    int percentual,
    String comprometido,
    String renda,
  );

  /// No description provided for @graficoMetaAcima.
  ///
  /// In pt, this message translates to:
  /// **'meta {meta}% · acima da meta'**
  String graficoMetaAcima(int meta);

  /// No description provided for @graficoMetaAbaixo.
  ///
  /// In pt, this message translates to:
  /// **'meta {meta}% · abaixo da meta'**
  String graficoMetaAbaixo(int meta);

  /// No description provided for @graficoMetaDentro.
  ///
  /// In pt, this message translates to:
  /// **'meta {meta}% · na meta'**
  String graficoMetaDentro(int meta);

  /// No description provided for @rendasTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Rendas'**
  String get rendasTitulo;

  /// No description provided for @rendaNova.
  ///
  /// In pt, this message translates to:
  /// **'Nova entrada'**
  String get rendaNova;

  /// No description provided for @rendaEditar.
  ///
  /// In pt, this message translates to:
  /// **'Editar entrada'**
  String get rendaEditar;

  /// No description provided for @rendasVazioTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma renda neste mês'**
  String get rendasVazioTitulo;

  /// No description provided for @rendasVazioDescricao.
  ///
  /// In pt, this message translates to:
  /// **'Toque em \"Nova entrada\" para cadastrar seu salário ou outra entrada.'**
  String get rendasVazioDescricao;

  /// No description provided for @rendasRecorrentes.
  ///
  /// In pt, this message translates to:
  /// **'Recorrentes (todo mês)'**
  String get rendasRecorrentes;

  /// No description provided for @rendasPontuaisDoMes.
  ///
  /// In pt, this message translates to:
  /// **'Pontuais de {mes}'**
  String rendasPontuaisDoMes(String mes);

  /// No description provided for @rendaRecebeDia.
  ///
  /// In pt, this message translates to:
  /// **'Recebe dia {dia}'**
  String rendaRecebeDia(String dia);

  /// No description provided for @rendaSoEm.
  ///
  /// In pt, this message translates to:
  /// **'Só em {mes}'**
  String rendaSoEm(String mes);

  /// No description provided for @rendasTotalDoMes.
  ///
  /// In pt, this message translates to:
  /// **'TOTAL DO MÊS'**
  String get rendasTotalDoMes;

  /// No description provided for @rendaNomeHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Salário'**
  String get rendaNomeHint;

  /// No description provided for @rendaTipoRecorrente.
  ///
  /// In pt, this message translates to:
  /// **'Recorrente'**
  String get rendaTipoRecorrente;

  /// No description provided for @rendaTipoPontual.
  ///
  /// In pt, this message translates to:
  /// **'Só este mês'**
  String get rendaTipoPontual;

  /// No description provided for @rendaDiaRecebimento.
  ///
  /// In pt, this message translates to:
  /// **'Dia do recebimento'**
  String get rendaDiaRecebimento;

  /// No description provided for @rendaEntraApenasEm.
  ///
  /// In pt, this message translates to:
  /// **'Entra apenas em {mes}.'**
  String rendaEntraApenasEm(String mes);

  /// No description provided for @rendaErroSalvar.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar esta entrada.'**
  String get rendaErroSalvar;

  /// No description provided for @rendaErroExcluir.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível excluir esta entrada.'**
  String get rendaErroExcluir;

  /// No description provided for @cartoesTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Cartões'**
  String get cartoesTitulo;

  /// No description provided for @cartaoNovo.
  ///
  /// In pt, this message translates to:
  /// **'Novo cartão'**
  String get cartaoNovo;

  /// No description provided for @cartaoEditar.
  ///
  /// In pt, this message translates to:
  /// **'Editar cartão'**
  String get cartaoEditar;

  /// No description provided for @cartoesVazioTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum cartão cadastrado'**
  String get cartoesVazioTitulo;

  /// No description provided for @cartoesVazioDescricao.
  ///
  /// In pt, this message translates to:
  /// **'Toque em \"Novo cartão\" para acompanhar as faturas na sua checklist mensal.'**
  String get cartoesVazioDescricao;

  /// No description provided for @cartaoFaturaVenceDia.
  ///
  /// In pt, this message translates to:
  /// **'Fatura vence dia {dia}'**
  String cartaoFaturaVenceDia(int dia);

  /// No description provided for @cartaoNomeHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Nubank'**
  String get cartaoNomeHint;

  /// No description provided for @cartaoDiaVencimento.
  ///
  /// In pt, this message translates to:
  /// **'Dia de vencimento'**
  String get cartaoDiaVencimento;

  /// No description provided for @cartaoDiaInvalido.
  ///
  /// In pt, this message translates to:
  /// **'Dia inválido'**
  String get cartaoDiaInvalido;

  /// No description provided for @cartaoExcluirTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Excluir cartão?'**
  String get cartaoExcluirTitulo;

  /// No description provided for @cartaoExcluirTexto.
  ///
  /// In pt, this message translates to:
  /// **'O cartão \"{nome}\" sai da lista e para de gerar faturas. As faturas dos meses já fechados continuam no histórico.'**
  String cartaoExcluirTexto(String nome);

  /// No description provided for @cartaoErroSalvar.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar este cartão.'**
  String get cartaoErroSalvar;

  /// No description provided for @cartaoErroExcluir.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível excluir este cartão.'**
  String get cartaoErroExcluir;

  /// No description provided for @configRendasSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Entradas recorrentes e pontuais'**
  String get configRendasSubtitulo;

  /// No description provided for @configCartoesSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Cartões de crédito e faturas'**
  String get configCartoesSubtitulo;

  /// No description provided for @configMetodologia.
  ///
  /// In pt, this message translates to:
  /// **'Metodologia (percentuais)'**
  String get configMetodologia;

  /// No description provided for @configMetodologiaSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Ajuste a referência 50-30-20'**
  String get configMetodologiaSubtitulo;

  /// No description provided for @configSecaoDados.
  ///
  /// In pt, this message translates to:
  /// **'Dados'**
  String get configSecaoDados;

  /// No description provided for @configExportar.
  ///
  /// In pt, this message translates to:
  /// **'Exportar dados'**
  String get configExportar;

  /// No description provided for @configExportarSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Planilha (CSV) ou backup completo (JSON)'**
  String get configExportarSubtitulo;

  /// No description provided for @configContaBackup.
  ///
  /// In pt, this message translates to:
  /// **'Conta e backup'**
  String get configContaBackup;

  /// No description provided for @configContaBackupSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Entrar, restaurar backup'**
  String get configContaBackupSubtitulo;

  /// No description provided for @configSecaoRisco.
  ///
  /// In pt, this message translates to:
  /// **'Zona de risco'**
  String get configSecaoRisco;

  /// No description provided for @configApagarTudo.
  ///
  /// In pt, this message translates to:
  /// **'Apagar todos os dados'**
  String get configApagarTudo;

  /// No description provided for @configExportarCsv.
  ///
  /// In pt, this message translates to:
  /// **'Planilha do mês (CSV)'**
  String get configExportarCsv;

  /// No description provided for @configExportarJson.
  ///
  /// In pt, this message translates to:
  /// **'Backup completo (JSON)'**
  String get configExportarJson;

  /// No description provided for @configCompartilharCsv.
  ///
  /// In pt, this message translates to:
  /// **'Planilha de {mes}'**
  String configCompartilharCsv(String mes);

  /// No description provided for @configCompartilharJson.
  ///
  /// In pt, this message translates to:
  /// **'Backup completo do app'**
  String get configCompartilharJson;

  /// No description provided for @configErroExportarCsv.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível exportar a planilha deste mês.'**
  String get configErroExportarCsv;

  /// No description provided for @configErroExportarJson.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível gerar o backup.'**
  String get configErroExportarJson;

  /// No description provided for @configApagarConfirmarTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Apagar todos os dados?'**
  String get configApagarConfirmarTitulo;

  /// No description provided for @configApagarConfirmarTexto.
  ///
  /// In pt, this message translates to:
  /// **'Isso remove rendas, contas, cartões e histórico deste dispositivo.'**
  String get configApagarConfirmarTexto;

  /// No description provided for @configApagarTemCerteza.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza?'**
  String get configApagarTemCerteza;

  /// Palavra que o usuário digita para confirmar a exclusão total. É comparada com o texto digitado — mude junto com configApagarInstrucao.
  ///
  /// In pt, this message translates to:
  /// **'excluir'**
  String get configApagarPalavra;

  /// No description provided for @configApagarInstrucao.
  ///
  /// In pt, this message translates to:
  /// **'Esta ação não pode ser desfeita. Para confirmar, digite \"{palavra}\" abaixo.'**
  String configApagarInstrucao(String palavra);

  /// No description provided for @configApagarAcao.
  ///
  /// In pt, this message translates to:
  /// **'Apagar tudo'**
  String get configApagarAcao;

  /// No description provided for @configErroApagar.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível apagar os dados.'**
  String get configErroApagar;

  /// No description provided for @percentuaisTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Metodologia'**
  String get percentuaisTitulo;

  /// No description provided for @percentuaisIntro.
  ///
  /// In pt, this message translates to:
  /// **'A referência 50-30-20 é um diagnóstico, não um limite. Ajuste os percentuais como preferir — a soma deve dar 100%.'**
  String get percentuaisIntro;

  /// No description provided for @percentuaisSomaOk.
  ///
  /// In pt, this message translates to:
  /// **'Soma: {soma}% — tudo certo'**
  String percentuaisSomaOk(int soma);

  /// No description provided for @percentuaisSomaInvalida.
  ///
  /// In pt, this message translates to:
  /// **'Soma: {soma}% — precisa fechar em 100%'**
  String percentuaisSomaInvalida(int soma);

  /// No description provided for @percentuaisSalvar.
  ///
  /// In pt, this message translates to:
  /// **'Salvar percentuais'**
  String get percentuaisSalvar;

  /// No description provided for @percentuaisAtualizados.
  ///
  /// In pt, this message translates to:
  /// **'Percentuais atualizados.'**
  String get percentuaisAtualizados;

  /// No description provided for @percentuaisErroSalvar.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar os percentuais.'**
  String get percentuaisErroSalvar;

  /// No description provided for @backupSecaoEntrar.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get backupSecaoEntrar;

  /// No description provided for @backupEntrarTexto.
  ///
  /// In pt, this message translates to:
  /// **'Entrar guarda um backup dos seus dados na sua conta. O app continua funcionando normalmente sem entrar.'**
  String get backupEntrarTexto;

  /// No description provided for @backupEntrarApple.
  ///
  /// In pt, this message translates to:
  /// **'Entrar com a Apple'**
  String get backupEntrarApple;

  /// No description provided for @backupEntrarGoogle.
  ///
  /// In pt, this message translates to:
  /// **'Entrar com o Google'**
  String get backupEntrarGoogle;

  /// No description provided for @backupEmBreve.
  ///
  /// In pt, this message translates to:
  /// **'Em breve'**
  String get backupEmBreve;

  /// No description provided for @backupSecao.
  ///
  /// In pt, this message translates to:
  /// **'Backup'**
  String get backupSecao;

  /// No description provided for @backupNuvem.
  ///
  /// In pt, this message translates to:
  /// **'Backup na nuvem'**
  String get backupNuvem;

  /// No description provided for @backupNuvemSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Disponível depois de entrar na conta'**
  String get backupNuvemSubtitulo;

  /// No description provided for @backupRestaurarArquivo.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar de um arquivo'**
  String get backupRestaurarArquivo;

  /// No description provided for @backupRestaurarArquivoSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Escolha um backup JSON exportado pelo app'**
  String get backupRestaurarArquivoSubtitulo;

  /// No description provided for @backupEscolherArquivo.
  ///
  /// In pt, this message translates to:
  /// **'Escolha o backup (.json)'**
  String get backupEscolherArquivo;

  /// No description provided for @backupErroLerArquivo.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível ler o arquivo.'**
  String get backupErroLerArquivo;

  /// No description provided for @backupRestaurarTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar backup?'**
  String get backupRestaurarTitulo;

  /// No description provided for @backupRestaurarTituloComData.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar backup de {data}?'**
  String backupRestaurarTituloComData(String data);

  /// No description provided for @backupRestaurarTexto.
  ///
  /// In pt, this message translates to:
  /// **'Os dados atuais deste aparelho serão substituídos pelos do backup. Os meses entre a data do backup e hoje ficarão em branco.'**
  String get backupRestaurarTexto;

  /// No description provided for @backupErroRestaurar.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível restaurar este backup.'**
  String get backupErroRestaurar;

  /// No description provided for @backupRestaurado.
  ///
  /// In pt, this message translates to:
  /// **'Backup restaurado.'**
  String get backupRestaurado;

  /// No description provided for @onboardingPasso.
  ///
  /// In pt, this message translates to:
  /// **'Passo {atual} de {total}'**
  String onboardingPasso(int atual, int total);

  /// No description provided for @onboardingBoasVindasTexto.
  ///
  /// In pt, this message translates to:
  /// **'Um aplicativo para organizar sua vida financeira, com o objetivo de te dar mais discernimento e autonomia.'**
  String get onboardingBoasVindasTexto;

  /// No description provided for @onboardingBulletChecklistTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Marque o que já pagou'**
  String get onboardingBulletChecklistTitulo;

  /// No description provided for @onboardingBulletChecklistDescricao.
  ///
  /// In pt, this message translates to:
  /// **'Veja num relance o que falta pagar no mês.'**
  String get onboardingBulletChecklistDescricao;

  /// No description provided for @onboardingBulletDirecionamentoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Direcionamento'**
  String get onboardingBulletDirecionamentoTitulo;

  /// No description provided for @onboardingBulletDirecionamentoDescricao.
  ///
  /// In pt, this message translates to:
  /// **'Separação de renda proporcional como referência, não como limitação.'**
  String get onboardingBulletDirecionamentoDescricao;

  /// No description provided for @onboardingBulletPrivacidadeTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Seus dados são seus'**
  String get onboardingBulletPrivacidadeTitulo;

  /// No description provided for @onboardingBulletPrivacidadeDescricao.
  ///
  /// In pt, this message translates to:
  /// **'Funciona offline; nada sai do aparelho sem você mandar.'**
  String get onboardingBulletPrivacidadeDescricao;

  /// No description provided for @onboardingJaUso.
  ///
  /// In pt, this message translates to:
  /// **'Já uso o app'**
  String get onboardingJaUso;

  /// No description provided for @onboardingRendaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Quais são suas rendas?'**
  String get onboardingRendaTitulo;

  /// No description provided for @onboardingRendaTexto.
  ///
  /// In pt, this message translates to:
  /// **'Adicione suas entradas mensais em valores líquidos — salário, vale, bolsa. Pode adicionar mais de uma.'**
  String get onboardingRendaTexto;

  /// No description provided for @onboardingRendaNomeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome (ex.: Salário)'**
  String get onboardingRendaNomeLabel;

  /// No description provided for @onboardingAdicionarRenda.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar renda'**
  String get onboardingAdicionarRenda;

  /// No description provided for @onboardingRendaVazia.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma renda adicionada ainda.'**
  String get onboardingRendaVazia;

  /// No description provided for @onboardingRendaPadrao.
  ///
  /// In pt, this message translates to:
  /// **'Renda {numero}'**
  String onboardingRendaPadrao(int numero);

  /// No description provided for @onboardingTotalMensal.
  ///
  /// In pt, this message translates to:
  /// **'Total mensal'**
  String get onboardingTotalMensal;

  /// No description provided for @onboardingMetodologiaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Como dividir seu dinheiro'**
  String get onboardingMetodologiaTitulo;

  /// No description provided for @onboardingMetodologiaTexto.
  ///
  /// In pt, this message translates to:
  /// **'Usamos a referência 50-30-20 como diagnóstico — nunca como limite ou cobrança. Dá para ajustar os percentuais depois.'**
  String get onboardingMetodologiaTexto;

  /// No description provided for @onboardingContasTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Suas contas principais'**
  String get onboardingContasTitulo;

  /// No description provided for @onboardingContasTexto.
  ///
  /// In pt, this message translates to:
  /// **'Adicione de 3 a 5 contas para começar. Toque numa sugestão:'**
  String get onboardingContasTexto;

  /// No description provided for @onboardingContasVazio.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma conta adicionada ainda.'**
  String get onboardingContasVazio;

  /// No description provided for @onboardingSugestaoAluguel.
  ///
  /// In pt, this message translates to:
  /// **'Aluguel'**
  String get onboardingSugestaoAluguel;

  /// No description provided for @onboardingSugestaoInternet.
  ///
  /// In pt, this message translates to:
  /// **'Internet'**
  String get onboardingSugestaoInternet;

  /// No description provided for @onboardingSugestaoEnergia.
  ///
  /// In pt, this message translates to:
  /// **'Energia'**
  String get onboardingSugestaoEnergia;

  /// No description provided for @onboardingSugestaoMercado.
  ///
  /// In pt, this message translates to:
  /// **'Mercado'**
  String get onboardingSugestaoMercado;

  /// No description provided for @onboardingSugestaoAcademia.
  ///
  /// In pt, this message translates to:
  /// **'Academia'**
  String get onboardingSugestaoAcademia;

  /// No description provided for @onboardingSugestaoReserva.
  ///
  /// In pt, this message translates to:
  /// **'Reserva de emergência'**
  String get onboardingSugestaoReserva;

  /// No description provided for @onboardingSairTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Sair e perder o que você já digitou?'**
  String get onboardingSairTitulo;

  /// No description provided for @onboardingSairTexto.
  ///
  /// In pt, this message translates to:
  /// **'Suas rendas e contas ainda não foram salvas. Você pode continuar de onde parou.'**
  String get onboardingSairTexto;

  /// No description provided for @onboardingErroConcluir.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível concluir seu cadastro.'**
  String get onboardingErroConcluir;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
