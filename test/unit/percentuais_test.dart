import 'package:app_financeiro/domain/entities/configuracao.dart';
import 'package:app_financeiro/domain/usecases/percentuais.dart';
import 'package:flutter_test/flutter_test.dart';

/// Validação dos percentuais da metodologia (RF-15): a soma tem de fechar 100.
/// A comparação é feita com tolerância de 0,01 justamente para que uma divisão
/// com casa decimal (33,3/33,3/33,4) não seja recusada por arredondamento.
void main() {
  const validar = ValidarPercentuais();

  ConfiguracaoMetodologia config(double n, double d, double p) =>
      ConfiguracaoMetodologia(
        mesVigenciaInicial: '2026-07',
        percentualNecessidades: n,
        percentualDesejos: d,
        percentualPoupanca: p,
      );

  test('o padrão 50-30-20 é válido', () {
    expect(validar(config(50, 30, 20)), isTrue);
    // O construtor sem percentuais precisa nascer válido: é o que a primeira
    // execução grava e o que `vigenteEm` devolve quando não há configuração.
    expect(
      validar(const ConfiguracaoMetodologia(mesVigenciaInicial: '2026-07')),
      isTrue,
    );
  });

  test('outra distribuição que soma 100 também é válida (70-20-10)', () {
    expect(validar(config(70, 20, 10)), isTrue);
  });

  test('decimais que somam 100 são aceitos (33,3/33,3/33,4)', () {
    expect(validar(config(33.3, 33.3, 33.4)), isTrue);
  });

  test('soma 99 é recusada', () {
    expect(validar(config(33, 33, 33)), isFalse);
  });

  test('soma 101 é recusada', () {
    expect(validar(config(51, 30, 20)), isFalse);
  });

  test('zerar um grupo não torna a configuração válida', () {
    expect(validar(config(50, 30, 0)), isFalse);
    // Mas 100 concentrado em um grupo fecha a conta: a validação é só da soma.
    expect(validar(config(100, 0, 0)), isTrue);
  });

  group('fronteira da tolerância de 0,01', () {
    test('desvio menor que 0,01 passa', () {
      expect(validar(config(50, 30, 20.005)), isTrue); // soma 100,005
      expect(validar(config(50, 30, 19.995)), isTrue); // soma 99,995
    });

    test('desvio de 0,01 ou mais é recusado (a comparação é estrita)', () {
      expect(validar(config(50, 30, 20.01)), isFalse); // soma 100,01
      expect(validar(config(50, 30, 19.99)), isFalse); // soma 99,99
      expect(validar(config(50, 30, 20.02)), isFalse);
    });
  });
}
