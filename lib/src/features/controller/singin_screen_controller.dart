import 'package:flutter/material.dart';
import 'package:untitled1/src/features/screen/forgot_pass_screen.dart';
import 'package:untitled1/src/features/screen/user_profile_screen.dart';
import 'package:untitled1/src/features/service/storage_service.dart';
import '../service/singin_service.dart';

class SignInScreenController {
  final BuildContext context;
  SignInScreenController(this.context);

  final SignInService _service = SignInService();

  void _createLoadingScreen() {
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
    }
  }

  void _destroyLoadingScreen() {
    if(!context.mounted) return;
    Navigator.of(context).pop();
  }

  void signIn(String userName, String password) async {

      _createLoadingScreen();
      final result = await _service.signIn(userName, password);
      _destroyLoadingScreen();


      if (result['success']) {
        print('Login successful');
        storageService.writeSecureData('userName', userName);
        // Navigate to main page.
        _navigateToMainPage();
      }
      else {
        print('Login failed: ${result['message']}');
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login failed: ${result['message']}'),
        ));
      }
    }


  void navigateToForgotPass() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return ForgotPass();
    }));
  }

  void _navigateToMainPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return UserProfile();
    }));
  }
}