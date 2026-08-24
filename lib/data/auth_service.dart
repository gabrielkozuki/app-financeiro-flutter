import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../domain/entities/usuario.dart';

/// Autenticação com a conta Google, via Firebase Auth.
///
/// **Só Google.** Foi decidido contra e-mail/senha porque o login aqui existe
/// para dar backup: uma senha esquecida transformaria a rede de proteção na
/// própria perda de dados. Com o Google, recuperar a conta é problema do
/// Google. E, como o app sai só na Play Store, todo usuário já tem uma.
///
/// "Entrar com a Apple" fica para quando o iOS entrar — `sign_in_with_apple`
/// exige conta paga no Apple Developer Program.
class AuthService {
  /// Client **web** (`client_type: 3` no `google-services.json`), não o Android.
  /// É a audiência do `idToken` que o Firebase valida; passar o Android aqui
  /// gera token que o Firebase recusa.
  static const _serverClientId =
      '548283748086-ttvq6muqpo2p7s6rjh2hptorso916pa9.apps.googleusercontent.com';

  final _auth = FirebaseAuth.instance;
  bool _googleIniciado = false;

  /// O `initialize` da 7.x é obrigatório e só pode rodar uma vez. Fica
  /// preguiçoso em vez de no `main` para não custar nada a quem nunca entra —
  /// o app inteiro funciona sem conta (RNF-01/RNF-04).
  Future<void> _garantirGoogle() async {
    if (_googleIniciado) return;
    await GoogleSignIn.instance.initialize(serverClientId: _serverClientId);
    _googleIniciado = true;
  }

  Usuario? get atual => _converter(_auth.currentUser);

  /// Emite a cada login/logout, inclusive os que o próprio Firebase dispara
  /// (token revogado, conta excluída em outro aparelho).
  Stream<Usuario?> get mudancas => _auth.authStateChanges().map(_converter);

  /// Devolve `null` quando o usuário fecha a folha do Google sem escolher
  /// conta — cancelar não é erro e não deve virar SnackBar de falha.
  Future<Usuario?> entrarComGoogle() async {
    await _garantirGoogle();
    final GoogleSignInAccount conta;
    try {
      conta = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }

    final idToken = conta.authentication.idToken;
    if (idToken == null) {
      throw Exception('Google não devolveu idToken — confira o SHA-1 no '
          'Firebase e se o google-services.json é o baixado DEPOIS de '
          'registrá-lo (precisa ter oauth_client com client_type 1).');
    }

    final credencial = GoogleAuthProvider.credential(idToken: idToken);
    return _converter((await _auth.signInWithCredential(credencial)).user);
  }

  /// Sai das duas pontas. Sem o `signOut` do Google, o próximo login reusa a
  /// conta anterior em silêncio e não há como trocar de usuário.
  Future<void> sair() async {
    await _garantirGoogle();
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }

  /// Exclui a conta no provedor de identidade. Apagar o `backups/{uid}` é
  /// responsabilidade de quem chama — ver `BackupNuvemService.apagar` — e tem
  /// que acontecer ANTES, porque depois disto não há mais uid autenticado
  /// para as regras do banco aceitarem a escrita.
  ///
  /// `disconnect` revoga o consentimento do Google; sem ele a conta some do
  /// Firebase mas o app continua autorizado no lado do Google.
  Future<void> excluirConta() async {
    final usuario = _auth.currentUser;
    if (usuario == null) return;
    await _garantirGoogle();
    await GoogleSignIn.instance.disconnect();
    await usuario.delete();
  }

  Usuario? _converter(User? u) => u == null
      ? null
      : Usuario(uid: u.uid, nome: u.displayName, email: u.email);
}
