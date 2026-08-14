import 'package:intl/intl.dart';

/// Nome abreviado do mês (ex.: `Jan.`) a partir do número, no idioma do
/// [locale] — usado na grade do seletor de mês.
String nomeMesAbreviado(int mes, String locale) =>
    _capitalizar(DateFormat.MMM(locale).format(DateTime(2000, mes)));

/// Rótulo "Mês Ano" (ex.: `Julho de 2026`) usado no seletor de mês.
String mesAno(DateTime data, String locale) =>
    _capitalizar(DateFormat.yMMMM(locale).format(data));

/// Data curta na convenção do [locale] (`31/12/2026`, `12/31/2026`) — usada
/// para dizer de quando é um backup.
String dataCurta(DateTime data, String locale) =>
    DateFormat.yMd(locale).format(data);

/// O `intl` devolve o mês em minúscula em pt ("julho de 2026"); as telas o
/// exibem como título.
String _capitalizar(String texto) =>
    texto.isEmpty ? texto : texto[0].toUpperCase() + texto.substring(1);

/// Chave de mês de referência no formato `YYYY-MM`, usada como identificador
/// dos recortes mensais no banco (ver seção 8 do documento de requisitos).
String mesReferencia(DateTime data) =>
    '${data.year.toString().padLeft(4, '0')}-${data.month.toString().padLeft(2, '0')}';

/// O recorte mensal a que "hoje" pertence — o ciclo corrente.
///
/// Ponto ÚNICO dessa definição: todo lugar que precisa saber "que mês é agora"
/// (a virada, a fronteira do passado, a vigência dos percentuais, o mês inicial
/// do seletor, o lançamento de cartão e renda) passa por aqui. Hoje é o
/// mês-calendário (RN-01); quando o ciclo passar a começar no dia do salário
/// (fase 2 do roadmap), esta é a única função a mudar.
String mesCorrente() => mesReferencia(DateTime.now());

/// Um mês é "passado" (candidato a fechado) quando começa antes do ciclo
/// corrente. Como a chave `YYYY-MM` é zero-padded, a comparação textual já é a
/// cronológica — inclusive na virada de ano.
///
/// É a fronteira do invariante mais caro do app: mês passado NUNCA é gerado
/// (RN-05). [referencia] existe para o teste fixar "hoje"; em produção fica
/// nulo e vale o [mesCorrente].
bool ehMesPassado(String mes, {String? referencia}) =>
    mes.compareTo(referencia ?? mesCorrente()) < 0;
