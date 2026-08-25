import 'package:app_financeiro/core/format/dates.dart';
import 'package:app_financeiro/core/providers.dart';
import 'package:app_financeiro/core/theme/app_theme.dart';
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

/// Gera as capturas de tela da ficha da Play Store.
///
/// Não é teste de regressão — é ferramenta de produção de asset. Roda com:
///   flutter drive --driver=test_driver/integration_test.dart \
///     --target=integration_test/capturas_loja_test.dart -d emulator-5554
///
/// Os dados semeados são deliberados, não aleatórios: renda de R$ 4.200 e
/// necessidades em ~60% da renda. Um mês em que sobra dinheiro e tudo está pago
/// pareceria irreal para quem instala um app de finanças — e o cenário em que
/// as necessidades passam dos 50% é justamente o que o app existe para revelar
/// (persona secundária do documento de requisitos).
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> semear() async {
    final entradas = DriftEntradasRepository(db);
    final contas = DriftContasRepository(db);
    final mes = mesCorrente();

    await entradas.criar(const Entrada(
      id: 0,
      nome: 'Salário',
      valorLiquido: 4200,
      tipo: TipoEntrada.recorrente,
    ));

    // (nome, grupo, valor, dia, pagar?)
    const plano = [
      ('Aluguel', Grupo.necessidade, 1400.0, 5, true),
      ('Mercado', Grupo.necessidade, 850.0, 10, true),
      ('Energia', Grupo.necessidade, 180.0, 20, false),
      ('Internet', Grupo.necessidade, 120.0, 15, false),
      ('Academia', Grupo.desejo, 110.0, 10, true),
      ('Streaming', Grupo.desejo, 55.0, 8, true),
      ('Reserva de emergência', Grupo.investimento, 400.0, 5, false),
    ];

    for (final (nome, grupo, valor, dia, pagar) in plano) {
      final contaId = await contas.criar(Conta(
        id: 0,
        nome: nome,
        grupo: grupo,
        valorPlanejado: valor,
        diaVencimento: dia,
        recorrencia: Recorrencia.fixa,
      ));
      final ocorrenciaId = await contas.inserirOcorrencia(
          contaId: contaId, mesReferencia: mes, valorPlanejado: valor);
      if (pagar) await contas.marcarPaga(ocorrenciaId);
    }
  }

  testWidgets('capturas para a ficha da Play Store', (tester) async {
    await semear();

    await tester.pumpWidget(ProviderScope(
      overrides: [dbProvider.overrideWithValue(db)],
      // Espelha o `FinancasApp` do main.dart. Sem o AppTheme a captura sai com
      // o Material 3 padrão (lilás) em vez do verde-petróleo do app — e sem o
      // `debugShowCheckedModeBanner: false` sai com a faixa DEBUG, porque
      // `flutter drive` builda em debug.
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        // Fixo em claro: a ficha da loja precisa ser determinística, não
        // depender do tema em que o emulador estiver.
        themeMode: ThemeMode.light,
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const RootGate(),
      ),
    ));
    await tester.pumpAndSettle();

    // Obrigatório no Android antes de `takeScreenshot`: converte a surface do
    // Flutter numa imagem legível. Só pode ser chamado uma vez.
    await binding.convertFlutterSurfaceToImage();
    await tester.pumpAndSettle();

    await binding.takeScreenshot('1-contas');

    await tester.tap(find.text('Gráfico'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('2-grafico');

    await tester.tap(find.text('Configurações'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('3-configuracoes');
  });
}
