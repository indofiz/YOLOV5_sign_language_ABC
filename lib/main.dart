// IMPORT PACKAGE
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:yolo/back.dart';
import 'package:yolo/front.dart';
import 'package:yolo/hai.dart';
import 'package:yolo/image_test.dart';

// SEBAGAI ENUM PILIHAN MENU
enum Options { none, image, front, back }

// INISIALISASI VARIABEL KAMERA
late List<CameraDescription> cameras;

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'ABC FINGER',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // INISIALISASI VARIABEL VISION
  late FlutterVision vision;
  Options option = Options.none;
  @override
  void initState() {
    super.initState();
    vision = FlutterVision();
  }

  @override
  void dispose() async {
    super.dispose();
    await vision.closeTesseractModel();
    await vision.closeYoloModel();
  }

  @override
  Widget build(BuildContext context) {
    // MEMBUAT TAMPILAN MENU HALAMAN DEPAN
    return Scaffold(
      body: task(option),
      floatingActionButton: SpeedDial(
        //margin bottom
        icon: Icons.menu, //icon on Floating action button
        activeIcon: Icons.close, //icon when menu is expanded on button
        backgroundColor: Colors.deepPurple, //background color of button
        foregroundColor: Colors.white, //font color, icon color in button
        activeBackgroundColor:
            Colors.black12, //background color when menu is expanded
        activeForegroundColor: Colors.white,
        visible: true,
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        buttonSize: const Size(56.0, 56.0),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.camera),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            label: 'Test Gambar',
            labelStyle: const TextStyle(fontSize: 18.0),
            onTap: () {
              setState(() {
                option = Options.image;
              });
            },
          ),
          SpeedDialChild(
            //speed dial child
            child: const Icon(Icons.video_call),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            label: 'Kamera Depan',
            labelStyle: const TextStyle(fontSize: 18.0),
            onTap: () {
              setState(() {
                option = Options.front;
              });
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.video_call),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            label: 'Kamera Belakang',
            labelStyle: const TextStyle(fontSize: 18.0),
            onTap: () {
              setState(() {
                option = Options.back;
              });
            },
          ),
        ],
      ),
    );
  }

// PILIHAN MENU JIKA DI PILIH LALU DIARAHKAN SESUAI CLASS
  Widget task(Options option) {
    if (option == Options.front) {
      return FrontYolo(vision: vision);
    }
    if (option == Options.back) {
      return BackYolo(vision: vision);
    }
    if (option == Options.image) {
      return ImageTest(vision: vision);
    }
    return const Center(child: HaiWidget());
  }
}
