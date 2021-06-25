import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nock/nock.dart';
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

      TransloaditResponse tlResponse =
          await transloaditClient.getAssembly(assemblyID: id);

      expect(tlResponse.statusCode, 200);
      expect(tlResponse.data["ok"], "ASSEMBLY_COMPLETED");
      expect(tlResponse.data["assembly_id"], "abcdef12345");
    });

    test('list of assemblies', () async {
      var id = "abcdef12345";

      nock.get(startsWith("/assemblies"))
        ..reply(
          200,
          '{"ok": "ASSEMBLY_COMPLETED", "assembly_id": "$id"}',
        );

      TransloaditResponse tlResponse = await transloaditClient.listAssemblies();

      expect(tlResponse.statusCode, 200);
      expect(tlResponse.data["ok"], "ASSEMBLY_COMPLETED");
      expect(tlResponse.data["assembly_id"], "abcdef12345");
    });

    test('list of assembly notifications', () async {
      var id = "abcdef12345";

      nock.get(startsWith("/assembly_notifications"))
        ..reply(
          200,
          '{"ok": "FOUND_NOTIFICATIONS", "assembly_id": "$id"}',
        );

      TransloaditResponse tlResponse =
          await transloaditClient.getAssemblyNotifications();

      expect(tlResponse.statusCode, 200);
      expect(tlResponse.data["ok"], "FOUND_NOTIFICATIONS");
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
      File cat = File('cat.jpg');
      assembly.addFile(file: cat, fieldName: "file");
      expect(assembly.files["file"]!.path, cat.path);
    });

    test('add multiple', () {
      File cat = File('cat.jpg');
      for (var i = 0; i < 3; i++) {
        assembly.addFile(file: cat, fieldName: "file_$i");
        expect(assembly.files["file_$i"]!.path, cat.path);
      }
    });

    test('remove', () {
      File cat = File('cat.jpg');
      assembly.addFile(file: cat, fieldName: "remove_me");
      expect(assembly.files["remove_me"]!.path, cat.path);
      assembly.removeFile(fieldName: "remove_me");
      expect(assembly.files.containsKey("remove_me"), false);
    });

    test('remove all', () {
      File cat = File('cat.jpg');
      assembly.addFile(file: cat, fieldName: "file");
      expect(assembly.files["file"]!.path, cat.path);
      assembly.clearFiles();
      expect(assembly.files.length, 0);
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

    test('replay assembly', () async {
      var id = "abcdef12345";

      nock.post(startsWith("/assemblies/$id/replay"))
        ..reply(
          200,
          '{"ok": "ASSEMBLY_REPLAYING"}',
        );

      TransloaditResponse tlResponse =
          await transloaditClient.replayAssembly(assemblyID: id);

      expect(tlResponse.statusCode, 200);
      expect(tlResponse.data["ok"], "ASSEMBLY_REPLAYING");
    });

    test('replay assembly notification', () async {
      var id = "abcdef12345";

      nock.post(startsWith("/assembly_notification/$id/replay"))
        ..reply(
          200,
          '{"ok": "ASSEMBLY_REPLAYING"}',
        );

      TransloaditResponse tlResponse =
          await transloaditClient.replayAssembly(assemblyID: id);

      expect(tlResponse.statusCode, 200);
      expect(tlResponse.data["ok"], "ASSEMBLY_REPLAYING");
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
