// @dart=2.9
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:transloadit/transloadit.dart';

void main() {
  // test('loading secrets', () async {
  //   //TODO
  //   Future<Secret> futureSecret =
  //       SecretLoader(secretPath: "./lib/auth/test.json").load();
  //   Secret secret = await futureSecret;
  //   futureSecret.then((value) => expect(value.apikey, 'test'));
  // });

  group('client tests', () {
    TransloaditClient client = TransloaditClient(
        authKey: '72a70fba93ce41cba617cfd7c2a44b1a',
        authSecret: '3b2845e9330051ed3adc06b4217c42e4f504f8f3');
    test('get assembly id', () async {
      TransloaditResponse response = await client.getAssembly(
          assemblyID: '0fcea03d1cc14b8abfea28db5e377428');
      expect(response.statusCode, 200);
    });

    test('create assembly', () async {
      TransloaditAssembly assembly = client.createAssembly();
      assembly.addStep("import", "/http/import",
          {"url": "https://demos.transloadit.com/inputs/chameleon.jpg"});
      assembly.addStep("resize", "/image/resize", {"height": 400});
      TransloaditResponse response = await assembly.createAssembly();

      expect(response.data["ok"], "ASSEMBLY_COMPLETED");
    });

    test('create assembly with file', () async {
      TransloaditAssembly assembly = client.createAssembly();
      final imagePath = 'test/assets/cat.jpg';
      assembly.addFile(file: File(imagePath));
      assembly.addStep("resize", "/image/resize", {"height": 400});
      TransloaditResponse response = await assembly.createAssembly();

      expect(response.data["ok"], "ASSEMBLY_COMPLETED");
    });
  });
}
