// @dart=2.9
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:transloadit/transloadit.dart';

void main() {
  // test('loading secrets', () async {
  //   //TODO implement secret protection
  //   Future<Secret> futureSecret =
  //       SecretLoader(secretPath: "./lib/auth/test.json").load();
  //   Secret secret = await futureSecret;
  //   futureSecret.then((value) => expect(value.apikey, 'test'));
  // });

  TransloaditClient client = TransloaditClient(
      authKey: '72a70fba93ce41cba617cfd7c2a44b1a',
      authSecret: '3b2845e9330051ed3adc06b4217c42e4f504f8f3');

  test('run template', () async {
    TransloaditAssembly assembly = client
        .runTemplate(templateID: 'ddedc05f1b5d4910aa8e3ee341f46053', params: {
      'fields': {'input': 'items.jpg'}
    });
    TransloaditResponse response = await assembly.createAssembly();

    expect(response.data["ok"], "ASSEMBLY_COMPLETED");
  });

  group('create', () {
    test('assembly', () async {
      TransloaditAssembly assembly = client.createAssembly();
      assembly.addStep("import", "/http/import",
          {"url": "https://demos.transloadit.com/inputs/chameleon.jpg"});
      assembly.addStep("resize", "/image/resize", {"height": 400});
      TransloaditResponse response = await assembly.createAssembly();

      expect(response.data["ok"], "ASSEMBLY_COMPLETED");
    });

    test('assembly with file', () async {
      TransloaditAssembly assembly = client.createAssembly();
      final imagePath = 'test/assets/cat.jpg';
      assembly.addFile(file: File(imagePath));
      assembly.addStep("resize", "/image/resize", {"height": 400});
      TransloaditResponse response = await assembly.createAssembly();

      expect(response.data["ok"], "ASSEMBLY_COMPLETED");
    });
  });

  group('get', () {
    test('assembly id', () async {
      TransloaditResponse response = await client.getAssembly(
          assemblyID: '0fcea03d1cc14b8abfea28db5e377428');
      expect(response.statusCode, 200);
    });

    test('assembly url', () async {
      TransloaditResponse response = await client.getAssembly(
          assemblyURL:
              'https://transloadit.com/tickets/assemblies/view/7c1d07f1d71a470c8d70f6045674b4e1');
      expect(response.statusCode, 200);
    });
  });
}
