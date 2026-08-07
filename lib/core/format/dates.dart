const List<String> _meses = [
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro',
];

/// Nome do mês em português a partir do número (1 = Janeiro … 12 = Dezembro).
String nomeMes(int mes) => _meses[mes - 1];

/// Rótulo "Mês Ano" (ex.: `Julho 2026`) usado no seletor de mês.
String mesAno(DateTime data) => '${nomeMes(data.month)} ${data.year}';

/// Chave de mês de referência no formato `YYYY-MM`, usada como identificador
/// dos recortes mensais no banco (ver seção 8 do documento de requisitos).
String mesReferencia(DateTime data) =>
    '${data.year.toString().padLeft(4, '0')}-${data.month.toString().padLeft(2, '0')}';
