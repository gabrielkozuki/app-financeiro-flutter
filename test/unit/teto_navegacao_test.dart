import 'package:app_financeiro/core/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// O teto de navegação para o futuro não é preferência de UI: abrir um mês
/// futuro **dispara a virada** e grava uma ocorrência por conta ativa. Sem
/// teto, segurar o "›" cria meses que ninguém planejou, que ficam no banco e
/// vão junto no backup da nuvem.
///
/// O passado não tem teto — mês passado nunca é gerado (invariante 1), então
/// navegar para trás não escreve nada.
void main() {
  late ProviderContainer container;
  late MesSelecionadoNotifier notifier;

  DateTime mesRelativo(int delta) {
    final agora = DateTime.now();
    return DateTime(agora.year, agora.month + delta);
  }

  setUp(() {
    container = ProviderContainer();
    notifier = container.read(mesSelecionadoProvider.notifier);
  });
  tearDown(() => container.dispose());

  test('começa no mês corrente', () {
    expect(container.read(mesSelecionadoProvider), mesRelativo(0));
  });

  test('avança até o teto de 12 meses', () {
    for (var i = 0; i < MesSelecionadoNotifier.mesesFuturosMax; i++) {
      notifier.mover(1);
    }
    expect(container.read(mesSelecionadoProvider),
        mesRelativo(MesSelecionadoNotifier.mesesFuturosMax));
  });

  test('para no teto em vez de continuar avançando', () {
    for (var i = 0; i < 40; i++) {
      notifier.mover(1);
    }
    expect(container.read(mesSelecionadoProvider),
        mesRelativo(MesSelecionadoNotifier.mesesFuturosMax),
        reason: 'segurar a seta não pode passar do teto');
  });

  test('podeAvancar vira false exatamente no teto', () {
    for (var i = 0; i < MesSelecionadoNotifier.mesesFuturosMax - 1; i++) {
      notifier.mover(1);
      expect(notifier.podeAvancar, isTrue, reason: 'ainda há folga em +${i + 1}');
    }
    notifier.mover(1);
    expect(notifier.podeAvancar, isFalse);
  });

  test('a grade de mês/ano NÃO contorna o teto', () {
    // `definir` é o caminho do seletor de mês/ano. Barrar só a seta deixaria
    // este caminho gravando meses arbitrários.
    notifier.definir(mesRelativo(60));
    expect(container.read(mesSelecionadoProvider), mesRelativo(0),
        reason: 'fora do teto, a seleção é recusada e o mês não muda');
  });

  test('o passado não tem teto', () {
    for (var i = 0; i < 40; i++) {
      notifier.mover(-1);
    }
    expect(container.read(mesSelecionadoProvider), mesRelativo(-40));
  });

  test('voltar do teto e avançar de novo continua funcionando', () {
    notifier.definir(mesRelativo(MesSelecionadoNotifier.mesesFuturosMax));
    notifier.mover(-1);
    expect(notifier.podeAvancar, isTrue);
    notifier.mover(1);
    expect(container.read(mesSelecionadoProvider),
        mesRelativo(MesSelecionadoNotifier.mesesFuturosMax));
  });
}
