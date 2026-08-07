import 'package:flutter/material.dart';

/// Executa uma escrita (banco, arquivo, compartilhamento) sem deixar a falha
/// passar em silêncio: em caso de exceção mostra [mensagemErro] em um SnackBar
/// e devolve `false`, para o chamador decidir se ainda fecha a tela ou recarrega
/// os providers. A exceção vai para o log (`debugPrint`), nunca para o usuário.
///
/// O `finally` do chamador continua responsável por desligar o `_salvando` —
/// aqui nada é relançado, então o formulário nunca fica com o spinner eterno.
Future<bool> executarComFeedback(
  BuildContext context,
  Future<void> Function() acao, {
  required String mensagemErro,
}) async {
  try {
    await acao();
    return true;
  } catch (e, s) {
    debugPrint('$mensagemErro $e\n$s');
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensagemErro)));
    }
    return false;
  }
}
