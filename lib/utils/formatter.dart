String brl(num valor) {
  final negativo = valor < 0;
  final inteiro = valor.abs().round().toString();
  final buffer = StringBuffer();

  for (int i = 0; i < inteiro.length; i++) {
    if (i > 0 && (inteiro.length - i) % 3 == 0) buffer.write('.');
    buffer.write(inteiro[i]);
  }

  return 'R\$ ${negativo ? '-' : ''}$buffer';
}
