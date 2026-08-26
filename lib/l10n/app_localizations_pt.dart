// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitulo => 'Conta em Dia';

  @override
  String get abaContas => 'Contas';

  @override
  String get abaGrafico => 'Gráfico';

  @override
  String get abaConfiguracoes => 'Configurações';

  @override
  String get tituloMeuMes => 'Meu mês';

  @override
  String get tituloDirecionamento => 'Direcionamento';

  @override
  String get acaoCancelar => 'Cancelar';

  @override
  String get acaoSalvar => 'Salvar';

  @override
  String get acaoExcluir => 'Excluir';

  @override
  String get acaoAdicionar => 'Adicionar';

  @override
  String get acaoTentarNovamente => 'Tentar novamente';

  @override
  String get erroTituloPadrao => 'Não conseguimos carregar seus dados';

  @override
  String get erroDescricaoPadrao =>
      'Algo deu errado ao ler os dados deste aparelho. Nada foi perdido — tente de novo.';

  @override
  String get acaoContinuar => 'Continuar';

  @override
  String get acaoRemover => 'Remover';

  @override
  String get acaoVoltar => 'Voltar';

  @override
  String get acaoSair => 'Sair';

  @override
  String get acaoRestaurar => 'Restaurar';

  @override
  String get acaoConcluir => 'Concluir';

  @override
  String get acaoComecar => 'Começar';

  @override
  String get acaoSalvarAlteracoes => 'Salvar alterações';

  @override
  String get campoNome => 'Nome';

  @override
  String get campoValor => 'Valor';

  @override
  String get campoValorLiquido => 'Valor líquido';

  @override
  String get campoGrupo => 'Grupo';

  @override
  String get campoVenceDia => 'Vence dia';

  @override
  String get validacaoInformeNome => 'Informe um nome';

  @override
  String get validacaoDia => 'Informe um dia entre 1 e 31';

  @override
  String get validacaoValorInvalido => 'Valor inválido';

  @override
  String venceDia(int dia) {
    return 'Vence dia $dia';
  }

  @override
  String get grupoNecessidade => 'Necessidade';

  @override
  String get grupoDesejo => 'Desejo';

  @override
  String get grupoInvestimento => 'Investimento';

  @override
  String get erroCarregarMes => 'Não conseguimos carregar este mês';

  @override
  String get erroCarregarRendas => 'Não conseguimos carregar suas rendas';

  @override
  String get erroCarregarCartoes => 'Não conseguimos carregar seus cartões';

  @override
  String get erroCarregarPercentuais =>
      'Não conseguimos carregar seus percentuais';

  @override
  String get erroAbrirDados => 'Não conseguimos abrir seus dados';

  @override
  String get mesAnterior => 'Mês anterior';

  @override
  String get mesProximo => 'Próximo mês';

  @override
  String get mesEscolher => 'Escolher mês';

  @override
  String get mesAnoAnterior => 'Ano anterior';

  @override
  String get mesAnoProximo => 'Próximo ano';

  @override
  String mesSemanticaSeletor(String mes) {
    return 'Mês selecionado: $mes. Toque para escolher outro.';
  }

  @override
  String mesSemanticaAtual(String mes) {
    return '$mes, mês atual';
  }

  @override
  String get mesErroReabrir => 'Não foi possível reabrir o mês.';

  @override
  String get mesErroConcluirEdicao =>
      'Não foi possível concluir a edição do mês.';

  @override
  String get contasNovaConta => 'Nova conta';

  @override
  String get contasSecaoMensais => 'Contas mensais';

  @override
  String get contasVazioTitulo => 'Nenhuma conta neste mês';

  @override
  String get contasVazioDescricao =>
      'Toque em \"Nova conta\" para começar a organizar seu mês.';

  @override
  String get contasVazioFechadoTitulo => 'Nenhuma conta neste mês fechado';

  @override
  String get contasVazioFechadoDescricao =>
      'Este mês faz parte do histórico e não teve contas registradas.';

  @override
  String get contasMesFechadoAviso =>
      'Mês fechado — somente leitura. Este é o registro do que foi pago naquele mês.';

  @override
  String get contasReabrirMes => 'Reabrir mês';

  @override
  String get contasReabrirTitulo => 'Reabrir este mês?';

  @override
  String get contasReabrirTexto =>
      'O mês volta a ser editável para você corrigir contas e faturas deste mês. Nada nos outros meses é afetado. Ao concluir, um novo registro do mês é gravado.';

  @override
  String get contasReabrirAcao => 'Reabrir';

  @override
  String get contasEditandoFechadoAviso =>
      'Editando um mês fechado. As alterações valem só para este mês.';

  @override
  String get contasConcluirEdicao => 'Concluir edição';

  @override
  String get contasPagoEsteMes => 'PAGO ESTE MÊS';

  @override
  String contasPagoSemantica(String pago, String total, int percentual) {
    return 'Pago este mês: $pago de $total, $percentual por cento';
  }

  @override
  String contasPagoDeTotal(String total, int percentual) {
    return 'de $total · $percentual%';
  }

  @override
  String get estadoPaga => 'paga';

  @override
  String get estadoPendente => 'pendente';

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
    return 'Marcar $nome como paga';
  }

  @override
  String contaSubtitulo(String grupo, int dia) {
    return '$grupo · vencimento dia $dia';
  }

  @override
  String contaSubtituloParcela(String grupo, int dia, int parcela, int total) {
    return '$grupo · vencimento dia $dia · $parcela/$total';
  }

  @override
  String contaErroMarcar(String nome) {
    return 'Não foi possível marcar \"$nome\".';
  }

  @override
  String faturaTitulo(String cartao) {
    return 'Fatura $cartao';
  }

  @override
  String faturaMarcarPaga(String cartao) {
    return 'Marcar a fatura $cartao como paga';
  }

  @override
  String get faturaInformar => 'Informar';

  @override
  String faturaSubtitulo(int dia) {
    return 'vence dia $dia';
  }

  @override
  String faturaSubtituloRatear(int dia) {
    return 'vence dia $dia · toque para ratear';
  }

  @override
  String faturaErroMarcar(String cartao) {
    return 'Não foi possível marcar a fatura $cartao.';
  }

  @override
  String get faturaValorTotal => 'Valor total da fatura';

  @override
  String get faturaComoDividir => 'Como dividir entre os grupos';

  @override
  String get faturaComoDividirTexto =>
      'Divida de cabeça, sem itemizar. É o que mantém o painel fiel quando quase tudo é pago no cartão.';

  @override
  String get faturaSalvar => 'Salvar fatura';

  @override
  String get faturaNaoUsei => 'Não usei este cartão neste mês';

  @override
  String get faturaInformeTotal => 'Informe o valor total da fatura.';

  @override
  String get faturaTudoAlocado => 'Tudo alocado!';

  @override
  String faturaFaltaAlocar(String valor) {
    return 'Falta alocar $valor';
  }

  @override
  String faturaAlocouAMais(String valor) {
    return 'Você alocou $valor a mais que o total';
  }

  @override
  String get faturaErroSalvar => 'Não foi possível salvar esta fatura.';

  @override
  String get contaFormTituloNova => 'Nova conta';

  @override
  String get contaFormTituloEditar => 'Editar conta';

  @override
  String get contaFormTituloParcela => 'Editar parcela';

  @override
  String get contaFormTituloAjustar => 'Ajustar neste mês';

  @override
  String contaFormSubtituloParcela(int atual, int total) {
    return 'Parcela $atual/$total';
  }

  @override
  String get contaFormNomeHint => 'Ex.: Aluguel';

  @override
  String get contaFormNomeBloqueado =>
      'Nome não editável ao ajustar um mês fechado';

  @override
  String get contaFormValorDoMes => 'Valor deste mês';

  @override
  String get contaFormValorParcela => 'Valor da parcela';

  @override
  String get contaFormDiaBloqueado => 'Não editável neste ajuste';

  @override
  String get contaFormValorPago => 'Valor pago (se diferente do planejado)';

  @override
  String get contaFormAplicarProximos => 'Aplicar valor aos próximos meses';

  @override
  String get contaFormAplicarProximosDescricao =>
      'Desligado, o valor muda só neste mês';

  @override
  String get contaFormRecorrenciaFixa => 'Fixa';

  @override
  String get contaFormRecorrenciaPontual => 'Só este mês';

  @override
  String get contaFormRecorrenciaParcelada => 'Parcelada';

  @override
  String get contaFormNumeroParcelas => 'Nº de parcelas';

  @override
  String get contaFormValidacaoParcelas => 'Entre 1 e 120';

  @override
  String contaFormExplicacaoFixa(String mes) {
    return 'Repete todo mês a partir de $mes.';
  }

  @override
  String contaFormExplicacaoPontual(String mes) {
    return 'Aparece apenas em $mes.';
  }

  @override
  String contaFormExplicacaoParcelada(String mes) {
    return 'Gera uma parcela por mês a partir de $mes.';
  }

  @override
  String get contaFormRemoverTitulo => 'Remover deste mês?';

  @override
  String contaFormRemoverTexto(String nome) {
    return '\"$nome\" sai apenas deste mês. Nenhum outro mês é afetado.';
  }

  @override
  String get contaFormExcluirTitulo => 'Excluir conta';

  @override
  String get contaFormExcluirTexto =>
      'O que você quer excluir? Meses anteriores nunca são afetados.';

  @override
  String get contaFormExcluirSoEsteMes => 'Só deste mês';

  @override
  String get contaFormExcluirDaquiEmDiante => 'Deste mês em diante';

  @override
  String get contaFormErroSalvar => 'Não foi possível salvar esta conta.';

  @override
  String get contaFormErroExcluir => 'Não foi possível excluir esta conta.';

  @override
  String get graficoSemRegistrosTitulo => 'Sem registros neste mês';

  @override
  String get graficoSemRegistrosDescricao =>
      'Este mês faz parte do histórico e não teve contas nem rendas registradas para calcular o direcionamento.';

  @override
  String get graficoSemRendaTitulo => 'Sem renda cadastrada neste mês';

  @override
  String get graficoSemRendaDescricao =>
      'Cadastre sua renda em Configurações → Rendas para ver o direcionamento do seu dinheiro.';

  @override
  String get graficoComoEstaDividido => 'Como está dividido';

  @override
  String get graficoComprometido => 'Comprometido';

  @override
  String get graficoRendaDoMes => 'Renda do mês';

  @override
  String get graficoLivre => 'Livre';

  @override
  String graficoSemanticaRosca(String renda, String grupos) {
    return 'Renda do mês: $renda, dividida entre $grupos e Livre';
  }

  @override
  String graficoSemanticaRoscaComprometido(
    int percentual,
    String comprometido,
    String renda,
  ) {
    return 'Comprometido $percentual% da renda do mês, $comprometido de $renda';
  }

  @override
  String graficoMetaAcima(String meta) {
    return 'meta $meta · acima da meta';
  }

  @override
  String graficoMetaAbaixo(String meta) {
    return 'meta $meta · abaixo da meta';
  }

  @override
  String graficoMetaDentro(String meta) {
    return 'meta $meta · na meta';
  }

  @override
  String get rendasTitulo => 'Rendas';

  @override
  String get rendaNova => 'Nova entrada';

  @override
  String get rendaEditar => 'Editar entrada';

  @override
  String get rendasVazioTitulo => 'Nenhuma renda neste mês';

  @override
  String get rendasVazioDescricao =>
      'Toque em \"Nova entrada\" para cadastrar seu salário ou outra entrada.';

  @override
  String get rendasRecorrentes => 'Recorrentes (todo mês)';

  @override
  String rendasPontuaisDoMes(String mes) {
    return 'Pontuais de $mes';
  }

  @override
  String rendaRecebeDia(String dia) {
    return 'Recebe dia $dia';
  }

  @override
  String rendaSoEm(String mes) {
    return 'Só em $mes';
  }

  @override
  String get rendasTotalDoMes => 'TOTAL DO MÊS';

  @override
  String get rendaNomeHint => 'Ex.: Salário';

  @override
  String get rendaTipoRecorrente => 'Recorrente';

  @override
  String get rendaTipoPontual => 'Só este mês';

  @override
  String get rendaDiaRecebimento => 'Dia do recebimento';

  @override
  String rendaEntraApenasEm(String mes) {
    return 'Entra apenas em $mes.';
  }

  @override
  String get rendaErroSalvar => 'Não foi possível salvar esta entrada.';

  @override
  String get rendaErroExcluir => 'Não foi possível excluir esta entrada.';

  @override
  String get cartoesTitulo => 'Cartões';

  @override
  String get cartaoNovo => 'Novo cartão';

  @override
  String get cartaoEditar => 'Editar cartão';

  @override
  String get cartoesVazioTitulo => 'Nenhum cartão cadastrado';

  @override
  String get cartoesVazioDescricao =>
      'Toque em \"Novo cartão\" para acompanhar as faturas na sua checklist mensal.';

  @override
  String cartaoFaturaVenceDia(int dia) {
    return 'Fatura vence dia $dia';
  }

  @override
  String get cartaoNomeHint => 'Ex.: Nubank';

  @override
  String get cartaoDiaVencimento => 'Dia de vencimento';

  @override
  String get cartaoDiaInvalido => 'Dia inválido';

  @override
  String get cartaoExcluirTitulo => 'Excluir cartão?';

  @override
  String cartaoExcluirTexto(String nome) {
    return 'O cartão \"$nome\" sai da lista e para de gerar faturas. As faturas dos meses já fechados continuam no histórico.';
  }

  @override
  String get cartaoErroSalvar => 'Não foi possível salvar este cartão.';

  @override
  String get cartaoErroExcluir => 'Não foi possível excluir este cartão.';

  @override
  String get configRendasSubtitulo => 'Entradas recorrentes e pontuais';

  @override
  String get configCartoesSubtitulo => 'Cartões de crédito e faturas';

  @override
  String get configMetodologia => 'Metodologia (percentuais)';

  @override
  String get configMetodologiaSubtitulo => 'Ajuste a referência 50-30-20';

  @override
  String get configSecaoDados => 'Dados';

  @override
  String get configExportar => 'Exportar dados';

  @override
  String get configExportarSubtitulo =>
      'Planilha (CSV) ou backup completo (JSON)';

  @override
  String get configContaBackup => 'Conta e backup';

  @override
  String get configContaBackupSubtitulo => 'Entrar, restaurar backup';

  @override
  String get configSecaoRisco => 'Zona de risco';

  @override
  String get configApagarTudo => 'Apagar todos os dados';

  @override
  String get configExportarCsv => 'Planilha do mês (CSV)';

  @override
  String get configExportarJson => 'Backup completo (JSON)';

  @override
  String configCompartilharCsv(String mes) {
    return 'Planilha de $mes';
  }

  @override
  String get configCompartilharJson => 'Backup completo do app';

  @override
  String get configErroExportarCsv =>
      'Não foi possível exportar a planilha deste mês.';

  @override
  String get configErroExportarJson => 'Não foi possível gerar o backup.';

  @override
  String get configApagarConfirmarTitulo => 'Apagar todos os dados?';

  @override
  String get configApagarConfirmarTexto =>
      'Isso remove rendas, contas, cartões e histórico deste dispositivo.';

  @override
  String get configApagarTemCerteza => 'Tem certeza?';

  @override
  String get configApagarPalavra => 'excluir';

  @override
  String configApagarInstrucao(String palavra) {
    return 'Esta ação não pode ser desfeita. Para confirmar, digite \"$palavra\" abaixo.';
  }

  @override
  String get configApagarAcao => 'Apagar tudo';

  @override
  String get configErroApagar => 'Não foi possível apagar os dados.';

  @override
  String get percentuaisTitulo => 'Metodologia';

  @override
  String get percentuaisIntro =>
      'A referência 50-30-20 é um diagnóstico, não um limite. Ajuste os percentuais como preferir — a soma deve dar 100%.';

  @override
  String percentuaisSomaOk(int soma) {
    return 'Soma: $soma% — tudo certo';
  }

  @override
  String percentuaisSomaInvalida(int soma) {
    return 'Soma: $soma% — precisa fechar em 100%';
  }

  @override
  String get percentuaisSalvar => 'Salvar percentuais';

  @override
  String get percentuaisAtualizados => 'Percentuais atualizados.';

  @override
  String get percentuaisErroSalvar => 'Não foi possível salvar os percentuais.';

  @override
  String get backupSecaoEntrar => 'Entrar';

  @override
  String get backupEntrarTexto =>
      'Entrar guarda um backup dos seus dados na sua conta. O app continua funcionando normalmente sem entrar.';

  @override
  String get backupEntrarApple => 'Entrar com a Apple';

  @override
  String get backupEntrarGoogle => 'Entrar com o Google';

  @override
  String get backupEmBreve => 'Em breve';

  @override
  String get backupSecao => 'Backup';

  @override
  String get backupNuvem => 'Backup na nuvem';

  @override
  String get backupNuvemSubtitulo => 'Disponível depois de entrar na conta';

  @override
  String get backupRestaurarTitulo => 'Restaurar backup?';

  @override
  String backupRestaurarTituloComData(String data) {
    return 'Restaurar backup de $data?';
  }

  @override
  String get backupRestaurarTexto =>
      'Os dados atuais deste aparelho serão substituídos pelos do backup. Os meses entre a data do backup e hoje ficarão em branco.';

  @override
  String get backupErroRestaurar => 'Não foi possível restaurar este backup.';

  @override
  String get backupRestaurado => 'Backup restaurado.';

  @override
  String onboardingPasso(int atual, int total) {
    return 'Passo $atual de $total';
  }

  @override
  String get onboardingBoasVindasTexto =>
      'Um aplicativo para organizar sua vida financeira, com o objetivo de te dar mais discernimento e autonomia.';

  @override
  String get onboardingBulletChecklistTitulo => 'Marque o que já pagou';

  @override
  String get onboardingBulletChecklistDescricao =>
      'Veja num relance o que falta pagar no mês.';

  @override
  String get onboardingBulletDirecionamentoTitulo => 'Direcionamento';

  @override
  String get onboardingBulletDirecionamentoDescricao =>
      'Separação de renda proporcional como referência, não como limitação.';

  @override
  String get onboardingBulletPrivacidadeTitulo => 'Seus dados são seus';

  @override
  String get onboardingBulletPrivacidadeDescricao =>
      'Funciona offline; nada sai do aparelho sem você mandar.';

  @override
  String get onboardingJaUso => 'Já uso o app';

  @override
  String get onboardingRendaTitulo => 'Quais são suas rendas?';

  @override
  String get onboardingRendaTexto =>
      'Adicione suas entradas mensais em valores líquidos — salário, vale, bolsa. Pode adicionar mais de uma.';

  @override
  String get onboardingRendaNomeLabel => 'Nome (ex.: Salário)';

  @override
  String get onboardingAdicionarRenda => 'Adicionar renda';

  @override
  String get onboardingRendaVazia => 'Nenhuma renda adicionada ainda.';

  @override
  String onboardingRendaPadrao(int numero) {
    return 'Renda $numero';
  }

  @override
  String get onboardingTotalMensal => 'Total mensal';

  @override
  String get onboardingMetodologiaTitulo => 'Como dividir seu dinheiro';

  @override
  String get onboardingMetodologiaTexto =>
      'Usamos a referência 50-30-20 como diagnóstico — nunca como limite ou cobrança. Dá para ajustar os percentuais depois.';

  @override
  String get onboardingContasTitulo => 'Suas contas principais';

  @override
  String get onboardingContasTexto =>
      'Adicione de 3 a 5 contas para começar. Toque numa sugestão:';

  @override
  String get onboardingContasVazio => 'Nenhuma conta adicionada ainda.';

  @override
  String get onboardingSugestaoAluguel => 'Aluguel';

  @override
  String get onboardingSugestaoInternet => 'Internet';

  @override
  String get onboardingSugestaoEnergia => 'Energia';

  @override
  String get onboardingSugestaoMercado => 'Mercado';

  @override
  String get onboardingSugestaoAcademia => 'Academia';

  @override
  String get onboardingSugestaoReserva => 'Reserva de emergência';

  @override
  String get onboardingSairTitulo => 'Sair e perder o que você já digitou?';

  @override
  String get onboardingSairTexto =>
      'Suas rendas e contas ainda não foram salvas. Você pode continuar de onde parou.';

  @override
  String get onboardingErroConcluir =>
      'Não foi possível concluir seu cadastro.';

  @override
  String get rendaExcluirTitulo => 'Excluir esta renda?';

  @override
  String rendaExcluirTexto(String nome) {
    return 'A renda \"$nome\" sai do cálculo deste mês e dos próximos. Meses já fechados não são afetados.';
  }

  @override
  String get backupSair => 'Sair da conta';

  @override
  String get backupSairPergunta => 'Enviar backup antes de sair?';

  @override
  String get backupSairTexto =>
      'Suas alterações desde o último envio ainda não estão na nuvem.';

  @override
  String get backupSairEnviarESair => 'Enviar e sair';

  @override
  String get backupSairSoSair => 'Sair sem enviar';

  @override
  String get backupEnviar => 'Enviar backup agora';

  @override
  String get backupEnviarSubtitulo =>
      'Substitui o backup guardado na sua conta';

  @override
  String get backupEnviado => 'Backup enviado.';

  @override
  String get backupErroEnviar => 'Não foi possível enviar o backup.';

  @override
  String get backupRestaurarDaNuvem => 'Restaurar da nuvem';

  @override
  String get backupRestaurarDaNuvemSubtitulo =>
      'Substitui os dados deste aparelho';

  @override
  String get backupSemBackup => 'Nenhum backup nesta conta ainda';

  @override
  String get backupErroEntrar => 'Não foi possível entrar na conta.';

  @override
  String get backupErroSair => 'Não foi possível sair da conta.';

  @override
  String get backupIndisponivel => 'Serviço indisponível';

  @override
  String get backupIndisponivelTexto =>
      'Não foi possível conectar ao serviço de conta. Verifique sua conexão e reabra o app. O restante do app funciona normalmente.';

  @override
  String get backupConflitoTitulo => 'Qual versão manter?';

  @override
  String backupConflitoTexto(String data) {
    return 'Este aparelho tem dados, e sua conta tem um backup de $data. Escolher uma substitui a outra.';
  }

  @override
  String get backupConflitoUsarAparelho => 'Usar os deste aparelho';

  @override
  String get backupConflitoUsarNuvem => 'Restaurar os da conta';

  @override
  String get backupExcluirConta => 'Excluir conta';

  @override
  String get backupExcluirContaSubtitulo =>
      'Remove a conta e o backup na nuvem';

  @override
  String get backupExcluirContaTitulo => 'Excluir sua conta?';

  @override
  String get backupExcluirContaTexto =>
      'A conta e o backup guardado nela serão apagados definitivamente. Os dados deste aparelho continuam onde estão.';

  @override
  String get backupContaExcluida => 'Conta excluída.';

  @override
  String get backupErroExcluirConta => 'Não foi possível excluir a conta.';

  @override
  String get excluir => 'Excluir';

  @override
  String graficoPercentual(int percentual) {
    return '$percentual%';
  }

  @override
  String get graficoDaRenda => 'da renda';

  @override
  String contaSubtituloPaga(String grupo, String data) {
    return '$grupo · pago em $data';
  }

  @override
  String get onboardingOutraConta => 'Outra';

  @override
  String get onboardingOutraContaTitulo => 'Nova conta';

  @override
  String get onboardingOutraContaNome => 'Nome da conta';

  @override
  String get onboardingOutraContaAjuda =>
      'Você ajusta grupo e vencimento depois, na aba Contas.';

  @override
  String get entradaPausar => 'Pausar';

  @override
  String get entradaRetomar => 'Retomar';

  @override
  String get entradaPausada => 'Pausada';

  @override
  String get entradaPausadaAjuda =>
      'Não entra no cálculo dos próximos meses. O histórico continua.';

  @override
  String get entradaErroPausar => 'Não foi possível alterar esta renda.';
}
