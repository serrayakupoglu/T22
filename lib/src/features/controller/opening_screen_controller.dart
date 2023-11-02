import 'package:flutter/material.dart';
import 'package:untitled1/src/features/screen/signup_screen.dart';
import 'package:untitled1/src/features/screen/signin_screen.dart';

class OpeningScreenController {
  final BuildContext context;

  OpeningScreenController(this.context);

  void navigateToSignUp() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return SignupPage();
    }));
  }

  void navigateToSignIn() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return LoginPage();
    }));
  }
}



