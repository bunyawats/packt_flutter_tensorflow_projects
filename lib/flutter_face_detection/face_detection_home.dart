import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'face_detection.dart';

class FaceDetectorHome extends StatefulWidget {
  @override
  _FaceDetectorHomeState createState() => _FaceDetectorHomeState();
}

class _FaceDetectorHomeState extends State<FaceDetectorHome> {
  File image;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget buildRowTitle(BuildContext context, String title) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 16.0,
        ),
        child: Text(
          title,
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
    );
  }

  Widget createButton(String imgSource) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
      child: ButtonTheme(
        // minWidth: 200.0,
        // height: 50.0,
        child: RaisedButton(
          color: Colors.blue,
          textColor: Colors.white,
          splashColor: Colors.blueGrey,
          onPressed: () {
            onPickImageSelected(imgSource);
          },
          child: Text(imgSource),
        ),
      ),
    );
  }

  Widget buildSelectImageRowWidget(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        createButton('Camera'),
        createButton('Gallery'),
      ],
    );
  }

  void onPickImageSelected(String source) async {
    var imageSource;
    if (source == 'Camera') {
      imageSource = ImageSource.camera;
    } else {
      imageSource = ImageSource.gallery;
    }
    final scaffold = _scaffoldKey.currentState;
    try {
      final file = await ImagePicker.pickImage(
        source: imageSource,
      );
      if (file == null) {
        throw Exception('File is not available');
      }
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FaceDetection(file),
          ));
    } catch (ex) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text(ex.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Face Detection'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            buildRowTitle(context, 'Pick Image'),
            buildSelectImageRowWidget(context)
          ],
        ),
      ),
    );
  }
}
