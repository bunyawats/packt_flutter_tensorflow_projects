import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class FaceDetection extends StatefulWidget {
  final File file;
  FaceDetection(this.file);

  @override
  _FaceDetectionState createState() => _FaceDetectionState();
}

class _FaceDetectionState extends State<FaceDetection> {
  List<Face> faces;
  ui.Image image;

  void detectFaces() async {
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(widget.file);
    final FaceDetector faceDetector = FirebaseVision.instance.faceDetector(
      FaceDetectorOptions(
        mode: FaceDetectorMode.accurate,
        enableLandmarks: true,
        enableClassification: true,
      ),
    );
    List<Face> detectedFaces = await faceDetector.processImage(visionImage);
    for (var i = 0; i < detectedFaces.length; i++) {
      final double smileProbability = detectedFaces[i].smilingProbability;
      print('Smiling: $smileProbability');
    }
    faces = detectedFaces;
    loadImage(widget.file);
  }

  @override
  void initState() {
    super.initState();
    detectFaces();
  }

  void loadImage(File file) async {
    final data = await file.readAsBytes();
    await decodeImageFromList(data).then(
      (value) => setState(() {
        image = value;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face Detection'),
      ),
      body: (image == null)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: FittedBox(
                child: SizedBox(
                  height: image.height.toDouble(),
                  width: image.width.toDouble(),
                  child: CustomPaint(
                    painter: FacePainter(
                      image,
                      faces,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class FacePainter extends CustomPainter {
  ui.Image image;
  List<Face> faces;
  final List<Rect> rects = [];

  FacePainter(ui.Image img, List<Face> faces) {
    this.image = img;
    this.faces = faces;
    for (var i = 0; i < faces.length; i++) {
      rects.add(faces[i].boundingBox);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset.zero, Paint());

    for (var i = 0; i < faces.length; i++) {
      bool isSmiling = faces[i].smilingProbability > 0.80;
      drawSmilingTag(isSmiling, rects[i], canvas);
    }
  }

  void drawSmilingTag(bool isSmiling, Rect rect, Canvas canvas) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..color = isSmiling ? Colors.green : Colors.red;
    canvas.drawRect(rect, paint);

    final textSpan = TextSpan(
      style: TextStyle(
        color: Colors.lightGreen,
        fontWeight: FontWeight.w900,
        fontSize: 100,
      ),
      text: isSmiling ? 'Smiling' : '',
    );

    Offset position = Offset(
      rect.bottomLeft.dx + 10,
      rect.bottomLeft.dy - 110,
    );

    TextPainter tp = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
      canvas,
      position,
    );
  }

  @override
  bool shouldRepaint(covariant FacePainter oldDelegate) {
    return image != oldDelegate.image || faces != oldDelegate.faces;
  }
}
