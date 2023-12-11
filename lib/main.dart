import 'package:flutter/material.dart';
import 'package:untitled1/src/features/screen/home_screen.dart';
import 'package:untitled1/src/features/screen/forgot_pass/forgot_pass_code_screen.dart';
import 'package:untitled1/src/features/screen/home_page.dart';
import 'package:untitled1/src/features/screen/opening_screen.dart';
import 'package:untitled1/src/features/screen/search_screen.dart';
import 'package:untitled1/src/features/screen/user_profile_screen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: OpeningPage(),
    );
  }
}


