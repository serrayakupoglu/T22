import 'package:flutter/material.dart';
import 'package:untitled1/src/features/screen/sign_in_screen.dart';
import '../service/sign_up_service.dart';

class SignUpController {
  final BuildContext context;
  final SignUpService _service = SignUpService();

  SignUpController({required this.context});

  void signUp(String username, String password, String password2, String name, String surname) async {
    final result = await _service.signUp(name: name, password2: password2, password: password, surname: surname, username: username);

    if (result['success']) {
      _navigateToSignInPage();
    }
    else {
      print('Login failed: ${result['message']}');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Login failed: ${result['message']}'),
      ));
    }
  }

  void _navigateToSignInPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return LoginPage();
    }));
  }
}