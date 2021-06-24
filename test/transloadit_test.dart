import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nock/nock.dart';
import 'package:path/path.dart';
import 'package:transloadit/transloadit.dart';

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

  group('get', () {
    test('assembly', () async {
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

    test('template', () async {
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
  });

  group('file', () {
    TransloaditAssembly assembly = transloaditClient.newAssembly();
    test('add one', () {
      File cat = File('test/assets/cat.jpg');
      assembly.addFile(file: cat, fieldName: "file");
      expect(assembly.files["file"]!.name, cat.path);
    });

    test('add multiple', () {
      File cat = File('test/assets/cat.jpg');
      for (var i = 0; i < 3; i++) {
        assembly.addFile(file: cat, fieldName: "file_$i");
        print(assembly.files);
        expect(assembly.files["file_$i"]!.name, cat.path);
      }
    });
  });

  group('update', () {
    test('template', () async {
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
  });

  group('create', () {
    test('assembly', () async {
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

    test('assembly from template', () async {
      var id = "abcdef12345";

      nock.post(startsWith("/assemblies"))
        ..reply(
          200,
          '{"ok": "ASSEMBLY_COMPLETED", "template_id": "$id"}',
        );

      TransloaditAssembly transloaditAssembly =
          transloaditClient.assemblyFromTemplate(templateID: id);

      TransloaditResponse tlResponse =
          await transloaditAssembly.createAssembly();

      expect(tlResponse.statusCode, 200);
      expect(tlResponse.data["ok"], "ASSEMBLY_COMPLETED");
      expect(tlResponse.data["template_id"], "abcdef12345");
    });

    test('template', () async {
      TransloaditTemplate template =
          transloaditClient.newTemplate(name: "Test");
      nock.post(startsWith("/templates"))
        ..reply(
          200,
          '{"ok": "TEMPLATE_CREATED"}',
        );
      TransloaditResponse tlResponse = await template.createTemplate();
      expect(tlResponse.statusCode, 200);
      expect(tlResponse.data["ok"], "TEMPLATE_CREATED");
    });
  });

  group('delete', () {
    test('assembly', () async {
      var id = "abcdef12345";

      nock.delete(startsWith("/assemblies/$id"))..reply(200, '{}');

      TransloaditResponse tlResponse =
          await transloaditClient.cancelAssembly(assemblyID: id);

      expect(tlResponse.statusCode, 200);
    });

    test('template', () async {
      var id = "abcdef12345";

      nock.delete(startsWith("/templates/$id"))
        ..reply(200, '{"ok": "TEMPLATE_DELETED"}');

      TransloaditResponse tlResponse =
          await transloaditClient.deleteTemplate(templateID: id);

      expect(tlResponse.statusCode, 200);
      expect(tlResponse.data["ok"], "TEMPLATE_DELETED");
    });
  });

  group('options', () {
    TransloaditOptions options = TransloaditOptions();
    options.addStep("import", "/http/import", {
      "url": "https://demos.transloadit.com/inputs/chameleon.jpg",
    });
    options.addStep("resize", "/image/resize", {
      "use": "import",
      "height": 400,
    });

    test('add step', () {
      expect(options.steps, {
        'import': {
          'url': 'https://demos.transloadit.com/inputs/chameleon.jpg',
          'robot': '/http/import'
        },
        'resize': {'use': 'import', 'height': 400, 'robot': '/image/resize'}
      });
    });

    test('remove step', () {
      options.removeStep("import");
      expect(options.steps.containsKey("import"), false);
    });

    test('get', () {
      expect(options.options, {
        "steps": {
          "resize": {"robot": "/image/resize", "use": "import", "height": 400}
        }
      });
    });
  });
}
