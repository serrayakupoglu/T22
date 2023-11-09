import 'package:flutter/material.dart';
import 'package:untitled1/src/features/screen/opening_screen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color(0xFF003049), // Custom primary color
        fontFamily: 'Montserrat',        // Custom font
      ),
      home:OpeningPage(),

    );
  }
}


