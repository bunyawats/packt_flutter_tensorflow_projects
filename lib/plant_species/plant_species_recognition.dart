import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PlantSpeciesRecognition extends StatefulWidget {
  int chosenModel;

  PlantSpeciesRecognition(this.chosenModel);

  @override
  _PlantSpeciesRecognitionState createState() =>
      _PlantSpeciesRecognitionState();
}

class _PlantSpeciesRecognitionState extends State<PlantSpeciesRecognition> {
  List<Widget> stackChildren = [];
  File _image;
  // bool _busy = false;

  @override
  Widget build(BuildContext context) {

    List<Widget> stackChildren = [];
    Size size = MediaQuery.of(context).size;
    stackChildren.add(
      Positioned(
        top: 0,
        left: 0,
        width: size.width,
        child: _image == null ? Text('No Image Selected') : Image.file(_image),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Species Recognition'),
      ),
      body: Stack(
        children: stackChildren,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: chooseImageGallery,
        tooltip: 'Pick Image',
        child: Icon(Icons.image),
      ),
    );
  }

  void chooseImageGallery() async {
    _image = await ImagePicker.pickImage(source: ImageSource.gallery);
    print('select image $_image');
    // if (_image == null) return;
    setState(() {
      _image = _image;
    });
  }
}
