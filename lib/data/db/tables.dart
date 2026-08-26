import 'package:drift/drift.dart';

import '../../domain/entities/enums.dart';

/// Tabelas do banco local (SQLite via drift), espelhando o modelo de dados
/// conceitual da seção 8 do documento de requisitos. Enums são persistidos como
/// inteiro (`intEnum`); `mesReferencia` é a chave textual `YYYY-MM` do recorte.

@DataClassName('EntradaRow')
class Entradas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text()();
  RealColumn get valorLiquido => real()();
  IntColumn get tipo => intEnum<TipoEntrada>()();
  IntColumn get diaRecebimento => integer().nullable()();
  TextColumn get mesReferencia => text().nullable()();
  /// Vigência da pausa, em `YYYY-MM`. Substituiu o booleano `ativa` na
  /// schemaVersion 2: pausar precisa valer **daquele mês em diante**, não
  /// retroativamente, senão pausar hoje reescreveria meses passados que ainda
  /// leem ao vivo (os reabertos).
  ///
  /// `pausadaDesde` nulo = nunca pausada. `retomadaEm` nulo = segue pausada.
  /// Retomar em outubro deixa o intervalo [pausadaDesde, outubro) sem contar e
  /// outubro em diante contando.
  TextColumn get pausadaDesde => text().nullable()();
  TextColumn get retomadaEm => text().nullable()();
}

@DataClassName('ContaRow')
class Contas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text()();
  IntColumn get grupo => intEnum<Grupo>()();
  RealColumn get valorPlanejado => real()();
  IntColumn get diaVencimento => integer()();
  IntColumn get recorrencia => intEnum<Recorrencia>()();
  IntColumn get totalParcelas => integer().nullable()();
  BoolColumn get ativa => boolean().withDefault(const Constant(true))();
}

@DataClassName('OcorrenciaContaRow')
class OcorrenciasConta extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get contaId => integer().references(Contas, #id)();
  TextColumn get mesReferencia => text()();
  RealColumn get valorPlanejado => real()();
  RealColumn get valorPago => real().nullable()();
  DateTimeColumn get dataPagamento => dateTime().nullable()();
  IntColumn get status =>
      intEnum<StatusPagamento>().withDefault(const Constant(0))();
  IntColumn get parcelaAtual => integer().nullable()();

  /// Ocorrência "removida só deste mês" (RF-07): fica oculta na checklist, mas
  /// permanece gravada para que a virada não a recrie.
  BoolColumn get removida => boolean().withDefault(const Constant(false))();

  /// Uma conta tem no máximo UMA ocorrência por mês. A idempotência da virada
  /// (RF-16/RN-05) passa a ser garantida pelo banco, e não só pela checagem
  /// prévia do caso de uso: duas execuções concorrentes não duplicam a linha.
  @override
  List<Set<Column>> get uniqueKeys => [
        {contaId, mesReferencia},
      ];
}

@DataClassName('CartaoRow')
class Cartoes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text()();
  IntColumn get diaVencimento => integer()();
  BoolColumn get ativa => boolean().withDefault(const Constant(true))();
}

@DataClassName('FaturaCartaoRow')
class FaturasCartao extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cartaoId => integer().references(Cartoes, #id)();
  TextColumn get mesReferencia => text()();
  RealColumn get valorTotal => real().nullable()();
  RealColumn get valorPago => real().nullable()();
  DateTimeColumn get dataPagamento => dateTime().nullable()();
  IntColumn get status =>
      intEnum<StatusPagamento>().withDefault(const Constant(0))();

  /// Um cartão tem no máximo UMA fatura por mês — mesma garantia de
  /// idempotência da virada aplicada às ocorrências de conta.
  @override
  List<Set<Column>> get uniqueKeys => [
        {cartaoId, mesReferencia},
      ];
}

@DataClassName('RateioFaturaRow')
class RateiosFatura extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get faturaCartaoId => integer().references(FaturasCartao, #id)();
  IntColumn get grupo => intEnum<Grupo>()();
  RealColumn get valor => real()();
}

@DataClassName('ConfiguracaoMetodologiaRow')
class ConfiguracoesMetodologia extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get mesVigenciaInicial => text()();
  RealColumn get percentualNecessidades =>
      real().withDefault(const Constant(50))();
  RealColumn get percentualDesejos => real().withDefault(const Constant(30))();
  RealColumn get percentualPoupanca => real().withDefault(const Constant(20))();
}

@DataClassName('FechamentoMensalRow')
class FechamentosMensais extends Table {
  TextColumn get mesReferencia => text()();
  RealColumn get rendaTotal => real()();
  RealColumn get totalNecessidade => real().withDefault(const Constant(0))();
  RealColumn get totalDesejo => real().withDefault(const Constant(0))();
  RealColumn get totalInvestimento => real().withDefault(const Constant(0))();
  RealColumn get snapNecessidades => real().withDefault(const Constant(50))();
  RealColumn get snapDesejos => real().withDefault(const Constant(30))();
  RealColumn get snapPoupanca => real().withDefault(const Constant(20))();

  @override
  Set<Column> get primaryKey => {mesReferencia};
}
