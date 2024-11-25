import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Labeling with Firebase ML',
      home: ImageLabelingApp(),
    );
  }
}

class ImageLabelingApp extends StatefulWidget {
  @override
  _ImageLabelingAppState createState() => _ImageLabelingAppState();
}

class _ImageLabelingAppState extends State<ImageLabelingApp> {
  final picker = ImagePicker();
  File? _image;
  List<ImageLabel> _labels = [];

  // Function to pick an image from the gallery or camera
  Future<void> getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      setState(() {
        _image = imageFile;
      });
      detectLabels(imageFile); // Detect labels after selecting an image
    } else {
      print('No image selected.');
    }
  }

  // Function to detect labels in the selected image using ML Kit
  void detectLabels(File image) async {
    final inputImage = InputImage.fromFile(image);
    final ImageLabeler imageLabeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.5),
    );

    try {
      final List<ImageLabel> labels =
          await imageLabeler.processImage(inputImage);
      setState(() {
        _labels = labels;
      });
    } catch (e) {
      print('Error in image labeling: $e');
    } finally {
      imageLabeler.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Labeling with Firebase ML'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => getImage(ImageSource.camera),
              child: Text('Capture Image'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => getImage(ImageSource.gallery),
              child: Text('Select Image from Gallery'),
            ),
            SizedBox(height: 20),
            _image == null
                ? Text('No image selected.')
                : Column(
                    children: [
                      Image.file(_image!, height: 200),
                      SizedBox(height: 20),
                      if (_labels.isNotEmpty)
                        Column(
                          children: [
                            Text(
                              'Detected Labels:',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            ..._labels.map((label) => Text(
                                  '${label.label} (${label.confidence.toStringAsFixed(2)})',
                                )),
                          ],
                        )
                      else
                        Text('No labels detected.'),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
