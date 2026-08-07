import '../../domain/entities/cartao.dart';
import '../../domain/entities/conta.dart';
import '../../domain/entities/configuracao.dart';
import '../../domain/entities/entrada.dart';
import '../../domain/entities/enums.dart';
import 'app_database.dart';

/// Conversões entre as linhas geradas pelo drift (camada de dados) e as
/// entidades puras do domínio. Mantém o domínio livre de drift.

Entrada toEntrada(EntradaRow r) => Entrada(
      id: r.id,
      nome: r.nome,
      valorLiquido: r.valorLiquido,
      tipo: r.tipo,
      diaRecebimento: r.diaRecebimento,
      mesReferencia: r.mesReferencia,
      ativa: r.ativa,
    );

Conta toConta(ContaRow r) => Conta(
      id: r.id,
      nome: r.nome,
      grupo: r.grupo,
      valorPlanejado: r.valorPlanejado,
      diaVencimento: r.diaVencimento,
      recorrencia: r.recorrencia,
      totalParcelas: r.totalParcelas,
      ativa: r.ativa,
    );

OcorrenciaConta toOcorrencia(OcorrenciaContaRow r) => OcorrenciaConta(
      id: r.id,
      contaId: r.contaId,
      mesReferencia: r.mesReferencia,
      valorPlanejado: r.valorPlanejado,
      valorPago: r.valorPago,
      dataPagamento: r.dataPagamento,
      status: r.status,
      parcelaAtual: r.parcelaAtual,
    );

Cartao toCartao(CartaoRow r) => Cartao(
      id: r.id,
      nome: r.nome,
      diaVencimento: r.diaVencimento,
      ativa: r.ativa,
    );

FaturaCartao toFatura(FaturaCartaoRow r) => FaturaCartao(
      id: r.id,
      cartaoId: r.cartaoId,
      mesReferencia: r.mesReferencia,
      valorTotal: r.valorTotal,
      valorPago: r.valorPago,
      dataPagamento: r.dataPagamento,
      status: r.status,
    );

RateioFatura toRateio(RateioFaturaRow r) => RateioFatura(
      id: r.id,
      faturaCartaoId: r.faturaCartaoId,
      grupo: r.grupo,
      valor: r.valor,
    );

ConfiguracaoMetodologia toConfig(ConfiguracaoMetodologiaRow r) =>
    ConfiguracaoMetodologia(
      mesVigenciaInicial: r.mesVigenciaInicial,
      percentualNecessidades: r.percentualNecessidades,
      percentualDesejos: r.percentualDesejos,
      percentualPoupanca: r.percentualPoupanca,
    );

FechamentoMensal toFechamento(FechamentoMensalRow r) => FechamentoMensal(
      mesReferencia: r.mesReferencia,
      rendaTotal: r.rendaTotal,
      totalPorGrupo: {
        Grupo.necessidade: r.totalNecessidade,
        Grupo.desejo: r.totalDesejo,
        Grupo.investimento: r.totalInvestimento,
      },
      snapshotPercentuais: ConfiguracaoMetodologia(
        mesVigenciaInicial: r.mesReferencia,
        percentualNecessidades: r.snapNecessidades,
        percentualDesejos: r.snapDesejos,
        percentualPoupanca: r.snapPoupanca,
      ),
    );
