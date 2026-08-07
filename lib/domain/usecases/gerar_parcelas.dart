import '../entities/conta.dart';
import '../entities/enums.dart';

/// Uma parcela a ser materializada como [OcorrenciaConta] no ato do cadastro
/// (RF-06/RN-03): N ocorrências mensais independentes, uma por mês de referência.
class ParcelaGerada {
  const ParcelaGerada({
    required this.mesReferencia,
    required this.valorPlanejado,
    required this.parcelaAtual,
    required this.totalParcelas,
  });

  final String mesReferencia;
  final double valorPlanejado;
  final int parcelaAtual;
  final int totalParcelas;
}

/// Gera as N parcelas de uma despesa parcelada a partir de um mês inicial.
/// Cada parcela é independente e recebe seu contador (ex.: 3/10).
class GerarParcelas {
  const GerarParcelas();

  List<ParcelaGerada> call({
    required int anoInicial,
    required int mesInicial,
    required double valorParcela,
    required int totalParcelas,
    Recorrencia recorrencia = Recorrencia.parcelada,
  }) {
    assert(totalParcelas >= 1);
    assert(mesInicial >= 1 && mesInicial <= 12);

    final parcelas = <ParcelaGerada>[];
    var ano = anoInicial;
    var mes = mesInicial;

    for (var i = 1; i <= totalParcelas; i++) {
      parcelas.add(ParcelaGerada(
        mesReferencia:
            '${ano.toString().padLeft(4, '0')}-${mes.toString().padLeft(2, '0')}',
        valorPlanejado: valorParcela,
        parcelaAtual: i,
        totalParcelas: totalParcelas,
      ));
      mes++;
      if (mes > 12) {
        mes = 1;
        ano++;
      }
    }
    return parcelas;
  }
}
