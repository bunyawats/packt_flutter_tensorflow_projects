import 'package:flutter/material.dart';
import 'face_detection_home.dart';

void main() => runApp(FaceDetectorApp());

class FaceDetectorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FaceDetectorHome(),
    );
  }
}

