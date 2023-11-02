import 'package:flutter/material.dart';
import '../service/signup_service.dart';

class SignUpScreenController {
  final BuildContext context;
  SignUpScreenController(this.context);

  final SignUpService _service = SignUpService();

  void signUp(String email, String password) async {
    try {
      await _service.signUp(email, password);
      // Handle successful signup, such as navigation or displaying a success message.
      debugPrint(email);
      debugPrint(password);
    } catch (e) {
      // Handle errors, such as displaying an error message.
    }
  }

  void goBack() {
    Navigator.of(context).pop();
  }
}