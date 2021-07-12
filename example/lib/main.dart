import 'package:universal_io/io.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:transloadit/transloadit.dart';

void main() {
  runApp(MyApp());
}

Map<int, Color> dark = {
  50: Color.fromRGBO(17, 30, 50, .1),
  100: Color.fromRGBO(17, 30, 50, .2),
  200: Color.fromRGBO(17, 30, 50, .3),
  300: Color.fromRGBO(17, 30, 50, .4),
  400: Color.fromRGBO(17, 30, 50, .5),
  500: Color.fromRGBO(17, 30, 50, .6),
  600: Color.fromRGBO(17, 30, 50, .7),
  700: Color.fromRGBO(17, 30, 50, .8),
  800: Color.fromRGBO(17, 30, 50, .9),
  900: Color.fromRGBO(17, 30, 50, 1),
};

Map<int, Color> light = {
  50: Color.fromRGBO(0, 120, 209, .1),
  100: Color.fromRGBO(0, 120, 209, .2),
  200: Color.fromRGBO(0, 120, 209, .3),
  300: Color.fromRGBO(0, 120, 209, .4),
  400: Color.fromRGBO(0, 120, 209, .5),
  500: Color.fromRGBO(0, 120, 209, .6),
  600: Color.fromRGBO(0, 120, 209, .7),
  700: Color.fromRGBO(0, 120, 209, .8),
  800: Color.fromRGBO(0, 120, 209, .9),
  900: Color.fromRGBO(0, 120, 209, 1),
};

MaterialColor transloaditDark = MaterialColor(0xFF111E32, dark);
MaterialColor transloaditLight = MaterialColor(0xFF0078D1, light);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transloadit Demo',
      theme: ThemeData(
          // Define the default brightness and colors.
          brightness: Brightness.light,
          primaryColor: transloaditDark,
          accentColor: transloaditLight,
          sliderTheme: SliderThemeData(
            valueIndicatorColor: transloaditDark,
            activeTrackColor: transloaditDark,
            activeTickMarkColor: transloaditDark,
            thumbColor: transloaditDark,
            inactiveTrackColor: transloaditLight[200],
            inactiveTickMarkColor: Colors.transparent,
            valueIndicatorShape: PaddleSliderValueIndicatorShape(),
          )),
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
  bool imageZoom = false;
  bool isProcessing = false;
  bool uploadComplete = false;
  double progress = 0;

  // Opens a file picker to select an on device file
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'],
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
  Future<void> _processImage() async {
    if (image != null) {
      setState(() {
        isProcessing = true;
      });

      TransloaditClient client = TransloaditClient(
          authKey: '72a70fba93ce41cba617cfd7c2a44b1a',
          authSecret: '3b2845e9330051ed3adc06b4217c42e4f504f8f3');

      TransloaditAssembly assembly = client.newAssembly();

      assembly.addFile(file: image!);
      assembly.addStep("resize", "/image/resize", {
        "rotation": imageRotation,
        "zoom": imageZoom,
        "trim_whitespace": true,
        "transparent": "#FFFFFF",
        "format": "png"
      });

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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _pickFile();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 60,
            ),
            IconButton(
              icon: Icon(
                Icons.send,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _processImage();
                  progress = 0;
                  uploadComplete = false;
                });
              },
            ),
          ],
        ),
        color: transloaditDark,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TransloaditImage(
              isProcessing: isProcessing,
              uploadComplete: uploadComplete,
              progress: progress,
              imageURL: imageURL,
              image: image),
          Expanded(
            child: Column(
              children: [
                TransloaditToggle(
                  text: 'Zoom',
                  value: imageZoom,
                  onChanged: (value) {
                    setState(() {
                      imageZoom = value;
                    });
                  },
                ),
                Divider(),
                TransloaditSlider(
                    text: 'Rotation',
                    value: imageRotation,
                    max: 360,
                    divisions: 12,
                    onChanged: (value) {
                      setState(() {
                        imageRotation = value;
                      });
                    }),
                Divider(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TransloaditSlider extends StatelessWidget {
  const TransloaditSlider({
    Key? key,
    required this.text,
    required this.value,
    required this.max,
    required this.divisions,
    required this.onChanged,
  }) : super(key: key);

  final String text;
  final double value;
  final double max;
  final int divisions;
  final Function(double p1) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 8, 15, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            textScaleFactor: 1.5,
          ),
          Slider(
              value: value,
              min: 0,
              max: max,
              label: value.ceil().toString(),
              divisions: divisions,
              onChanged: onChanged),
        ],
      ),
    );
  }
}

class TransloaditToggle extends StatelessWidget {
  const TransloaditToggle({
    Key? key,
    required this.text,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  final String text;
  final bool value;
  final Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 8, 15, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            textScaleFactor: 1.5,
          ),
          Switch(
              value: value,
              activeColor: transloaditDark,
              activeTrackColor: transloaditLight[200],
              inactiveThumbColor: transloaditDark,
              inactiveTrackColor: transloaditDark[100],
              onChanged: onChanged),
        ],
      ),
    );
  }
}

class TransloaditImage extends StatelessWidget {
  const TransloaditImage({
    Key? key,
    required this.isProcessing,
    required this.uploadComplete,
    required this.progress,
    required this.imageURL,
    required this.image,
  }) : super(key: key);

  final bool isProcessing;
  final bool uploadComplete;
  final double progress;
  final String? imageURL;
  final File? image;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(color: Colors.grey[200]),
          isProcessing
              ? uploadComplete
                  ? CircularProgressIndicator()
                  : Align(
                      alignment: Alignment.bottomCenter,
                      child: LinearProgressIndicator(
                        color: transloaditDark,
                        backgroundColor: transloaditLight[200],
                        value: progress / 100,
                      ),
                    )
              : imageURL != null
                  ? Image.network(imageURL!)
                  : image != null
                      ? Image.file(image!)
                      : Image(
                          image: AssetImage('assets/transloadit.png'),
                        ),
        ],
      ),
    );
  }
}
