import 'package:flutter/material.dart';
import 'package:untitled1/src/features/screen/sign_up_screen.dart';
import 'package:untitled1/src/features/screen/sign_in_screen.dart';

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



