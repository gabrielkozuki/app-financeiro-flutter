import 'dart:convert';

import 'package:app_financeiro/data/db/app_database.dart';
import 'package:app_financeiro/data/export_service.dart';
import 'package:app_financeiro/data/repositories/drift_cartoes_repository.dart';
import 'package:app_financeiro/data/repositories/drift_contas_repository.dart';
import 'package:app_financeiro/domain/entities/cartao.dart';
import 'package:app_financeiro/domain/entities/conta.dart';
import 'package:app_financeiro/domain/entities/enums.dart';
import 'package:app_financeiro/domain/usecases/gerar_mes.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Contrato do esquema local. Duas garantias que não aparecem em nenhuma tela,
/// mas que corrompem dado quando quebram:
/// 1. os enums são persistidos como ÍNDICE (`intEnum`), logo a ORDEM das
///    constantes é contrato — reordenar reclassifica em silêncio tudo o que já
///    está gravado (e todos os backups JSON);
/// 2. uma conta tem no máximo uma ocorrência por mês e um cartão no máximo uma
///    fatura por mês — é o que torna a virada (RF-16) idempotente.
void main() {
  late AppDatabase db;
  late DriftContasRepository contas;
  late DriftCartoesRepository cartoes;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    contas = DriftContasRepository(db);
    cartoes = DriftCartoesRepository(db);
  });
  tearDown(() => db.close());

  Conta contaFixa(String nome) => Conta(
        id: 0,
        nome: nome,
        grupo: Grupo.desejo,
        valorPlanejado: 100,
        diaVencimento: 10,
        recorrencia: Recorrencia.parcelada,
        totalParcelas: 3,
      );

  /// Mesma sequência que a virada executa (RF-16): consulta o que já existe no
  /// mês, decide pelo caso de uso e insere o que falta.
  Future<void> virada(String mes) async {
    final gerado = const GerarMes()(
      mesReferencia: mes,
      contasFixasAtivas: await contas.listarFixasAtivas(),
      contaIdsComOcorrenciaNoMes: await contas.contaIdsComOcorrenciaNoMes(mes),
      cartoesAtivos: await cartoes.listarAtivos(),
      cartaoIdsComFaturaNoMes: await cartoes.cartaoIdsComFaturaNoMes(mes),
    );
    for (final o in gerado.ocorrencias) {
      await contas.inserirOcorrencia(
        contaId: o.contaId,
        mesReferencia: o.mesReferencia,
        valorPlanejado: o.valorPlanejado,
      );
    }
    for (final f in gerado.faturas) {
      await cartoes.criarFatura(
          cartaoId: f.cartaoId, mesReferencia: f.mesReferencia);
    }
  }

  group('Enums persistidos como índice', () {
    test('a ordem das constantes é contrato de persistência', () {
      expect(Grupo.values,
          [Grupo.necessidade, Grupo.desejo, Grupo.investimento]);
      expect(Recorrencia.values,
          [Recorrencia.fixa, Recorrencia.pontual, Recorrencia.parcelada]);
      expect(TipoEntrada.values,
          [TipoEntrada.recorrente, TipoEntrada.pontual]);
      expect(StatusPagamento.values,
          [StatusPagamento.pendente, StatusPagamento.paga]);
    });

    test('a conta grava grupo e recorrência com o índice esperado', () async {
      final id = await contas.criar(contaFixa('Streaming'));

      final row = await db
          .customSelect(
            'SELECT grupo, recorrencia FROM contas WHERE id = ?',
            variables: [Variable.withInt(id)],
          )
          .getSingle();
      expect(row.read<int>('grupo'), 1); // Grupo.desejo
      expect(row.read<int>('recorrencia'), 2); // Recorrencia.parcelada
    });

    test('o backup JSON carrega o índice, não o nome do valor', () async {
      await contas.criar(contaFixa('Streaming'));

      final backup = jsonDecode(await ExportService(db).exportarJson())
          as Map<String, dynamic>;
      final conta = (backup['contas'] as List).single as Map<String, dynamic>;
      expect(conta['grupo'], 1);
      expect(conta['recorrencia'], 2);
      // Por isso reordenar um enum não quebra só o banco do aparelho: todo
      // backup já gerado passaria a ser restaurado com outra classificação.
    });
  });

  group('Unicidade do recorte mensal', () {
    test('inserir a mesma conta duas vezes no mês não duplica a linha',
        () async {
      final id = await contas.criar(contaFixa('Aluguel'));
      await contas.inserirOcorrencia(
          contaId: id, mesReferencia: '2026-07', valorPlanejado: 100);
      await contas.inserirOcorrencia(
          contaId: id, mesReferencia: '2026-07', valorPlanejado: 999);

      final doMes = await contas.ocorrenciasDoMes('2026-07');
      expect(doMes, hasLength(1));
      // A segunda inserção não faz nada: o valor original permanece.
      expect(doMes.single.valorPlanejado, 100);
    });

    test('criar a fatura do mesmo cartão duas vezes no mês não duplica',
        () async {
      final cartaoId = await cartoes
          .criar(const Cartao(id: 0, nome: 'Nubank', diaVencimento: 15));
      await cartoes.criarFatura(cartaoId: cartaoId, mesReferencia: '2026-07');
      await cartoes.criarFatura(cartaoId: cartaoId, mesReferencia: '2026-07');

      expect(await cartoes.faturasDoMes('2026-07'), hasLength(1));
    });

    test('gerar o mesmo mês duas vezes não duplica ocorrência nem fatura',
        () async {
      await contas.criar(Conta(
        id: 0,
        nome: 'Aluguel',
        grupo: Grupo.necessidade,
        valorPlanejado: 1200,
        diaVencimento: 5,
        recorrencia: Recorrencia.fixa,
      ));
      await cartoes.criar(const Cartao(id: 0, nome: 'Nubank', diaVencimento: 15));

      await virada('2026-07');
      await virada('2026-07');

      expect(await contas.ocorrenciasDoMes('2026-07'), hasLength(1));
      expect(await cartoes.faturasDoMes('2026-07'), hasLength(1));
    });

    test('duas viradas concorrentes não duplicam o mês', () async {
      await contas.criar(Conta(
        id: 0,
        nome: 'Aluguel',
        grupo: Grupo.necessidade,
        valorPlanejado: 1200,
        diaVencimento: 5,
        recorrencia: Recorrencia.fixa,
      ));
      await cartoes.criar(const Cartao(id: 0, nome: 'Nubank', diaVencimento: 15));

      // Caso que a checagem prévia do caso de uso NÃO cobre: as duas execuções
      // consultam o mês vazio antes de qualquer inserção e ambas decidem
      // inserir. Quem segura a duplicata aqui é a unicidade do banco.
      await Future.wait([virada('2026-07'), virada('2026-07')]);

      expect(await contas.ocorrenciasDoMes('2026-07'), hasLength(1));
      expect(await cartoes.faturasDoMes('2026-07'), hasLength(1));
    });
  });
}
