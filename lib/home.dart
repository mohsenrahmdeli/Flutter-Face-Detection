import 'dart:io';
import 'dart:typed_data';
import 'package:face_detection/image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Face> _faces = [];
  final faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate));
  XFile? _optedImage;
  Uint8List? _optedImageData;

  final _border =
      const Border(top: BorderSide(width: 1, color: Colors.black26));

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    faceDetector.close();
    super.dispose();
  }

  void _pickImage() async {
    _optedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (_optedImage != null) {
      _optedImageData = await _optedImage!.readAsBytes();
      _detectedFaces();
    }
  }

  void _detectedFaces() async {
    final faces = await faceDetector
        .processImage(InputImage.fromFilePath(_optedImage!.path));
    _faces = [...faces];
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Face Detection"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Flexible(
                flex: 2,
                child: Container(
                  color: Colors.white,
                  child: _optedImage != null
                      ? Image.file(
                          File(_optedImage!.path),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),
              Flexible(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: _border,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _optedImage != null
                          ? GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                              ),
                              itemCount: _faces.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: ImageCropperWidget(
                                      originalImageData: _optedImageData!,
                                      rect: _faces[index].boundingBox),
                                );
                              },
                            )
                          : Container(),
                    ),
                  ))
            ],
          ),
          Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: FloatingActionButton(
                  onPressed: _pickImage,
                  child: const Icon(Icons.photo),
                ),
              ))
        ],
      ),
    );
  }
}
