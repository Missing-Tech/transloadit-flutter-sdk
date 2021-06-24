import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:nock/nock.dart';
import 'package:transloadit/transloadit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final transloaditClient =
      TransloaditClient(authKey: "key", authSecret: "secret");

  setUpAll(() {
    nock.defaultBase = "https://${transloaditClient.service}";
    nock.init();
  });

  setUp(() {
    nock.cleanAll();
  });

  group('client', () {
    test('update template', () async {
      var id = "abcdef12345";
      nock.put(startsWith('/templates/$id'))
        ..reply(
          200,
          '{"ok": "TEMPLATE_UPDATED", "template_id": "$id"}',
        );

      TransloaditResponse tlResponse = await transloaditClient
          .updateTemplate(templateID: id, template: {"name": "foo_bar"});

      expect(tlResponse.statusCode, 200);
      expect(tlResponse.data["ok"], "TEMPLATE_UPDATED");
      expect(tlResponse.data["template_id"], "abcdef12345");
    });

    test('create assembly', () async {
      var id = "abcdef12345";

      nock.post(startsWith("/assemblies"))
        ..reply(
          200,
          '{"ok": "ASSEMBLY_COMPLETED", "assembly_id": "$id"}',
        );

      TransloaditAssembly assembly = transloaditClient.newAssembly();
      TransloaditResponse tlResponse = await assembly.createAssembly();

      expect(tlResponse.statusCode, 200);
      expect(tlResponse.data["ok"], "ASSEMBLY_COMPLETED");
      expect(tlResponse.data["assembly_id"], "abcdef12345");
    });

    test('get assembly', () async {
      var id = "abcdef12345";

      nock.get(startsWith("/assemblies/$id"))
        ..reply(
          200,
          '{"ok": "ASSEMBLY_COMPLETED", "assembly_id": "$id"}',
        );

      print(nock.pendingMocks);

      TransloaditResponse tlResponse =
          await transloaditClient.getAssembly(assemblyID: id);

      expect(tlResponse.statusCode, 200);
      expect(tlResponse.data["ok"], "ASSEMBLY_COMPLETED");
      expect(tlResponse.data["assembly_id"], "abcdef12345");
    });

    test('get template', () async {
      var id = "abcdef12345";

      nock.get(startsWith("/templates/$id"))
        ..reply(
          200,
          '{"ok": "TEMPLATE_COMPLETED", "template_id": "$id"}',
        );

      TransloaditResponse tlResponse =
          await transloaditClient.getTemplate(templateID: id);

      expect(tlResponse.statusCode, 200);
      expect(tlResponse.data["ok"], "TEMPLATE_COMPLETED");
      expect(tlResponse.data["template_id"], "abcdef12345");
    });

    test('cancel assembly', () async {
      var id = "abcdef12345";

      nock.delete(startsWith("/assemblies/$id"))
        ..reply(200, '{}')
        ..persist();

      TransloaditResponse tlResponse =
          await transloaditClient.cancelAssembly(assemblyID: id);

      expect(tlResponse.statusCode, 200);
    });
  });
}
