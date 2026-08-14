import 'package:app_financeiro/core/providers.dart';
import 'package:app_financeiro/data/db/app_database.dart';
import 'package:app_financeiro/data/repositories/drift_contas_repository.dart';
import 'package:app_financeiro/data/repositories/drift_entradas_repository.dart';
import 'package:app_financeiro/domain/entities/conta.dart';
import 'package:app_financeiro/domain/entities/entrada.dart';
import 'package:app_financeiro/domain/entities/enums.dart';
import 'package:app_financeiro/features/shell/root_gate.dart';
import 'package:app_financeiro/l10n/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Fluxos ponta a ponta rodando o app de verdade no emulador.
///
/// Complementa (não substitui) `test/unit` e `test/persistence`: aqui o que se
/// verifica é a NAVEGAÇÃO e a ligação entre tela, provider e banco — coisas que
/// teste de regra pura não alcança. As regras de cálculo continuam cobertas lá.
///
/// O banco é substituído por um em memória via override do `dbProvider`, então
/// cada teste começa limpo e não toca no app instalado no aparelho.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// Sobe o app real (`RootGate` + tema + localização), só com o banco trocado.
  ///
  /// O locale é SEMPRE explícito: o emulador pode estar em qualquer idioma, e
  /// um teste que dependesse disso passaria ou falharia conforme a máquina.
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
    // O RootGate abre o banco e decide onboarding vs shell — precisa assentar.
    await tester.pumpAndSettle();
  }

  /// Semeia renda + conta para o app abrir direto no shell, pulando o onboarding
  /// (que é `precisaOnboarding == false` quando já existe conta ou entrada).
  Future<void> semearMesCorrente() async {
    final repoEntradas = DriftEntradasRepository(db);
    await repoEntradas.criar(const Entrada(
      id: 0,
      nome: 'Salário',
      valorLiquido: 5000,
      tipo: TipoEntrada.recorrente,
    ));
    final contas = DriftContasRepository(db);
    await contas.criar(const Conta(
      id: 0,
      nome: 'Aluguel',
      grupo: Grupo.necessidade,
      valorPlanejado: 1800,
      diaVencimento: 5,
      recorrencia: Recorrencia.fixa,
    ));
  }

  testWidgets('instalação limpa abre no onboarding, com a porta "já uso o app"',
      (tester) async {
    await abrirApp(tester);

    // Sem nenhuma conta nem renda, o RootGate manda para o onboarding.
    expect(find.text('Conta em Dia'), findsWidgets);
    // A porta que impede o beco sem saída de aparelho novo (M9/restauração).
    expect(find.text('Já uso o app'), findsOneWidget);
  });

  testWidgets('com dados, abre no shell de 3 abas e navega entre elas',
      (tester) async {
    await semearMesCorrente();
    await abrirApp(tester);

    // Aba Contas é a inicial.
    expect(find.text('Meu mês'), findsOneWidget);
    expect(find.text('Aluguel'), findsOneWidget);

    // CE-02: navegação entre as 3 abas fixas.
    await tester.tap(find.text('Gráfico'));
    await tester.pumpAndSettle();
    expect(find.text('Direcionamento'), findsOneWidget);

    await tester.tap(find.text('Configurações'));
    await tester.pumpAndSettle();
    expect(find.text('Conta e backup'), findsOneWidget);

    await tester.tap(find.text('Contas'));
    await tester.pumpAndSettle();
    expect(find.text('Aluguel'), findsOneWidget);
  });

  testWidgets('marcar uma conta como paga leva 1 toque e persiste (RNF-03)',
      (tester) async {
    await semearMesCorrente();
    await abrirApp(tester);

    final caixa = find.byType(Checkbox).first;
    expect(tester.widget<Checkbox>(caixa).value, isFalse);

    // RNF-03: no máximo 2 toques a partir da tela inicial. Aqui é 1.
    await tester.tap(caixa);
    await tester.pumpAndSettle();

    expect(tester.widget<Checkbox>(find.byType(Checkbox).first).value, isTrue,
        reason: 'a marcação precisa refletir na tela');

    // E precisa ter ido ao banco, não só ao estado do widget.
    final ocorrencias = await db.select(db.ocorrenciasConta).get();
    expect(ocorrencias.single.status, StatusPagamento.paga);
  });

  testWidgets('a interface acompanha o idioma do sistema', (tester) async {
    await semearMesCorrente();
    await abrirApp(tester, locale: const Locale('en'));

    expect(find.text('My month'), findsOneWidget);
    expect(find.text('Bills'), findsWidgets);
    expect(find.text('Meu mês'), findsNothing,
        reason: 'nenhuma string em português deve sobrar em en-US');
  });
}
