[![Dart](https://github.com/Missing-Tech/transloadit-flutter-sdk/actions/workflows/dart.yml/badge.svg?branch=main)](https://github.com/Missing-Tech/transloadit-flutter-sdk/actions/workflows/dart.yml)

# flutter-sdk

A **Flutter** integration for [Transloadit](https://transloadit.com/)'s file uploading and encoding service.

## Intro

[Transloadit](https://transloadit.com) is a service that helps you handle file uploads, resize, crop and watermark your images, make GIFs, transcode your videos, extract thumbnails, generate audio waveforms, and so much more. In short, [Transloadit](https://transloadit.com) is the Swiss Army Knife for your files.

This is a **Flutter** SDK to make it easy to talk to the [Transloadit](https://transloadit.com) REST API.


## Install

```
flutter pub add transloadit
```

## Usage

Firstly you need to create a Transloadit client, using your [authentication credentials](https://transloadit.com/accounts/credentials). This will allow us to make requests to the [Transloadit API](https://transloadit.com/docs/api/).
```dart
TransloaditClient client = TransloaditClient(
        authKey: 'KEY',
        authSecret: 'SECRET');
```

### 1. Resize an Image
This example shows how to resize an image using the Transloadit API.

```dart
TransloaditClient client = TransloaditClient(
        authKey: 'KEY',
        authSecret: 'SECRET');

// First we create our assembly
TransloaditAssembly assembly = client.newAssembly();

// Next we add two steps, one to import a file, and another to resize it to 400px tall
assembly.addStep("import", "/http/import",
        {"url": "https://demos.transloadit.com/inputs/chameleon.jpg"});
assembly.addStep("resize", "/image/resize", {"height": 400});

// We then send this assembly to Transloadit to be processed
TransloaditResponse response = await assembly.createAssembly();

print(response['ok']) // "ASSEMBLY_COMPLETED"
```

### 2. Uploading files with an Assembly

A file from a user's device can be included with an Assembly using the `addFile` method.

```dart
TransloaditClient client = TransloaditClient(
        authKey: 'KEY',
        authSecret: 'SECRET');

// First we create our assembly
TransloaditAssembly assembly = client.newAssembly();

// Add a local file to be sent along with the assembly via the Tus protocol
assembly.addFile(file: file!);
assembly.addStep("resize", "/image/resize", {"height": 400});

// We then send this assembly to Transloadit to be processed
TransloaditResponse response = await assembly.createAssembly();

print(response['ok']) // "ASSEMBLY_COMPLETED"
```

### 3. Using a template with fields
```dart
TransloaditClient client = TransloaditClient(
        authKey: 'KEY',
        authSecret: 'SECRET');

// Create an assembly from a template ID
TransloaditAssembly assembly = client.runTemplate(
        templateID: 'TEMPLATE_ID', 
        params: {'fields': {'input': 'items.jpg'}});

// We then send this assembly to Transloadit to be processed
TransloaditResponse response = await assembly.createAssembly();

print(response.data["ok"]); // "ASSEMBLY_COMPLETED"
```

### 4. Tracking Upload Progress
These two callback methods track the progress of the Tus upload, not the Transloadit Assembly.
```dart
TransloaditResponse response = await assembly.createAssembly(
        onProgress: (progressValue) {
          print(progressValue); // Float from 0-100
        },
        onComplete: () {
          // Run on completion
        }),
      );
```

## Example
For a fully working example app, check out [examples/](https://github.com/Missing-Tech/transloadit-flutter-sdk/tree/main/example).

## Documentation
Full documentation for all classes and methods can be found on [pub.dev](https://pub.dev/documentation/transloadit/latest/)