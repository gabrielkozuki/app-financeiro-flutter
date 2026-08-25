import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Driver que grava as capturas em disco. O `integration_test` sozinho não
/// escreve arquivo: ele devolve os bytes ao driver, e é aqui que decidimos
/// onde salvar.
Future<void> main() async {
  final destino = Platform.environment['CAPTURAS_DIR'] ?? 'build/capturas';
  await Directory(destino).create(recursive: true);

  await integrationDriver(
    onScreenshot: (String nome, List<int> bytes, [Map<String, Object?>? args]) async {
      await File('$destino/$nome.png').writeAsBytes(bytes);
      return true;
    },
  );
}
