import 'package:app_financeiro/domain/entities/cartao.dart';
import 'package:app_financeiro/domain/entities/conta.dart';
import 'package:app_financeiro/domain/entities/enums.dart';
import 'package:app_financeiro/domain/usecases/gerar_mes.dart';
import 'package:flutter_test/flutter_test.dart';

/// Geração da checklist do mês na virada (RF-16) — idempotente e sem tocar
/// meses anteriores (RN-05).
void main() {
  const gerar = GerarMes();

  Conta conta(int id, {Recorrencia rec = Recorrencia.fixa, bool ativa = true}) =>
      Conta(
        id: id,
        nome: 'Conta $id',
        grupo: Grupo.necessidade,
        valorPlanejado: 100,
        diaVencimento: 5,
        recorrencia: rec,
        ativa: ativa,
      );

  test('gera ocorrências das contas fixas ativas sem ocorrência no mês', () {
    final r = gerar(
      mesReferencia: '2026-08',
      contasFixasAtivas: [conta(1), conta(2)],
      contaIdsComOcorrenciaNoMes: const {},
      cartoesAtivos: const [],
      cartaoIdsComFaturaNoMes: const {},
    );
    expect(r.ocorrencias.length, 2);
    expect(r.ocorrencias.first.mesReferencia, '2026-08');
    expect(r.ocorrencias.first.valorPlanejado, 100);
  });

  test('é idempotente: não duplica ocorrência já existente', () {
    final r = gerar(
      mesReferencia: '2026-08',
      contasFixasAtivas: [conta(1), conta(2)],
      contaIdsComOcorrenciaNoMes: const {1},
      cartoesAtivos: const [],
      cartaoIdsComFaturaNoMes: const {},
    );
    expect(r.ocorrencias.length, 1);
    expect(r.ocorrencias.single.contaId, 2);
  });

  test('ignora contas pausadas e não-fixas (parcelas/pontuais)', () {
    final r = gerar(
      mesReferencia: '2026-08',
      contasFixasAtivas: [
        conta(1, ativa: false),
        conta(2, rec: Recorrencia.parcelada),
        conta(3, rec: Recorrencia.pontual),
      ],
      contaIdsComOcorrenciaNoMes: const {},
      cartoesAtivos: const [],
      cartaoIdsComFaturaNoMes: const {},
    );
    expect(r.ocorrencias, isEmpty);
  });

  test('gera fatura para cartões ativos sem fatura no mês', () {
    final r = gerar(
      mesReferencia: '2026-08',
      contasFixasAtivas: const [],
      contaIdsComOcorrenciaNoMes: const {},
      cartoesAtivos: [
        const Cartao(id: 10, nome: 'Nubank', diaVencimento: 12),
        const Cartao(id: 11, nome: 'Inter', diaVencimento: 8),
      ],
      cartaoIdsComFaturaNoMes: const {10},
    );
    expect(r.faturas.length, 1);
    expect(r.faturas.single.cartaoId, 11);
  });
}
