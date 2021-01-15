import 'package:flutter/material.dart';
import 'plant_species_recognition.dart';

class ChooseModel extends StatefulWidget {
  @override
  _ChooseModelState createState() => _ChooseModelState();
}

class _ChooseModelState extends State<ChooseModel> {
  var strCloud = 'Cloud Vision API';
  var strTensor = 'TensorFlow Lite';

  Widget buildRowTitle(BuildContext context, String title) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 16,
        ),
        // ignore: deprecated_member_use
        child: Text(
          title,
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
    );
  }

  Widget createButton(String choseModel) {
    return RaisedButton(
      color: Colors.blue,
      textColor: Colors.white,
      splashColor: Colors.blueGrey,
      child: Text(choseModel),
      onPressed: () {
        var modelType = (choseModel == strCloud) ? 0 : 1;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlantSpeciesRecognition(modelType),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Plant Species Recognition'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            buildRowTitle(context, 'Choose Model'),
            createButton(strCloud),
            createButton(strTensor),
          ],
        ),
      ),
    );
  }
}
