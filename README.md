# Transloadit Flutter SDK

Flutter integration with [Transloadit](https://transloadit.com/)

# WIP

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
TransloaditAssembly assembly = client.createAssembly();
final imagePath = 'assets/cat.jpg';

assembly.addStep("import", "/http/import",
        {"url": "https://demos.transloadit.com/inputs/chameleon.jpg"});
assembly.addStep("resize", "/image/resize", {"height": 400});

TransloaditResponse response = await assembly.createAssembly();

print(response['ok']) // "ASSEMBLY_COMPLETED"
```