import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'face_detection_home.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(FaceDetectorApp());
}

class FaceDetectorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FaceDetectorHome(),
    );
  }
}

