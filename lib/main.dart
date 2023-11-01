import 'package:flutter/material.dart';
import 'package:untitled1/src/features/pages/first_page.dart';
import 'src/features/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'src/features/pages/signup.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFF003049), // Custom primary color
        fontFamily: 'Montserrat',        // Custom font
      ),
      home: LoginPage(),
      routes: <String, WidgetBuilder>
      {
        '{signup': (BuildContext context) => SignupPage()
      },
    );
  }
}
