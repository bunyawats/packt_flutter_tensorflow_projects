import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'api_key.dart';

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

  Future visionAPICall() async {
    List<int> imageBytes = _image.readAsBytesSync();
    print(imageBytes);
    String base64Image = base64Encode(imageBytes);
    var request_str = {
      "requests": [
        {
          "image": {"content": "$base64Image"},
          "features": [
            {"type": "LABEL_DETECTION", "maxResults": 1}
          ]
        }
      ]
    };
    var url = 'https://vision.googleapis.com/v1/images:annotate?key=$API_KEY';

    var response = await http.post(
      url,
      body: json.encode(request_str),
    );
    print('Response status: ${response.statusCode}');
    print('Respons body: ${response.body}');

    var responseJson = json.decode(response.body);
    var key = responseJson["response"][0]["labelAnnotations"][0]["description"];
    var value = responseJson["responses"][0]["labelAnnotations"][0]["score"].toStringAsFixed(3);
    var str = '$key : $value';
  }
}
