import '../entities/cartao.dart';
import '../entities/conta.dart';
import '../entities/enums.dart';

/// Uma nova ocorrência de conta a ser criada na virada do mês.
class NovaOcorrencia {
  const NovaOcorrencia({
    required this.contaId,
    required this.mesReferencia,
    required this.valorPlanejado,
  });

  final int contaId;
  final String mesReferencia;
  final double valorPlanejado;
}

/// Uma nova fatura de cartão a ser criada na virada do mês.
class NovaFatura {
  const NovaFatura({required this.cartaoId, required this.mesReferencia});

  final int cartaoId;
  final String mesReferencia;
}

/// O que precisa ser materializado para um mês de referência.
class MesGerado {
  const MesGerado({required this.ocorrencias, required this.faturas});

  final List<NovaOcorrencia> ocorrencias;
  final List<NovaFatura> faturas;
}

/// Gera a checklist do mês a partir das contas recorrentes fixas e dos cartões
/// ativos (RF-16). É idempotente: nada é duplicado se a ocorrência/fatura do mês
/// já existe. Parcelas NÃO são geradas aqui — já foram materializadas no ato do
/// cadastro (RF-06). Contas pontuais também não, pois pertencem só ao seu mês.
///
/// Regra do recorte fechado (RN-05): esta função apenas cria as instâncias do
/// mês-alvo; nada é migrado de meses anteriores.
class GerarMes {
  const GerarMes();

  MesGerado call({
    required String mesReferencia,
    required List<Conta> contasFixasAtivas,
    required Set<int> contaIdsComOcorrenciaNoMes,
    required List<Cartao> cartoesAtivos,
    required Set<int> cartaoIdsComFaturaNoMes,
  }) {
    final ocorrencias = <NovaOcorrencia>[];
    for (final conta in contasFixasAtivas) {
      final relevante =
          conta.ativa && conta.recorrencia == Recorrencia.fixa;
      if (relevante && !contaIdsComOcorrenciaNoMes.contains(conta.id)) {
        ocorrencias.add(NovaOcorrencia(
          contaId: conta.id,
          mesReferencia: mesReferencia,
          valorPlanejado: conta.valorPlanejado,
        ));
      }
    }

    final faturas = <NovaFatura>[];
    for (final cartao in cartoesAtivos) {
      if (cartao.ativa && !cartaoIdsComFaturaNoMes.contains(cartao.id)) {
        faturas.add(NovaFatura(
          cartaoId: cartao.id,
          mesReferencia: mesReferencia,
        ));
      }
    }

    return MesGerado(ocorrencias: ocorrencias, faturas: faturas);
  }
}
