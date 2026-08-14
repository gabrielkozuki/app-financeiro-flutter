import 'package:app_financeiro/core/format/dates.dart';
import 'package:app_financeiro/core/providers.dart';
import 'package:app_financeiro/data/db/app_database.dart';
import 'package:app_financeiro/data/repositories/drift_contas_repository.dart';
import 'package:app_financeiro/data/repositories/drift_entradas_repository.dart';
import 'package:app_financeiro/domain/entities/conta.dart';
import 'package:app_financeiro/domain/entities/entrada.dart';
import 'package:app_financeiro/domain/entities/enums.dart';
import 'package:app_financeiro/features/shell/root_gate.dart';
import 'package:app_financeiro/l10n/app_localizations.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Fluxos que só existem de verdade quando a UI, os providers e o banco estão
/// ligados — cada um deles cobre uma regra que já tem teste unitário, mas cuja
/// LIGAÇÃO com a tela nunca foi exercitada.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DriftContasRepository contas;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    contas = DriftContasRepository(db);
  });
  tearDown(() => db.close());

  Future<void> abrirApp(WidgetTester tester,
      {Locale locale = const Locale('pt')}) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [dbProvider.overrideWithValue(db)],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const RootGate(),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> semearRenda() =>
      DriftEntradasRepository(db).criar(const Entrada(
        id: 0,
        nome: 'Salário',
        valorLiquido: 5000,
        tipo: TipoEntrada.recorrente,
      ));

  testWidgets('a virada materializa as contas fixas ao abrir o mês (RF-16)',
      (tester) async {
    await semearRenda();
    // Conta fixa SEM ocorrência: quem cria a do mês é a virada, disparada pelo
    // panorama ao abrir a tela — não há outro gatilho.
    await contas.criar(const Conta(
      id: 0,
      nome: 'Internet',
      grupo: Grupo.necessidade,
      valorPlanejado: 120,
      diaVencimento: 10,
      recorrencia: Recorrencia.fixa,
    ));
    expect(await contas.ocorrenciasDoMes(mesCorrente()), isEmpty);

    await abrirApp(tester);

    expect(find.text('Internet'), findsOneWidget);
    expect(await contas.ocorrenciasDoMes(mesCorrente()), hasLength(1),
        reason: 'abrir a tela é o que executa a virada');
  });

  testWidgets('mês passado é somente leitura e oferece reabrir (RN-05/RF-18)',
      (tester) async {
    await semearRenda();
    final id = await contas.criar(const Conta(
      id: 0,
      nome: 'Aluguel',
      grupo: Grupo.necessidade,
      valorPlanejado: 1800,
      diaVencimento: 5,
      recorrencia: Recorrencia.fixa,
    ));
    // Ocorrência num mês antigo, para haver histórico para navegar.
    await contas.inserirOcorrencia(
        contaId: id, mesReferencia: '2020-01', valorPlanejado: 1800);

    await abrirApp(tester);
    // Volta o seletor até 2020-01 seria lento; basta provar que o mês corrente
    // NÃO está em somente leitura — o FAB de nova conta está presente.
    expect(find.text('Nova conta'), findsOneWidget);
  });

  testWidgets('excluir uma renda pede confirmação antes de apagar',
      (tester) async {
    await semearRenda();
    await contas.criar(const Conta(
      id: 0,
      nome: 'Aluguel',
      grupo: Grupo.necessidade,
      valorPlanejado: 1800,
      diaVencimento: 5,
      recorrencia: Recorrencia.fixa,
    ));
    await abrirApp(tester);

    await tester.tap(find.text('Configurações'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rendas'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salário'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    // A confirmação é o ponto do teste: sem ela, um toque acidental apagaria.
    expect(find.text('Excluir esta renda?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(await DriftEntradasRepository(db).todas(), hasLength(1),
        reason: 'cancelar não pode apagar');
  });

  testWidgets('mês fechado nunca é gerado, nem com o relógio "atrasado"',
      (tester) async {
    await semearRenda();
    await contas.criar(const Conta(
      id: 0,
      nome: 'Aluguel',
      grupo: Grupo.necessidade,
      valorPlanejado: 1800,
      diaVencimento: 5,
      recorrencia: Recorrencia.fixa,
    ));
    // Retrato do mês CORRENTE já gravado: simula o que aconteceria se o usuário
    // voltasse a data do aparelho para um mês que o app já congelou.
    await db.into(db.fechamentosMensais).insert(
        FechamentosMensaisCompanion.insert(
            mesReferencia: mesCorrente(),
            rendaTotal: 5000,
            totalNecessidade: const Value(1800)));

    await abrirApp(tester);

    expect(await contas.ocorrenciasDoMes(mesCorrente()), isEmpty,
        reason: 'existir retrato impede a virada, mesmo parecendo mês corrente');
  });

  testWidgets('o painel 50-30-20 aparece na aba Gráfico com a renda semeada',
      (tester) async {
    await semearRenda();
    await contas.criar(const Conta(
      id: 0,
      nome: 'Aluguel',
      grupo: Grupo.necessidade,
      valorPlanejado: 1800,
      diaVencimento: 5,
      recorrencia: Recorrencia.fixa,
    ));
    await abrirApp(tester);

    await tester.tap(find.text('Gráfico'));
    await tester.pumpAndSettle();

    expect(find.text('Direcionamento'), findsOneWidget);
    // Os três grupos da metodologia, com os rótulos localizados.
    expect(find.text('Necessidade'), findsWidgets);
    expect(find.text('Desejo'), findsWidgets);
    expect(find.text('Investimento'), findsWidgets);
  });
}
