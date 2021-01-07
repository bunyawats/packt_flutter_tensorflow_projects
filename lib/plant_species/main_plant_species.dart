import 'package:flutter/material.dart';
import 'choose_model.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChooseModel(),
    );
  }
}
