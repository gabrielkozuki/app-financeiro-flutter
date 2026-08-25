import 'dart:convert';
import 'dart:io' show Platform;

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../domain/entities/usuario.dart';

/// Autenticação via Firebase Auth: **Google** e, no iOS, **Apple**.
///
/// **Sem e-mail/senha**, por decisão: o login aqui existe para dar backup, e
/// uma senha esquecida transformaria a rede de proteção na própria perda de
/// dados. Com provedor de identidade, recuperar a conta é problema dele.
///
/// "Entrar com a Apple" é exigência da diretriz 4.8 da App Store quando há
/// login de terceiros — não é opcional lá. No Android fica oculto: o
/// `sign_in_with_apple` cairia num fluxo web, e um caminho pior para uma
/// exigência que não vale naquela loja.
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

  /// Onde faz sentido oferecer "Entrar com a Apple". Fora do ecossistema
  /// Apple o pacote cai num fluxo web, que é pior que o login do Google e não
  /// é exigido por loja nenhuma.
  static bool get appleDisponivel => Platform.isIOS || Platform.isMacOS;

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

  /// Login com Apple. Devolve `null` quando o usuário cancela.
  ///
  /// O `nonce` não é zelo extra: o Firebase **recusa** o token sem ele. Vai o
  /// hash SHA-256 para a Apple e o valor cru para o Firebase, que refaz o hash
  /// e compara — é o que impede reaproveitar um token interceptado.
  Future<Usuario?> entrarComApple() async {
    final cruz = generateNonce();
    final AuthorizationCredentialAppleID credencialApple;
    try {
      credencialApple = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: sha256.convert(utf8.encode(cruz)).toString(),
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return null;
      rethrow;
    }

    final credencial = OAuthProvider('apple.com').credential(
      idToken: credencialApple.identityToken,
      rawNonce: cruz,
    );
    final usuario = (await _auth.signInWithCredential(credencial)).user;

    // A Apple só manda nome e e-mail no PRIMEIRO login daquela conta; nas
    // vezes seguintes vêm nulos. Sem gravar agora, o app fica sem nome para
    // sempre — e não há como pedir de novo sem o usuário revogar o acesso nos
    // ajustes do aparelho.
    final nome = [
      credencialApple.givenName,
      credencialApple.familyName,
    ].whereType<String>().join(' ').trim();
    if (usuario != null && nome.isNotEmpty && usuario.displayName == null) {
      await usuario.updateDisplayName(nome);
      await usuario.reload();
      return _converter(_auth.currentUser);
    }
    return _converter(usuario);
  }

  /// Sai das duas pontas. Sem o `signOut` do Google, o próximo login reusa a
  /// conta anterior em silêncio e não há como trocar de usuário.
  /// Sair da Apple não existe como operação: quem controla a sessão é o
  /// sistema, e revogar o acesso é feito nos Ajustes do aparelho. Sair do
  /// Firebase basta.
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
    // `disconnect` revoga o consentimento no lado do Google. Só faz sentido
    // para quem entrou por lá; para a Apple, a revogação é responsabilidade do
    // usuário nos Ajustes, e o `delete()` já remove a conta no Firebase.
    final porGoogle = usuario.providerData
        .any((p) => p.providerId == GoogleAuthProvider.PROVIDER_ID);
    if (porGoogle) {
      await _garantirGoogle();
      await GoogleSignIn.instance.disconnect();
    }
    await usuario.delete();
  }

  Usuario? _converter(User? u) => u == null
      ? null
      : Usuario(uid: u.uid, nome: u.displayName, email: u.email);
}
