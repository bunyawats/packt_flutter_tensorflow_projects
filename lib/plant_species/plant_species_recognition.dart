import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:tflite/tflite.dart';

import 'api_key.dart';

class PlantSpeciesRecognition extends StatefulWidget {
  final int modelType;

  PlantSpeciesRecognition(this.modelType);

  @override
  _PlantSpeciesRecognitionState createState() =>
      _PlantSpeciesRecognitionState();
}

class _PlantSpeciesRecognitionState extends State<PlantSpeciesRecognition> {
  File _image;
  bool _busy = false;
  List _recognitions = [];
  String str = "";

  @override
  Widget build(BuildContext context) {
    List<Widget> stackChildren = buildStackChildren(context);

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

  List<Widget> buildStackChildren(BuildContext context) {
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
    stackChildren.add(
      Center(
        child: Column(
          children: <Widget>[
            str.isNotEmpty
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
          children: _recognitions.map(
            (res) {
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
            },
          ).toList(),
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
    return stackChildren;
  }

  void chooseImageGallery() async {
    PickedFile pickedImage = await ImagePicker().getImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    print('select image $pickedImage');

    var image = File(pickedImage.path);
    setState(() {
      _image = image;
      _busy = true;
    });

    //Deciding on which method should be chosen image analysis
    if (widget.modelType == 0) {
      print("call visionAPICall");
      await visionAPICall(image);
    } else if (widget.modelType == 1) {
      print("call analyzeTFLite");
      await analyzeTFLite(image);
    }
    setState(() {
      _busy = false;
    });
  }

  Future visionAPICall(File image) async {
    List<int> imageBytes = image.readAsBytesSync();
    print(imageBytes);
    String base64Image = base64Encode(imageBytes);
    var requestStr = {
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
      body: json.encode(requestStr),
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

  Future analyzeTFLite(File image) async {
    Tflite.close();
    String res = await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
    );
    print('Model Loaded: $res');

    final recognitions = await Tflite.runModelOnImage(
      path: image.path,
    );
    setState(() {
      _recognitions = recognitions;
    });
    print('Recognition Result: $_recognitions');
  }

  @override
  void dispose() {
    super.dispose();
  }
}
