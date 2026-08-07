import 'package:app_financeiro/domain/entities/configuracao.dart';
import 'package:app_financeiro/domain/entities/enums.dart';
import 'package:app_financeiro/domain/usecases/calcular_metodologia.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regras do painel 50-30-20 (RF-12..14) — funções puras, sem Flutter/banco.
void main() {
  const calcular = CalcularMetodologia();
  const config = ConfiguracaoMetodologia(mesVigenciaInicial: '2026-07');

  test('distribui os limites 50-30-20 sobre a renda', () {
    final r = calcular(
      renda: 3000,
      comprometidoPorGrupo: const {
        Grupo.necessidade: 1560,
        Grupo.desejo: 690,
        Grupo.investimento: 450,
      },
      config: config,
    );

    expect(r.item(Grupo.necessidade).limite, 1500);
    expect(r.item(Grupo.desejo).limite, 900);
    expect(r.item(Grupo.investimento).limite, 600);
    expect(r.totalComprometido, 2700);
    expect(r.livreParaGastar, 300);
    expect(r.percentualLivre, closeTo(10, 0.001));
  });

  test('sinaliza acima/abaixo da meta de forma neutra (RF-13)', () {
    final r = calcular(
      renda: 3000,
      comprometidoPorGrupo: const {
        Grupo.necessidade: 1560, // 52% > 50%
        Grupo.desejo: 690, // 23% < 30%
        Grupo.investimento: 450, // 15% < 20%
      },
      config: config,
    );

    expect(r.item(Grupo.necessidade).situacao, Situacao.acima);
    expect(r.item(Grupo.desejo).situacao, Situacao.abaixo);
    expect(r.item(Grupo.investimento).situacao, Situacao.abaixo);
    expect(r.item(Grupo.necessidade).percentualRealizado, closeTo(52, 0.001));
  });

  test('renda variável: necessidades podem consumir 90% (cenário Rafael)', () {
    final r = calcular(
      renda: 1000,
      comprometidoPorGrupo: const {Grupo.necessidade: 900},
      config: config,
    );
    expect(r.item(Grupo.necessidade).percentualRealizado, closeTo(90, 0.001));
    expect(r.item(Grupo.necessidade).situacao, Situacao.acima);
    expect(r.livreParaGastar, 100);
  });

  test('livre para gastar pode ser negativo sem quebrar a fatia Livre', () {
    final r = calcular(
      renda: 1000,
      comprometidoPorGrupo: const {Grupo.necessidade: 1200},
      config: config,
    );
    expect(r.livreParaGastar, -200);
    expect(r.percentualLivre, 0);
  });

  test('renda zero não divide por zero', () {
    final r = calcular(
      renda: 0,
      comprometidoPorGrupo: const {Grupo.necessidade: 100},
      config: config,
    );
    expect(r.item(Grupo.necessidade).percentualRealizado, 0);
    expect(r.percentualLivre, 0);
    expect(r.livreParaGastar, -100);
  });

  test('percentuais configuráveis (70-20-10) mudam os limites', () {
    const alt = ConfiguracaoMetodologia(
      mesVigenciaInicial: '2026-07',
      percentualNecessidades: 70,
      percentualDesejos: 20,
      percentualPoupanca: 10,
    );
    final r = calcular(renda: 2000, comprometidoPorGrupo: const {}, config: alt);
    expect(r.item(Grupo.necessidade).limite, 1400);
    expect(r.item(Grupo.desejo).limite, 400);
    expect(r.item(Grupo.investimento).limite, 200);
  });
}
