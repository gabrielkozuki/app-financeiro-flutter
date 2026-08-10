import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:drift/drift.dart';

import '../domain/entities/enums.dart';
import 'db/app_database.dart';

/// Serialização, exportação e limpeza dos dados (RF-19/RF-20). O JSON completo
/// é a base do backup na nuvem (M8) e do backup local; o CSV espelha a checklist
/// mensal que o app substitui.
class ExportService {
  ExportService(this._db);

  final AppDatabase _db;

  /// Backup completo em JSON (todas as tabelas). Formato aberto (RF-19).
  Future<String> exportarJson() async {
    final mapa = <String, dynamic>{
      'versao': _db.schemaVersion,
      'entradas': (await _db.select(_db.entradas).get())
          .map((e) => e.toJson())
          .toList(),
      'contas':
          (await _db.select(_db.contas).get()).map((e) => e.toJson()).toList(),
      'ocorrencias': (await _db.select(_db.ocorrenciasConta).get())
          .map((e) => e.toJson())
          .toList(),
      'cartoes': (await _db.select(_db.cartoes).get())
          .map((e) => e.toJson())
          .toList(),
      'faturas': (await _db.select(_db.faturasCartao).get())
          .map((e) => e.toJson())
          .toList(),
      'rateios': (await _db.select(_db.rateiosFatura).get())
          .map((e) => e.toJson())
          .toList(),
      'configuracoes': (await _db.select(_db.configuracoesMetodologia).get())
          .map((e) => e.toJson())
          .toList(),
      'fechamentos': (await _db.select(_db.fechamentosMensais).get())
          .map((e) => e.toJson())
          .toList(),
    };
    return jsonEncode(mapa);
  }

  /// CSV da checklist de um mês, no formato da planilha manual (RF-19).
  Future<String> exportarCsvMes(String mesReferencia) async {
    final contas = {
      for (final c in await _db.select(_db.contas).get()) c.id: c,
    };
    // Mesmo filtro da checklist: as removidas "só deste mês" (RF-07) continuam
    // gravadas, mas não fazem parte do mês exportado.
    final ocorrencias = await (_db.select(_db.ocorrenciasConta)
          ..where((o) =>
              o.mesReferencia.equals(mesReferencia) & o.removida.equals(false)))
        .get();

    final linhas = <List<dynamic>>[
      ['Conta', 'Grupo', 'Vencimento', 'Planejado', 'Pago', 'Status', 'Parcela'],
    ];
    for (final o in ocorrencias) {
      final c = contas[o.contaId];
      if (c == null) continue;
      linhas.add([
        c.nome,
        c.grupo.rotulo,
        c.diaVencimento,
        o.valorPlanejado.toStringAsFixed(2),
        o.valorPago?.toStringAsFixed(2) ?? '',
        o.status == StatusPagamento.paga ? 'Paga' : 'Pendente',
        o.parcelaAtual != null ? '${o.parcelaAtual}/${c.totalParcelas}' : '',
      ]);
    }

    // As faturas de cartão são linhas da checklist como qualquer outra (RF-22):
    // sem elas, quem concentra os gastos no cartão exporta uma planilha sem o
    // maior gasto do mês. Uma linha por grupo do rateio (RF-23).
    final cartoes = {
      for (final c in await _db.select(_db.cartoes).get()) c.id: c,
    };
    final faturas = await (_db.select(_db.faturasCartao)
          ..where((f) => f.mesReferencia.equals(mesReferencia)))
        .get();
    for (final f in faturas) {
      final cartao = cartoes[f.cartaoId];
      if (cartao == null) continue;
      final rateios = await (_db.select(_db.rateiosFatura)
            ..where((r) => r.faturaCartaoId.equals(f.id)))
          .get();
      final nome = 'Fatura ${cartao.nome}';
      final status = f.status == StatusPagamento.paga ? 'Paga' : 'Pendente';
      if (rateios.isEmpty) {
        // Fatura ainda não subdividida: uma única linha, sem grupo.
        linhas.add([
          nome,
          '',
          cartao.diaVencimento,
          f.valorTotal?.toStringAsFixed(2) ?? '',
          f.valorPago?.toStringAsFixed(2) ?? '',
          status,
          '',
        ]);
        continue;
      }
      // Planejado por grupo = a linha do rateio (que soma o total, RN-08).
      // Pago por grupo = o valor pago rateado na mesma proporção.
      //
      // Atenção: o painel NÃO faz essa proporção — `RatearFatura` soma os
      // valores brutos das linhas. Os dois coincidem porque salvar a fatura
      // força `valorPago == valorTotal` (`fatura_sheet`), e marcar pela
      // checklist não informa valor. Se algum dia der para pagar a fatura por
      // um valor diferente do total, os dois passam a divergir — e aí a regra
      // certa é a do painel, que é a testada (`ratear_fatura_test`).
      final somaRateios = rateios.fold<double>(0, (s, r) => s + r.valor);
      for (final r in rateios) {
        final proporcao = somaRateios == 0 ? 0.0 : r.valor / somaRateios;
        linhas.add([
          nome,
          r.grupo.rotulo,
          cartao.diaVencimento,
          r.valor.toStringAsFixed(2),
          f.valorPago == null
              ? ''
              : (f.valorPago! * proporcao).toStringAsFixed(2),
          status,
          '',
        ]);
      }
    }
    return Csv().encode(linhas);
  }

