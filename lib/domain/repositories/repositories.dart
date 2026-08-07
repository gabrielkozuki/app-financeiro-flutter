import '../entities/cartao.dart';
import '../entities/conta.dart';
import '../entities/configuracao.dart';
import '../entities/entrada.dart';
import '../entities/enums.dart';

/// Contratos de acesso a dados (camada de domínio). As implementações concretas
/// (drift) ficam em `data/repositories/` e são substituíveis por fakes nos
/// testes. Nenhum destes tipos depende de Flutter ou drift.

abstract interface class ContasRepository {
  Future<List<Conta>> listarAtivas();

  /// Todas as contas (ativas e inativas) — usado para exibir as ocorrências de
  /// meses passados de contas que foram desativadas ("excluir daqui em diante").
  Future<List<Conta>> listarTodas();
  Future<List<Conta>> listarFixasAtivas();
  Future<int> criar(Conta conta);
  Future<void> atualizar(Conta conta);
  Future<void> definirAtiva(int contaId, bool ativa);
  Future<void> excluir(int contaId);

  Future<List<OcorrenciaConta>> ocorrenciasDoMes(String mesReferencia);
  Future<Set<int>> contaIdsComOcorrenciaNoMes(String mesReferencia);
  Future<int> inserirOcorrencia({
    required int contaId,
    required String mesReferencia,
    required double valorPlanejado,
    int? parcelaAtual,
  });
  Future<void> marcarPaga(int ocorrenciaId, {double? valorPago});
  Future<void> desmarcar(int ocorrenciaId);
  Future<void> excluirOcorrencia(int ocorrenciaId);

  /// Remove a ocorrência apenas deste mês (soft-delete): some da checklist mas
  /// permanece gravada para a virada não recriá-la (RF-07).
  Future<void> removerOcorrenciaDoMes(int ocorrenciaId);

  /// Ajusta valores de uma ocorrência (planejado do mês e/ou valor pago, RN-04).
  /// Um parâmetro nulo significa "não informado" (mantém o que está gravado);
  /// para APAGAR o valor pago — voltando a calcular o mês pelo planejado —
  /// passe [limparValorPago] como true.
  Future<void> atualizarOcorrencia(
    int ocorrenciaId, {
    double? valorPlanejado,
    double? valorPago,
    bool limparValorPago = false,
  });

  /// Exclui as ocorrências de uma conta a partir de um mês (inclusive), sem
  /// tocar em meses anteriores/fechados — usado no "excluir esta e as futuras"
  /// de parcelas (RN-03).
  Future<void> excluirOcorrenciasDaContaAPartirDe(
      int contaId, String mesReferencia);
}

abstract interface class EntradasRepository {
  /// Entradas que compõem a renda do mês: recorrentes ativas + pontuais do mês.
  Future<List<Entrada>> doMes(String mesReferencia);

  /// Renda líquida total do mês (RN-02): soma das entradas de [doMes].
  Future<double> rendaDoMes(String mesReferencia);

  /// Todas as entradas cadastradas (para a tela de gestão de renda).
  Future<List<Entrada>> todas();

  Future<int> criar(Entrada entrada);
  Future<void> atualizar(Entrada entrada);
  Future<void> excluir(int id);

  /// Total de entradas cadastradas (usado para detectar a primeira execução).
  Future<int> contarTodas();
}

abstract interface class CartoesRepository {
  Future<List<Cartao>> listarAtivos();
  Future<int> criar(Cartao cartao);
  Future<void> atualizar(Cartao cartao);
  Future<void> excluir(int cartaoId);

  Future<List<FaturaCartao>> faturasDoMes(String mesReferencia);
  Future<Set<int>> cartaoIdsComFaturaNoMes(String mesReferencia);

  /// Cria a fatura (vazia) do mês para um cartão e devolve seu id.
  Future<int> criarFatura({required int cartaoId, required String mesReferencia});
  Future<void> definirValorFatura(int faturaId, double valorTotal);
  Future<void> marcarFaturaPaga(int faturaId, {double? valorPago});
  Future<void> desmarcarFatura(int faturaId);

  Future<List<RateioFatura>> rateiosDaFatura(int faturaId);

  /// Substitui todo o rateio de uma fatura pelos valores por grupo informados
  /// (a soma deve bater o total — validado na camada de aplicação, RN-08).
  Future<void> salvarRateio(int faturaId, Map<Grupo, double> valores);
}

abstract interface class ConfigRepository {
  /// Percentuais vigentes no mês informado (o snapshot mais recente cuja
  /// vigência começa em mês ≤ [mesReferencia]); padrão 50-30-20 se não houver.
  Future<ConfiguracaoMetodologia> vigenteEm(String mesReferencia);
  Future<void> salvar(ConfiguracaoMetodologia config);
}

abstract interface class FechamentoRepository {
  /// Retrato imutável de um mês fechado (nulo se o mês ainda não foi fechado).
  Future<FechamentoMensal?> doMes(String mesReferencia);
  Future<void> salvar(FechamentoMensal fechamento);

  /// Descarta o retrato de um mês (usado ao "reabrir" o mês para edição).
  Future<void> excluir(String mesReferencia);

  /// Meses (`YYYY-MM`) que têm alguma ocorrência ou fatura registrada — a base
  /// para decidir quais meses passados precisam ser fechados.
  Future<List<String>> mesesComDados();
}
