import 'package:csv/csv.dart';
import 'package:drift/drift.dart';

import '../domain/entities/enums.dart';
import 'db/app_database.dart';

/// Rótulo do grupo na planilha. O CSV é um artefato de dados, com cabeçalhos
/// fixos em pt-BR e sem `BuildContext` — não passa pelo l10n da interface.
String _rotuloGrupo(Grupo grupo) => switch (grupo) {
      Grupo.necessidade => 'Necessidade',
      Grupo.desejo => 'Desejo',
      Grupo.investimento => 'Investimento',
    };

/// Exportação da planilha mensal em CSV (RF-19) — o formato que espelha a
/// checklist manual que o app substitui. O backup completo do banco (JSON)
/// mora em `backup_service.dart`: são propósitos diferentes.
class ExportService {
  ExportService(this._db);

  final AppDatabase _db;

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
        _rotuloGrupo(c.grupo),
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
          _rotuloGrupo(r.grupo),
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
}
