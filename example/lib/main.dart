import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:transloadit/transloadit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transloadit Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(title: 'Transloadit Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? image;
  String? imageURL;
  double imageRotation = 0;
  bool isProcessing = false;
  bool uploadComplete = false;
  double progress = 0;

  // Opens a file picker to select an on device file
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        image = file;
      });
    } else {
      // User canceled the picker
    }
  }

  // Creates a Transloadit assembly to rotate an image by a user-specified amount
  Future<void> _rotateImage() async {
    if (image != null) {
      setState(() {
        isProcessing = true;
      });

      TransloaditClient client =
          TransloaditClient(authKey: 'AUTH_KEY', authSecret: 'AUTH_SECRET');

      TransloaditAssembly assembly = client.newAssembly();

      assembly.addFile(file: image!);
      assembly.addStep("resize", "/image/resize", {"rotation": imageRotation});

      TransloaditResponse response = await assembly.createAssembly(
        onProgress: (progressValue) {
          print(progressValue);
          setState(() {
            progress = progressValue;
          });
        },
        onComplete: () => setState(() => uploadComplete = true),
      );

      setState(() {
        imageURL = response.data['results']['resize'][0]['ssl_url'];
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isProcessing
              ? uploadComplete
                  ? CircularProgressIndicator()
                  : LinearProgressIndicator(
                      value: progress / 100,
                    )
              : Padding(
                  padding: EdgeInsets.all(10),
                  child: imageURL != null
                      ? Image.network(imageURL!)
                      : image != null
                          ? Image.file(image!)
                          : Container(),
                ),
          Slider(
              value: imageRotation,
              min: 0,
              max: 360,
              label: imageRotation.ceil().toString(),
              divisions: 12,
              onChanged: (double value) {
                setState(() {
                  imageRotation = value;
                });
              }),
          TextButton(
            style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue)),
            child: Text('Upload a file'),
            onPressed: () {
              setState(() {
                _pickFile();
              });
            },
          ),
          TextButton(
            style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue)),
            child: Text('Rotate Image'),
            onPressed: () {
              setState(() {
                _rotateImage();
                progress = 0;
                uploadComplete = false;
              });
            },
          ),
        ],
      ),
    );
  }
}
