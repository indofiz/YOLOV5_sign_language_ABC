import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/foundation.dart';

class ImageTest extends StatefulWidget {
  final FlutterVision vision;
  const ImageTest({super.key, required this.vision});

  @override
  State<ImageTest> createState() => ImageTestState();
}

class ImageTestState extends State<ImageTest> {
  // INISIALISASI VARIABEL
  late List<Map<String, dynamic>> yoloResults;
  File? imageFile;
  int imageHeight = 1;
  int imageWidth = 1;
  bool isLoaded = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    // INISIALISASI STATE
    super.initState();
    // LOAD MODEL YOLO PERTAMA KALI SAAT MASUK HALAMAN
    loadYoloModel().then((value) {
      setState(() {
        yoloResults = [];
        isLoaded = true;
      });
    });
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // MENAMPILKAN BUTTON DAN BOUNDING BOX PADA GAMBAR
    final Size size = MediaQuery.of(context).size;
    if (!isLoaded) {
      return const Scaffold(
        body: Center(
          child: Text("Model not loaded, waiting for it"),
        ),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        imageFile != null ? Image.file(imageFile!) : const SizedBox(),
        Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: pickImage,
                  child: const Text("Pick image"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  onPressed: imageFile != null ? yoloOnImage : () {},
                  child: const Text(
                    "Detect",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        ...displayBoxesAroundRecognizedObjects(size),
      ],
    );
  }

//FUNGSI LOAD MODEL YOLO
  Future<void> loadYoloModel() async {
    await widget.vision.loadYoloModel(
        labels: 'assets/labels.txt',
        modelPath: 'assets/best-fp16.tflite',
        modelVersion: "yolov5",
        quantization: false,
        numThreads: 8,
        useGpu: true);
    setState(() {
      isLoaded = true;
    });
  }

// FUNGSI AMBIL GAMBAR
  Future<void> pickImage() async {
    setState(() {
      yoloResults = [];
    });
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
      File image = File(photo!.path);
      _cropImage(image);
    } catch (error) {
      // ignore: avoid_print
      print("error: $error");
    }
  }

// FUNGSI CROP GAMBAR
  Future<void> _cropImage(File pickedFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true,
          // aspectRatioPresets: [CropAspectRatioPreset.square],
        )
      ],
    );

    if (croppedFile != null) {
      // String fileName = croppedFile.path.split('/').last;
      setState(() {
        imageFile = File(croppedFile.path);
      });
    }
  }

// FUNGSI UNTUK MELAKUKAN PENGUJIAN YOLO PADA GAMBAR
  yoloOnImage() async {
    yoloResults.clear();
    Uint8List byte = await imageFile!.readAsBytes();
    final image = await decodeImageFromList(byte);
    imageHeight = image.height;
    imageWidth = image.width;
    final result = await widget.vision.yoloOnImage(
        bytesList: byte,
        imageHeight: image.height,
        imageWidth: image.width,
        iouThreshold: 0.8,
        confThreshold: 0.4,
        classThreshold: 0.5);
    if (result.isNotEmpty) {
      setState(() {
        yoloResults = result;
      });
    }
  }

// FUNGSI UNTUK MENAMPILKAN BOX HASIL DETEKSI
  List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
    if (yoloResults.isEmpty) return [];

    double factorX = screen.width / (imageWidth);
    double imgRatio = imageWidth / imageHeight;
    double newWidth = imageWidth * factorX;
    double newHeight = newWidth / imgRatio;
    double factorY = newHeight / (imageHeight);

    double pady = (screen.height - newHeight) / 2;

    Color colorPick = const Color.fromARGB(255, 50, 233, 30);
    return yoloResults.map((result) {
      return Positioned(
        left: result["box"][0] * factorX,
        top: result["box"][1] * factorY + pady,
        width: (result["box"][2] - result["box"][0]) * factorX,
        height: (result["box"][3] - result["box"][1]) * factorY,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            border: Border.all(color: Colors.pink, width: 2.0),
          ),
          child: Text(
            "${result['tag']} ${(result['box'][4] * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              background: Paint()..color = colorPick,
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
        ),
      );
    }).toList();
  }
}
