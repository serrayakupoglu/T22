import 'package:flutter/material.dart';
import 'package:untitled1/src/features/screen/forgot_pass_screen.dart';
import '../service/singin_service.dart';

class SignInScreenController {
  final BuildContext context;
  SignInScreenController(this.context);

  final SignInService _service = SignInService();

  void signIn(String email, String password) async {
    try {
      await _service.signIn(email, password);
      // Handle successful signup, such as navigation or displaying a success message.
      debugPrint(email);
      debugPrint(password);
    } catch (e) {
      // Handle errors, such as displaying an error message.
    }
  }

  void navigateToForgotPass() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return ForgotPass();
    }));
  }

}