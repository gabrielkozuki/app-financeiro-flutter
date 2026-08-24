import 'package:firebase_database/firebase_database.dart';

/// Move o backup entre o aparelho e o Realtime Database. **Só isso.**
///
/// A fronteira é deliberada: `BackupService` serializa e valida, este aqui
/// transporta a String e não entende nada do conteúdo. Se algum dia este
/// serviço precisar ler um campo do JSON, a separação foi rompida — a data do
/// backup, por exemplo, sai de `BackupService.geradoEm` sobre o que `baixar`
/// devolveu, não de uma segunda ida à rede.
///
/// Blob por UID em `backups/{uid}`, *last-wins* — sem merge e sem resolução
/// por campo. Quem decide qual lado vence é o usuário, na tela, com a data do
/// backup à vista.
class BackupNuvemService {
  BackupNuvemService([FirebaseDatabase? db])
      : _db = db ?? FirebaseDatabase.instance;

  final FirebaseDatabase _db;

  DatabaseReference _no(String uid) => _db.ref('backups/$uid');

  /// As regras do banco (`auth.uid === $uid`) só deixam escrever no próprio nó,
  /// então um `uid` errado falha no servidor, não em silêncio.
  Future<void> enviar({required String uid, required String json}) =>
      _no(uid).set(json);

  /// `null` quando a conta nunca enviou backup — diferente de backup vazio,
  /// que `BackupService.importarJson` recusa.
  Future<String?> baixar(String uid) async {
    final valor = (await _no(uid).get()).value;
    return valor is String ? valor : null;
  }

  Future<void> apagar(String uid) => _no(uid).remove();
}
