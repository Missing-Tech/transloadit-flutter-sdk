# Transloadit Flutter SDK

Flutter integration with [Transloadit](https://transloadit.com/)

# WIP

- [x] Create assemblies
- [x] Get assemblies
- [x] Delete assemblies
- [ ] Replay assemblies
- [ ] Retrieve list of assemblies
- [ ] Retrieve month's bill
- [ ] Create templates
- [ ] Get templates
- [ ] Edit templates
- [ ] Delete templates
- [ ] Retrieve list of assemblies
- [x] Run templates

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

### Running template with fields
```dart
TransloaditAssembly assembly = client.runTemplate(
        templateID: 'TEMPLATE_ID', 
        params: {'fields': {'input': 'items.jpg'}});
TransloaditResponse response = await assembly.createAssembly();

print(response.data["ok"]); // "ASSEMBLY_COMPLETED"
```

## Development
To get working tests fill in the values in the .env file.