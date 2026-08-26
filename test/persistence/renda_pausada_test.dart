import 'package:app_financeiro/data/db/app_database.dart';
import 'package:app_financeiro/data/repositories/drift_entradas_repository.dart';
import 'package:app_financeiro/domain/entities/entrada.dart';
import 'package:app_financeiro/domain/entities/enums.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pausar uma renda recorrente: ela para de contar nos meses seguintes sem
/// apagar o histórico. Antes disso a única saída para um bico encerrado era
/// excluir — que leva o registro junto.
///
/// O caso que motivou os testes: `Entrada` tem `ativa = true` por padrão no
/// construtor, então qualquer código que remonte a entrada sem repassar o
/// campo **despausa em silêncio**. Foi o que acontecia ao editar.
void main() {
  late AppDatabase db;
  late DriftEntradasRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftEntradasRepository(db);
  });
  tearDown(() => db.close());

  Future<int> criarSalario({String? pausadaDesde, String? retomadaEm}) =>
      repo.criar(Entrada(
        id: 0,
        nome: 'Salário',
        valorLiquido: 5000,
        tipo: TipoEntrada.recorrente,
        diaRecebimento: 5,
        pausadaDesde: pausadaDesde,
        retomadaEm: retomadaEm,
      ));

  test('renda sem pausa entra na renda do mês', () async {
    await criarSalario();
    expect(await repo.rendaDoMes('2026-08'), 5000);
  });

  test('a pausa vale do mês escolhido em diante, e não para trás', () async {
    await criarSalario(pausadaDesde: '2026-08');
    expect(await repo.rendaDoMes('2026-07'), 5000, reason: 'julho é anterior');
    expect(await repo.rendaDoMes('2026-08'), 0);
    expect(await repo.rendaDoMes('2026-09'), 0);
  });

  test('retomar não ressuscita o intervalo pausado', () async {
    await criarSalario(pausadaDesde: '2026-08', retomadaEm: '2026-10');
    expect(await repo.rendaDoMes('2026-08'), 0);
    expect(await repo.rendaDoMes('2026-09'), 0);
    expect(await repo.rendaDoMes('2026-10'), 5000);
  });

  test('pausar não apaga a entrada — ela continua em todas()', () async {
    final id = await criarSalario();
    await repo.atualizar(Entrada(
      id: id,
      nome: 'Salário',
      valorLiquido: 5000,
      tipo: TipoEntrada.recorrente,
      diaRecebimento: 5,
      pausadaDesde: '2026-08',
    ));

    final todas = await repo.todas();
    expect(todas, hasLength(1), reason: 'pausar não é excluir');
    expect(todas.single.pausadaDesde, '2026-08');
    expect(await repo.rendaDoMes('2026-08'), 0);
  });

  test('editar nome e valor preserva a vigência da pausa', () async {
    // O formulário remonta a `Entrada`; esquecer de repassar a vigência
    // despausaria em silêncio, que era o bug do modelo booleano anterior.
    final id = await criarSalario(pausadaDesde: '2026-08', retomadaEm: '2026-10');
    await repo.atualizar(Entrada(
      id: id,
      nome: 'Salário CLT',
      valorLiquido: 5500,
      tipo: TipoEntrada.recorrente,
      diaRecebimento: 5,
      pausadaDesde: '2026-08',
      retomadaEm: '2026-10',
    ));

    final e = (await repo.todas()).single;
    expect(e.nome, 'Salário CLT');
    expect(e.valorLiquido, 5500);
    expect(e.pausadaDesde, '2026-08');
    expect(e.retomadaEm, '2026-10');
    expect(await repo.rendaDoMes('2026-09'), 0, reason: 'editar não despausa');
  });

  test('pausar uma entre várias não afeta as outras', () async {
    await criarSalario();
    await repo.criar(const Entrada(
      id: 0,
      nome: 'Freela',
      valorLiquido: 1200,
      tipo: TipoEntrada.recorrente,
      diaRecebimento: 20,
      pausadaDesde: '2026-08',
    ));
    expect(await repo.rendaDoMes('2026-08'), 5000);
    expect(await repo.rendaDoMes('2026-07'), 6200);
  });

  test('entrada pontual pertence a um mês e ignora a vigência', () async {
    await repo.criar(const Entrada(
      id: 0,
      nome: '13º',
      valorLiquido: 3000,
      tipo: TipoEntrada.pontual,
      mesReferencia: '2026-08',
    ));
    expect(await repo.rendaDoMes('2026-08'), 3000);
    expect(await repo.rendaDoMes('2026-09'), 0);
  });
}
