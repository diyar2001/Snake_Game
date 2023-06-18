import 'package:flutter/material.dart';
import 'board.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
        backgroundColor: Color.fromARGB(255, 77, 71, 71)
      ),
      home: Board(),
    );
  }
}
