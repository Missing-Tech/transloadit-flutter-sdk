# Transloadit Flutter SDK

Flutter integration with [Transloadit](https://transloadit.com/)

# WIP

## Basic Example

```dart
TransloaditClient client = TransloaditClient(
        authKey: 'KEY',
        authSecret: 'SECRET');
TransloaditResponse response = await client.getAssembly(
        assemblyID: 'ASSEMBLY_ID');
print(response.statusCode) // 200
```
