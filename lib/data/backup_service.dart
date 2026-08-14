import 'dart:convert';

import 'db/app_database.dart';

/// Backup completo do banco em JSON: gerar, restaurar e apagar (RF-19/RF-20).
///
/// É a base do backup em nuvem do M8 — e não sabe NADA de rede: o serviço de
/// nuvem vai apenas mover a String que sai daqui. Fica separado do CSV
/// (`export_service.dart`) porque são propósitos diferentes: aqui é o estado
/// inteiro para restaurar, lá é a planilha de um mês para ler.
class BackupService {
  BackupService(this._db);

  final AppDatabase _db;

  /// Versão do FORMATO do backup — não confundir com o `schemaVersion` do
  /// drift, que descreve o SQLite. Sobe quando a forma do JSON muda de um jeito
  /// que uma versão anterior do app não saberia ler.
  static const formatoBackupAtual = 1;

  /// Backup completo em JSON (todas as tabelas). Formato aberto (RF-19) e base
  /// do backup em nuvem do M8.
  ///
  /// O envelope (`formatoBackup`, `geradoEm`) é o que permite recusar um
  /// arquivo de um app mais novo em vez de truncá-lo em silêncio, e mostrar
  /// "restaurar backup de DD/MM?" sem inventar um lugar extra para a data.
  Future<String> exportarJson() async {
    final mapa = <String, dynamic>{
      'formatoBackup': formatoBackupAtual,
      'geradoEm': DateTime.now().toUtc().toIso8601String(),
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

  /// Data em que o backup foi gerado, para a UI perguntar "restaurar backup de
  /// DD/MM?". Nulo em arquivos anteriores ao envelope.
  static DateTime? geradoEm(String jsonStr) {
    try {
      final mapa = jsonDecode(jsonStr) as Map<String, dynamic>;
      final iso = mapa['geradoEm'] as String?;
      return iso == null ? null : DateTime.tryParse(iso)?.toLocal();
    } catch (_) {
      return null;
    }
  }

  /// Substitui todo o estado local pelo conteúdo do backup (last-backup-wins).
  ///
  /// Valida o envelope ANTES de qualquer escrita e deduplica pelo mesmo
  /// critério da unicidade mensal: dois registros da mesma conta/mês (ou
  /// cartão/mês) fariam o restore inteiro falhar no índice único.
  Future<void> importarJson(String jsonStr) async {
    final Map<String, dynamic> mapa;
    try {
      mapa = jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      throw const BackupInvalidoException(
          'Este arquivo não parece ser um backup do app.');
    }
    if (!mapa.containsKey('contas') && !mapa.containsKey('entradas')) {
      throw const BackupInvalidoException(
          'Este arquivo não parece ser um backup do app.');
    }
    // Ausente = backup anterior ao envelope, que é o formato 1.
    final formato = (mapa['formatoBackup'] as num?)?.toInt() ?? 1;
    if (formato > formatoBackupAtual) {
      throw const BackupInvalidoException(
          'Este backup foi criado por uma versão mais nova do app. '
          'Atualize o app para restaurá-lo.');
    }

    List<Map<String, dynamic>> lista(String chave) =>
        ((mapa[chave] as List?) ?? const [])
            .cast<Map<String, dynamic>>();

    /// Mantém uma linha por chave (conta+mês / cartão+mês), com o MESMO
    /// desempate da checklist: sobrevive a paga; no empate, a de menor id.
    /// Assim nenhum pagamento registrado se perde e fica a linha original.
    /// As chaves do JSON são os nomes dos campos em camelCase (é o que o
    /// `toJson` do drift gera), não os nomes das colunas SQL.
    List<Map<String, dynamic>> semDuplicatasDeMes(
        List<Map<String, dynamic>> linhas, String campoPai) {
      final melhor = <String, Map<String, dynamic>>{};
      for (final m in linhas) {
        final pai = m[campoPai];
        final mes = m['mesReferencia'];
        // Linha sem a chave esperada não é deduplicável: preservar (o índice
        // único do banco decide) é melhor que descartar em silêncio.
        final chave = (pai == null || mes == null) ? 'sem-chave|${m['id']}' : '$pai|$mes';
        final atual = melhor[chave];
        if (atual == null || _melhorQue(candidata: m, atual: atual)) {
          melhor[chave] = m;
        }
      }
      return melhor.values.toList();
    }

    final ocorrencias = semDuplicatasDeMes(lista('ocorrencias'), 'contaId');
    final faturas = semDuplicatasDeMes(lista('faturas'), 'cartaoId');
    final idsDeFatura = {for (final f in faturas) f['id']};

    await _db.transaction(() async {
      await apagarTudo();
      for (final m in lista('entradas')) {
        await _db.into(_db.entradas).insertOnConflictUpdate(EntradaRow.fromJson(m));
      }
      for (final m in lista('contas')) {
        await _db.into(_db.contas).insertOnConflictUpdate(ContaRow.fromJson(m));
      }
      for (final m in ocorrencias) {
        await _db
            .into(_db.ocorrenciasConta)
            .insertOnConflictUpdate(OcorrenciaContaRow.fromJson(m));
      }
      for (final m in lista('cartoes')) {
        await _db.into(_db.cartoes).insertOnConflictUpdate(CartaoRow.fromJson(m));
      }
      for (final m in faturas) {
        await _db
            .into(_db.faturasCartao)
            .insertOnConflictUpdate(FaturaCartaoRow.fromJson(m));
      }
      // Rateio de fatura descartada sairia órfão e somaria no painel sem dono.
      for (final m in lista('rateios')
          .where((r) => idsDeFatura.contains(r['faturaCartaoId']))) {
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

/// Desempate entre dois registros da mesma chave mensal: a paga vence; no
/// empate, a de menor id (a original, não a cópia acidental).
bool _melhorQue({
  required Map<String, dynamic> candidata,
  required Map<String, dynamic> atual,
}) {
  final sc = (candidata['status'] as num?)?.toInt() ?? 0;
  final sa = (atual['status'] as num?)?.toInt() ?? 0;
  if (sc != sa) return sc > sa;
  final ic = (candidata['id'] as num?)?.toInt() ?? 0;
  final ia = (atual['id'] as num?)?.toInt() ?? 0;
  return ic < ia;
}

/// Backup ilegível ou gerado por uma versão mais nova do app. Tem tipo próprio
/// para a tela dizer o que houve, em vez do "não foi possível" genérico.
class BackupInvalidoException implements Exception {
  const BackupInvalidoException(this.mensagem);
  final String mensagem;

  @override
  String toString() => mensagem;
}
