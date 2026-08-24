// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitulo => 'Bills on Track';

  @override
  String get abaContas => 'Bills';

  @override
  String get abaGrafico => 'Chart';

  @override
  String get abaConfiguracoes => 'Settings';

  @override
  String get tituloMeuMes => 'My month';

  @override
  String get tituloDirecionamento => 'Breakdown';

  @override
  String get acaoCancelar => 'Cancel';

  @override
  String get acaoSalvar => 'Save';

  @override
  String get acaoExcluir => 'Delete';

  @override
  String get acaoAdicionar => 'Add';

  @override
  String get acaoTentarNovamente => 'Try again';

  @override
  String get erroTituloPadrao => 'We couldn\'t load your data';

  @override
  String get erroDescricaoPadrao =>
      'Something went wrong reading data on this device. Nothing was lost — please try again.';

  @override
  String get acaoContinuar => 'Continue';

  @override
  String get acaoRemover => 'Remove';

  @override
  String get acaoVoltar => 'Back';

  @override
  String get acaoSair => 'Leave';

  @override
  String get acaoRestaurar => 'Restore';

  @override
  String get acaoConcluir => 'Finish';

  @override
  String get acaoComecar => 'Get started';

  @override
  String get acaoSalvarAlteracoes => 'Save changes';

  @override
  String get campoNome => 'Name';

  @override
  String get campoValor => 'Amount';

  @override
  String get campoValorLiquido => 'Net amount';

  @override
  String get campoGrupo => 'Group';

  @override
  String get campoVenceDia => 'Due day';

  @override
  String get validacaoInformeNome => 'Enter a name';

  @override
  String get validacaoDia => 'Enter a day between 1 and 31';

  @override
  String get validacaoValorInvalido => 'Invalid amount';

  @override
  String venceDia(int dia) {
    return 'Due on day $dia';
  }

  @override
  String get grupoNecessidade => 'Needs';

  @override
  String get grupoDesejo => 'Wants';

  @override
  String get grupoInvestimento => 'Savings';

  @override
  String get erroCarregarMes => 'We couldn\'t load this month';

  @override
  String get erroCarregarRendas => 'We couldn\'t load your income';

  @override
  String get erroCarregarCartoes => 'We couldn\'t load your cards';

  @override
  String get erroCarregarPercentuais => 'We couldn\'t load your percentages';

  @override
  String get erroAbrirDados => 'We couldn\'t open your data';

  @override
  String get mesAnterior => 'Previous month';

  @override
  String get mesProximo => 'Next month';

  @override
  String get mesEscolher => 'Choose a month';

  @override
  String get mesAnoAnterior => 'Previous year';

  @override
  String get mesAnoProximo => 'Next year';

  @override
  String mesSemanticaSeletor(String mes) {
    return 'Selected month: $mes. Tap to choose another one.';
  }

  @override
  String mesSemanticaAtual(String mes) {
    return '$mes, current month';
  }

  @override
  String get mesErroReabrir => 'We couldn\'t reopen this month.';

  @override
  String get mesErroConcluirEdicao => 'We couldn\'t finish editing this month.';

  @override
  String get contasNovaConta => 'New bill';

  @override
  String get contasSecaoMensais => 'Monthly bills';

  @override
  String get contasVazioTitulo => 'No bills this month';

  @override
  String get contasVazioDescricao =>
      'Tap \"New bill\" to start organizing your month.';

  @override
  String get contasVazioFechadoTitulo => 'No bills in this closed month';

  @override
  String get contasVazioFechadoDescricao =>
      'This month is part of your history and had no bills recorded.';

  @override
  String get contasMesFechadoAviso =>
      'Closed month — read only. This is the record of what was paid back then.';

  @override
  String get contasReabrirMes => 'Reopen month';

  @override
  String get contasReabrirTitulo => 'Reopen this month?';

  @override
  String get contasReabrirTexto =>
      'The month becomes editable again so you can correct its bills and statements. No other month is affected. When you\'re done, a new record of the month is saved.';

  @override
  String get contasReabrirAcao => 'Reopen';

  @override
  String get contasEditandoFechadoAviso =>
      'You\'re editing a closed month. Changes apply to this month only.';

  @override
  String get contasConcluirEdicao => 'Finish editing';

  @override
  String get contasPagoEsteMes => 'PAID THIS MONTH';

  @override
  String contasPagoSemantica(String pago, String total, int percentual) {
    return 'Paid this month: $pago of $total, $percentual percent';
  }

  @override
  String contasPagoDeTotal(String total, int percentual) {
    return 'of $total · $percentual%';
  }

  @override
  String get estadoPaga => 'paid';

  @override
  String get estadoPendente => 'pending';

  @override
  String contaSemantica(
    String nome,
    String grupo,
    String valor,
    String estado,
  ) {
    return '$nome, $grupo, $valor, $estado';
  }

  @override
  String contaMarcarPaga(String nome) {
    return 'Mark $nome as paid';
  }

  @override
  String contaSubtitulo(String grupo, int dia) {
    return '$grupo · due on day $dia';
  }

  @override
  String contaSubtituloParcela(String grupo, int dia, int parcela, int total) {
    return '$grupo · due on day $dia · $parcela/$total';
  }

  @override
  String contaErroMarcar(String nome) {
    return 'We couldn\'t update \"$nome\".';
  }

  @override
  String faturaTitulo(String cartao) {
    return '$cartao statement';
  }

  @override
  String faturaMarcarPaga(String cartao) {
    return 'Mark the $cartao statement as paid';
  }

  @override
  String get faturaInformar => 'Add amount';

  @override
  String faturaSubtitulo(int dia) {
    return 'due on day $dia';
  }

  @override
  String faturaSubtituloRatear(int dia) {
    return 'due on day $dia · tap to split';
  }

  @override
  String faturaErroMarcar(String cartao) {
    return 'We couldn\'t update the $cartao statement.';
  }

  @override
  String get faturaValorTotal => 'Statement total';

  @override
  String get faturaComoDividir => 'How to split it between groups';

  @override
  String get faturaComoDividirTexto =>
      'Split it off the top of your head — no need to go item by item. That\'s what keeps the breakdown honest when almost everything goes on the card.';

  @override
  String get faturaSalvar => 'Save statement';

  @override
  String get faturaNaoUsei => 'I didn\'t use this card this month';

  @override
  String get faturaInformeTotal => 'Enter the statement total.';

  @override
  String get faturaTudoAlocado => 'Everything\'s split!';

  @override
  String faturaFaltaAlocar(String valor) {
    return '$valor still to split';
  }

  @override
  String faturaAlocouAMais(String valor) {
    return 'You\'ve split $valor more than the total';
  }

  @override
  String get faturaErroSalvar => 'We couldn\'t save this statement.';

  @override
  String get contaFormTituloNova => 'New bill';

  @override
  String get contaFormTituloEditar => 'Edit bill';

  @override
  String get contaFormTituloParcela => 'Edit installment';

  @override
  String get contaFormTituloAjustar => 'Adjust for this month';

  @override
  String contaFormSubtituloParcela(int atual, int total) {
    return 'Installment $atual/$total';
  }

  @override
  String get contaFormNomeHint => 'e.g. Rent';

  @override
  String get contaFormNomeBloqueado =>
      'The name can\'t be changed while adjusting a closed month';

  @override
  String get contaFormValorDoMes => 'Amount for this month';

  @override
  String get contaFormValorParcela => 'Installment amount';

  @override
  String get contaFormDiaBloqueado => 'Can\'t be changed in this adjustment';

  @override
  String get contaFormValorPago => 'Amount paid (if different from planned)';

  @override
  String get contaFormAplicarProximos =>
      'Apply this amount to the coming months';

  @override
  String get contaFormAplicarProximosDescricao =>
      'When off, the amount changes for this month only';

  @override
  String get contaFormRecorrenciaFixa => 'Monthly';

  @override
  String get contaFormRecorrenciaPontual => 'One-time';

  @override
  String get contaFormRecorrenciaParcelada => 'Installments';

  @override
  String get contaFormNumeroParcelas => 'Number of installments';

  @override
  String get contaFormValidacaoParcelas => 'Between 1 and 120';

  @override
  String contaFormExplicacaoFixa(String mes) {
    return 'Repeats every month starting in $mes.';
  }

  @override
  String contaFormExplicacaoPontual(String mes) {
    return 'Shows up in $mes only.';
  }

  @override
  String contaFormExplicacaoParcelada(String mes) {
    return 'Creates one installment a month starting in $mes.';
  }

  @override
  String get contaFormRemoverTitulo => 'Remove from this month?';

  @override
  String contaFormRemoverTexto(String nome) {
    return '\"$nome\" leaves this month only. No other month is affected.';
  }

  @override
  String get contaFormExcluirTitulo => 'Delete bill';

  @override
  String get contaFormExcluirTexto =>
      'What would you like to delete? Earlier months are never affected.';

  @override
  String get contaFormExcluirSoEsteMes => 'This month only';

  @override
  String get contaFormExcluirDaquiEmDiante => 'This month onwards';

  @override
  String get contaFormErroSalvar => 'We couldn\'t save this bill.';

  @override
  String get contaFormErroExcluir => 'We couldn\'t delete this bill.';

  @override
  String get graficoSemRegistrosTitulo => 'Nothing recorded this month';

  @override
  String get graficoSemRegistrosDescricao =>
      'This month is part of your history and has no bills or income recorded to break down.';

  @override
  String get graficoSemRendaTitulo => 'No income for this month';

  @override
  String get graficoSemRendaDescricao =>
      'Add your income in Settings → Income to see where your money goes.';

  @override
  String get graficoComoEstaDividido => 'How it\'s divided';

  @override
  String get graficoComprometido => 'Committed';

  @override
  String get graficoRendaDoMes => 'Monthly income';

  @override
  String get graficoLivre => 'Left to spend';

  @override
  String graficoPercentualDaRenda(int percentual) {
    return '$percentual% of your income';
  }

  @override
  String graficoSemanticaRosca(String renda, String grupos) {
    return 'Monthly income: $renda, divided between $grupos and Left to spend';
  }

  @override
  String graficoSemanticaRoscaComprometido(
    int percentual,
    String comprometido,
    String renda,
  ) {
    return '$percentual% of this month\'s income is committed, $comprometido of $renda';
  }

  @override
  String graficoMetaAcima(int meta) {
    return '$meta% target · above';
  }

  @override
  String graficoMetaAbaixo(int meta) {
    return '$meta% target · below';
  }

  @override
  String graficoMetaDentro(int meta) {
    return '$meta% target · on target';
  }

  @override
  String get rendasTitulo => 'Income';

  @override
  String get rendaNova => 'New income';

  @override
  String get rendaEditar => 'Edit income';

  @override
  String get rendasVazioTitulo => 'No income this month';

  @override
  String get rendasVazioDescricao =>
      'Tap \"New income\" to add your salary or another source.';

  @override
  String get rendasRecorrentes => 'Recurring (every month)';

  @override
  String rendasPontuaisDoMes(String mes) {
    return 'One-time in $mes';
  }

  @override
  String rendaRecebeDia(String dia) {
    return 'Paid on day $dia';
  }

  @override
  String rendaSoEm(String mes) {
    return 'Only in $mes';
  }

  @override
  String get rendasTotalDoMes => 'MONTHLY TOTAL';

  @override
  String get rendaNomeHint => 'e.g. Salary';

  @override
  String get rendaTipoRecorrente => 'Recurring';

  @override
  String get rendaTipoPontual => 'One-time';

  @override
  String get rendaDiaRecebimento => 'Day you get paid';

  @override
  String rendaEntraApenasEm(String mes) {
    return 'Counts in $mes only.';
  }

  @override
  String get rendaErroSalvar => 'We couldn\'t save this income.';

  @override
  String get rendaErroExcluir => 'We couldn\'t delete this income.';

  @override
  String get cartoesTitulo => 'Cards';

  @override
  String get cartaoNovo => 'New card';

  @override
  String get cartaoEditar => 'Edit card';

  @override
  String get cartoesVazioTitulo => 'No cards yet';

  @override
  String get cartoesVazioDescricao =>
      'Tap \"New card\" to follow your statements in the monthly checklist.';

  @override
  String cartaoFaturaVenceDia(int dia) {
    return 'Statement due on day $dia';
  }

  @override
  String get cartaoNomeHint => 'e.g. Visa';

  @override
  String get cartaoDiaVencimento => 'Due day';

  @override
  String get cartaoDiaInvalido => 'Invalid day';

  @override
  String get cartaoExcluirTitulo => 'Delete card?';

  @override
  String cartaoExcluirTexto(String nome) {
    return 'The \"$nome\" card leaves the list and stops generating statements. Statements in months already closed stay in your history.';
  }

  @override
  String get cartaoErroSalvar => 'We couldn\'t save this card.';

  @override
  String get cartaoErroExcluir => 'We couldn\'t delete this card.';

  @override
  String get configRendasSubtitulo => 'Recurring and one-time income';

  @override
  String get configCartoesSubtitulo => 'Credit cards and statements';

  @override
  String get configMetodologia => 'Method (percentages)';

  @override
  String get configMetodologiaSubtitulo => 'Adjust the 50-30-20 reference';

  @override
  String get configSecaoDados => 'Data';

  @override
  String get configExportar => 'Export data';

  @override
  String get configExportarSubtitulo =>
      'Spreadsheet (CSV) or full backup (JSON)';

  @override
  String get configContaBackup => 'Account and backup';

  @override
  String get configContaBackupSubtitulo => 'Sign in, restore a backup';

  @override
  String get configSecaoRisco => 'Danger zone';

  @override
  String get configApagarTudo => 'Delete all data';

  @override
  String get configExportarCsv => 'This month\'s spreadsheet (CSV)';

  @override
  String get configExportarJson => 'Full backup (JSON)';

  @override
  String configCompartilharCsv(String mes) {
    return 'Spreadsheet for $mes';
  }

  @override
  String get configCompartilharJson => 'Full app backup';

  @override
  String get configErroExportarCsv =>
      'We couldn\'t export this month\'s spreadsheet.';

  @override
  String get configErroExportarJson => 'We couldn\'t create the backup.';

  @override
  String get configApagarConfirmarTitulo => 'Delete all data?';

  @override
  String get configApagarConfirmarTexto =>
      'This removes income, bills, cards and history from this device.';

  @override
  String get configApagarTemCerteza => 'Are you sure?';

  @override
  String get configApagarPalavra => 'delete';

  @override
  String configApagarInstrucao(String palavra) {
    return 'This can\'t be undone. To confirm, type \"$palavra\" below.';
  }

  @override
  String get configApagarAcao => 'Delete everything';

  @override
  String get configErroApagar => 'We couldn\'t delete your data.';

  @override
  String get percentuaisTitulo => 'Method';

  @override
  String get percentuaisIntro =>
      'The 50-30-20 reference is a diagnosis, not a limit. Set the percentages however you like — they just need to add up to 100%.';

  @override
  String percentuaisSomaOk(int soma) {
    return 'Total: $soma% — all set';
  }

  @override
  String percentuaisSomaInvalida(int soma) {
    return 'Total: $soma% — needs to add up to 100%';
  }

  @override
  String get percentuaisSalvar => 'Save percentages';

  @override
  String get percentuaisAtualizados => 'Percentages updated.';

  @override
  String get percentuaisErroSalvar => 'We couldn\'t save your percentages.';

  @override
  String get backupSecaoEntrar => 'Sign in';

  @override
  String get backupEntrarTexto =>
      'Signing in keeps a backup of your data in your account. The app works just the same without it.';

  @override
  String get backupEntrarApple => 'Sign in with Apple';

  @override
  String get backupEntrarGoogle => 'Sign in with Google';

  @override
  String get backupEmBreve => 'Coming soon';

  @override
  String get backupSecao => 'Backup';

  @override
  String get backupNuvem => 'Cloud backup';

  @override
  String get backupNuvemSubtitulo => 'Available once you sign in';

  @override
  String get backupRestaurarTitulo => 'Restore backup?';

  @override
  String backupRestaurarTituloComData(String data) {
    return 'Restore the backup from $data?';
  }

  @override
  String get backupRestaurarTexto =>
      'The data on this device will be replaced by the one in the backup. The months between the backup date and today will come up empty.';

  @override
  String get backupErroRestaurar => 'We couldn\'t restore this backup.';

  @override
  String get backupRestaurado => 'Backup restored.';

  @override
  String onboardingPasso(int atual, int total) {
    return 'Step $atual of $total';
  }

  @override
  String get onboardingBoasVindasTexto =>
      'An app to organize your financial life, made to give you more clarity and more say over your money.';

  @override
  String get onboardingBulletChecklistTitulo => 'Check off what you\'ve paid';

  @override
  String get onboardingBulletChecklistDescricao =>
      'See at a glance what\'s still left to pay this month.';

  @override
  String get onboardingBulletDirecionamentoTitulo => 'Breakdown';

  @override
  String get onboardingBulletDirecionamentoDescricao =>
      'A proportional split of your income as a reference, never as a limit.';

  @override
  String get onboardingBulletPrivacidadeTitulo => 'Your data is yours';

  @override
  String get onboardingBulletPrivacidadeDescricao =>
      'Works offline; nothing leaves the device unless you say so.';

  @override
  String get onboardingJaUso => 'I already use the app';

  @override
  String get onboardingRendaTitulo => 'What\'s your income?';

  @override
  String get onboardingRendaTexto =>
      'Add what you take home each month — salary, benefits, stipend. You can add more than one.';

  @override
  String get onboardingRendaNomeLabel => 'Name (e.g. Salary)';

  @override
  String get onboardingAdicionarRenda => 'Add income';

  @override
  String get onboardingRendaVazia => 'No income added yet.';

  @override
  String onboardingRendaPadrao(int numero) {
    return 'Income $numero';
  }

  @override
  String get onboardingTotalMensal => 'Monthly total';

  @override
  String get onboardingMetodologiaTitulo => 'How to divide your money';

  @override
  String get onboardingMetodologiaTexto =>
      'We use the 50-30-20 reference as a diagnosis — never as a limit or a demand. You can fine-tune the percentages later.';

  @override
  String get onboardingContasTitulo => 'Your main bills';

  @override
  String get onboardingContasTexto =>
      'Add 3 to 5 bills to get started. Tap a suggestion:';

  @override
  String get onboardingContasVazio => 'No bills added yet.';

  @override
  String get onboardingSugestaoAluguel => 'Rent';

  @override
  String get onboardingSugestaoInternet => 'Internet';

  @override
  String get onboardingSugestaoEnergia => 'Electricity';

  @override
  String get onboardingSugestaoMercado => 'Groceries';

  @override
  String get onboardingSugestaoAcademia => 'Gym';

  @override
  String get onboardingSugestaoReserva => 'Emergency fund';

  @override
  String get onboardingSairTitulo => 'Leave and lose what you\'ve entered?';

  @override
  String get onboardingSairTexto =>
      'Your income and bills haven\'t been saved yet. You can pick up right where you left off.';

  @override
  String get onboardingErroConcluir => 'We couldn\'t finish your setup.';

  @override
  String get rendaExcluirTitulo => 'Delete this income?';

  @override
  String rendaExcluirTexto(String nome) {
    return 'The income \"$nome\" is removed from this month and the next ones. Closed months are not affected.';
  }

  @override
  String get backupSair => 'Sign out';

  @override
  String get backupSairPergunta => 'Back up before signing out?';

  @override
  String get backupSairTexto =>
      'Your changes since the last upload are not in the cloud yet.';

  @override
  String get backupSairEnviarESair => 'Back up and sign out';

  @override
  String get backupSairSoSair => 'Sign out without backing up';

  @override
  String get backupEnviar => 'Back up now';

  @override
  String get backupEnviarSubtitulo =>
      'Replaces the backup stored in your account';

  @override
  String get backupEnviado => 'Backup uploaded.';

  @override
  String get backupErroEnviar => 'Couldn\'t upload the backup.';

  @override
  String get backupRestaurarDaNuvem => 'Restore from cloud';

  @override
  String get backupRestaurarDaNuvemSubtitulo =>
      'Replaces the data on this device';

  @override
  String get backupSemBackup => 'No backup in this account yet';

  @override
  String get backupErroEntrar => 'Couldn\'t sign in.';

  @override
  String get backupErroSair => 'Couldn\'t sign out.';

  @override
  String get backupIndisponivel => 'Service unavailable';

  @override
  String get backupIndisponivelTexto =>
      'Couldn\'t reach the account service. Check your connection and reopen the app. The rest of the app works normally.';

  @override
  String get backupConflitoTitulo => 'Which version do you want to keep?';

  @override
  String backupConflitoTexto(String data) {
    return 'This device has data, and your account has a backup from $data. Choosing one replaces the other.';
  }

  @override
  String get backupConflitoUsarAparelho => 'Keep this device\'s';

  @override
  String get backupConflitoUsarNuvem => 'Restore the account\'s';

  @override
  String get backupExcluirConta => 'Delete account';

  @override
  String get backupExcluirContaSubtitulo =>
      'Removes the account and its cloud backup';

  @override
  String get backupExcluirContaTitulo => 'Delete your account?';

  @override
  String get backupExcluirContaTexto =>
      'The account and the backup stored in it will be permanently erased. The data on this device stays where it is.';

  @override
  String get backupContaExcluida => 'Account deleted.';

  @override
  String get backupErroExcluirConta => 'Couldn\'t delete the account.';

  @override
  String get excluir => 'Delete';
}
