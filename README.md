[![Dart](https://github.com/Missing-Tech/transloadit-flutter-sdk/actions/workflows/dart.yml/badge.svg?branch=main)](https://github.com/Missing-Tech/transloadit-flutter-sdk/actions/workflows/dart.yml)

# Transloadit Flutter SDK

Flutter integration with [Transloadit](https://transloadit.com/)

## Demo App
![image](https://user-images.githubusercontent.com/36996165/125303987-1e810880-e325-11eb-811a-4922e1f0b5d7.png)


## Basic Examples

### Creating client
```dart
TransloaditClient client = TransloaditClient(
        authKey: 'KEY',
        authSecret: 'SECRET');
```

### Getting an assembly
```dart
TransloaditResponse response = await client.getAssembly(
        assemblyID: 'ASSEMBLY_ID');
print(response.statusCode) // 200
```

### Creating an assembly
```dart
TransloaditAssembly assembly = client.newAssembly();

assembly.addStep("import", "/http/import",
        {"url": "https://demos.transloadit.com/inputs/chameleon.jpg"});
assembly.addStep("resize", "/image/resize", {"height": 400});

TransloaditResponse response = await assembly.createAssembly();

print(response['ok']) // "ASSEMBLY_COMPLETED"
```

### Creating a template
```dart
TransloaditTemplate template = client.newTemplate(name: "template");

template.addStep("import", "/http/import",
          {"url": "https://demos.transloadit.com/inputs/chameleon.jpg"});
template.addStep("resize", "/image/resize", {"use": "import", "height": 400});

TransloaditResponse response = await template.createTemplate();

print(response['ok']) // "TEMPLATE_CREATED"
```

### Updating a template
```dart
TransloaditResponse response = await client.updateTemplate(
        templateID: 'TEMPLATE_ID',
        template: {
          "import": {
            "robot": "/http/import",
            "url": "https://demos.transloadit.com/inputs/chameleon.jpg"
          },
          "resize": {"use": "import", "robot": "/image/resize", "height": 200}
        },
      );

print(response['ok']) // "TEMPLATE_UPDATED"
```

### Running template with fields
```dart
TransloaditAssembly assembly = client.runTemplate(
        templateID: 'TEMPLATE_ID', 
        params: {'fields': {'input': 'items.jpg'}});
TransloaditResponse response = await assembly.createAssembly();

print(response.data["ok"]); // "ASSEMBLY_COMPLETED"
```

### Tracking upload progress
```dart
TransloaditResponse response = await assembly.createAssembly(
        onProgress: (progressValue) {
          print(progressValue); // Value from 0-100
        },
        onComplete: () {
          // Do stuff
        }),
      );
```
