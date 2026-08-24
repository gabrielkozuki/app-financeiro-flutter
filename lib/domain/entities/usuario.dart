/// Usuário autenticado, no mínimo que o app precisa saber.
///
/// Existe para a camada de UI não importar `firebase_auth`: as telas falam com
/// este tipo, e trocar o provedor de autenticação não vaza para `features/`.
/// Não é persistido — vive só enquanto a sessão dura.
class Usuario {
  const Usuario({required this.uid, this.nome, this.email});

  /// Identificador estável da conta. É a chave do backup (`backups/{uid}`).
  final String uid;

  final String? nome;
  final String? email;

  /// O que mostrar na tela: nome quando houver, senão o e-mail, senão nada —
  /// login com Google quase sempre traz os dois, mas nenhum é garantido.
  String? get rotulo => nome?.isNotEmpty == true ? nome : email;
}
