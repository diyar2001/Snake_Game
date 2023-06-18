import 'package:flutter/material.dart';

class Snakebody extends StatelessWidget {
  int index;

  Snakebody({@required this.index});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.rectangle,color: Colors.blueGrey,size: 30,weight: 700,fill: 0.5,);
  }
}