  /// Apaga todos os dados do app (RF-20). Ordem respeita as chaves estrangeiras.
  Future<void> apagarTudo() async {
    await _db.transaction(() async {
      await _db.delete(_db.rateiosFatura).go();
      await _db.delete(_db.faturasCartao).go();
      await _db.delete(_db.ocorrenciasConta).go();
      await _db.delete(_db.cartoes).go();
      await _db.delete(_db.contas).go();
      await _db.delete(_db.entradas).go();
      await _db.delete(_db.configuracoesMetodologia).go();
      await _db.delete(_db.fechamentosMensais).go();
    });
  }

  /// Restaura o banco a partir de um backup JSON (usado no restore da nuvem, M8).
  /// Substitui todo o estado local pelo conteúdo do backup (last-backup-wins).
  Future<void> importarJson(String jsonStr) async {
    final mapa = jsonDecode(jsonStr) as Map<String, dynamic>;
    List<Map<String, dynamic>> lista(String chave) =>
        ((mapa[chave] as List?) ?? const [])
            .cast<Map<String, dynamic>>();

    await _db.transaction(() async {
      await apagarTudo();
      for (final m in lista('entradas')) {
        await _db.into(_db.entradas).insertOnConflictUpdate(EntradaRow.fromJson(m));
      }
      for (final m in lista('contas')) {
        await _db.into(_db.contas).insertOnConflictUpdate(ContaRow.fromJson(m));
      }
      for (final m in lista('ocorrencias')) {
        await _db
            .into(_db.ocorrenciasConta)
            .insertOnConflictUpdate(OcorrenciaContaRow.fromJson(m));
      }
      for (final m in lista('cartoes')) {
        await _db.into(_db.cartoes).insertOnConflictUpdate(CartaoRow.fromJson(m));
      }
      for (final m in lista('faturas')) {
        await _db
            .into(_db.faturasCartao)
            .insertOnConflictUpdate(FaturaCartaoRow.fromJson(m));
      }
      for (final m in lista('rateios')) {
        await _db
            .into(_db.rateiosFatura)
            .insertOnConflictUpdate(RateioFaturaRow.fromJson(m));
      }
      for (final m in lista('configuracoes')) {
        await _db
            .into(_db.configuracoesMetodologia)
            .insertOnConflictUpdate(ConfiguracaoMetodologiaRow.fromJson(m));
      }
      for (final m in lista('fechamentos')) {
        await _db
            .into(_db.fechamentosMensais)
            .insertOnConflictUpdate(FechamentoMensalRow.fromJson(m));
      }
    });
  }
}
