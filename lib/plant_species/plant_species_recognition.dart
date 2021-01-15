import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:tflite/tflite.dart';

import 'api_key.dart';

class PlantSpeciesRecognition extends StatefulWidget {
  int modelType;

  PlantSpeciesRecognition(this.modelType);

  @override
  _PlantSpeciesRecognitionState createState() =>
      _PlantSpeciesRecognitionState();
}

class _PlantSpeciesRecognitionState extends State<PlantSpeciesRecognition> {
  List<Widget> stackChildren = [];
  File _image;
  bool _busy = false;
  List _recognitions;
  String str;

  @override
  Widget build(BuildContext context) {
    List<Widget> stackChildren = [];
    Size size = MediaQuery.of(context).size;

    stackChildren.clear();

    stackChildren.add(
      Positioned(
        top: 0,
        left: 0,
        width: size.width,
        child: _image == null ? Text('No Image Selected') : Image.file(_image),
      ),
    );
    stackChildren.add(
      Center(
        child: Column(
          children: <Widget>[
            str != null
                ? new Text(
                    str,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      background: Paint()..color = Colors.white,
                    ),
                  )
                : new Text('No Results'),
          ],
        ),
      ),
    );
    stackChildren.add(
      Center(
        child: Column(
          children: _recognitions != null
              ? _recognitions.map((res) {
                  var key = res["label"];
                  var value = res["confidence"].toStringAsFixed(3);
                  return Text(
                    "$key: $value",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      background: Paint()..color = Colors.white,
                    ),
                  );
                }).toList()
              : [],
        ),
      ),
    );

    if (_busy) {
      stackChildren.add(const Opacity(
        child: ModalBarrier(dismissible: false, color: Colors.grey),
        opacity: 0.3,
      ));
      stackChildren.add(const Center(child: CircularProgressIndicator()));
    }

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
    PickedFile pickedImage  = await ImagePicker().getImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    print('select image $_image');
    if (pickedImage == null) return;
    _image = File(pickedImage.path);
    setState(() {
      _busy = true;
    });

    //Deciding on which method should be chosen image analysis
    if (widget.modelType == 0) {
      print("call visionAPICall");
      await visionAPICall();
    } else if (widget.modelType == 1) {
      print("call analyzeTFLite");
      await analyzeTFLite();
    }
    setState(() {
      _busy = false;
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
    var key =
        responseJson["responses"][0]["labelAnnotations"][0]["description"];
    var value = responseJson["responses"][0]["labelAnnotations"][0]["score"]
        .toStringAsFixed(3);
    str = '$key : $value';
  }

  Future analyzeTFLite() async {
    String res = await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
    );
    print('Model Loaded: $res');

    var recognitions = await Tflite.runModelOnImage(
      path: _image.path,
    );
    setState(() {
      _recognitions = recognitions;
    });
    print('Recognition Result: $_recognitions');
  }
}
