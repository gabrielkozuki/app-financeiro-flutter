import 'package:flutter/material.dart';
import 'package:app_financeiro/models/conta.dart';
import 'package:app_financeiro/utils/formatter.dart';

void main() {
  runApp(const FinancasApp());
}

const Color _kSeed = Color(0xFF0F766E);
const Color _kResumoFundo = Color(0xFFDDF3EF);
const double _kMaxLargura = 480;
const double _kRaio = 16;

class FinancasApp extends StatelessWidget {
  const FinancasApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: _kSeed);
    return MaterialApp(
      title: 'App Finanças: Widgets',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F9F9),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_kRaio),
            side: BorderSide(color: scheme.outlineVariant),
          ),
          color: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
        ),
      ),
      home: const VitrinePage(),
    );
  }
}

class VitrinePage extends StatefulWidget {
  const VitrinePage({super.key});

  @override
  State<VitrinePage> createState() => _VitrinePageState();
}

class _VitrinePageState extends State<VitrinePage> {
  final List<Conta> _contas = List<Conta>.from(contasMock);

  @override
  Widget build(BuildContext context) {
    final contas = [..._contas]
      ..sort((a, b) {
        if (a.paga != b.paga) return a.paga ? 1 : -1;
        return a.diaVencimento.compareTo(b.diaVencimento);
      });
    final pagas = contas.where((c) => c.paga).toList();
    final total = contas.fold(0.0, (s, c) => s + c.valor);
    final pago = pagas.fold(0.0, (s, c) => s + c.valor);

    return Scaffold(
      appBar: AppBar(title: const Text('App Finanças: Widgets')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Teste criar conta')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova conta'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _kMaxLargura),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _seletorMes(),
                _resumoPago(pago, total),
                _cabecalhoContas(pagas.length, contas.length),
                const SizedBox(height: 8),
                for (final conta in contas) _contaTile(conta),
                const SizedBox(height: 64),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _seletorMes() {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Mês anterior',
          ),
          Text('Julho 2026',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              )),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Próximo mês',
          ),
        ],
      ),
    );
  }

  Widget _resumoPago(double pago, double total) {
    final textTheme = Theme.of(context).textTheme;
    final fracao = total == 0 ? 0.0 : (pago / total).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Card(
        color: _kResumoFundo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_kRaio),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pago este mês',
                  style: textTheme.labelLarge?.copyWith(color: _kSeed)),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(brl(pago),
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _kSeed,
                      )),
                  const Spacer(),
                  Text('de ${brl(total)}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: _kSeed.withValues(alpha: 0.8),
                      )),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: fracao,
                  minHeight: 10,
                  backgroundColor: Colors.white.withValues(alpha: 0.7),
                  valueColor: const AlwaysStoppedAnimation(_kSeed),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cabecalhoContas(int pagas, int totalContas) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: [
          Text('Contas mensais', style: textTheme.titleMedium),
          const SizedBox(width: 8),
          Text('$pagas/$totalContas',
              style: textTheme.titleMedium?.copyWith(
                color: _kSeed,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }

  Widget _contaTile(Conta conta) {
    final textTheme = Theme.of(context).textTheme;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Card(
        child: CheckboxListTile(
          value: conta.paga,
          onChanged: (v) => setState(() => conta.paga = v ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_kRaio),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  conta.nome,
                  style: TextStyle(
                    decoration: conta.paga ? TextDecoration.lineThrough : null,
                    color: conta.paga ? onSurfaceVariant : null,
                  ),
                ),
              ),
              Text(brl(conta.valor),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(conta.grupo.icone, size: 14, color: conta.grupo.cor),
                const SizedBox(width: 4),
                Text('${conta.grupo.rotulo} · vencimento dia '
                    '${conta.diaVencimento}',
                    style: textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
