import 'package:flutter/material.dart';
import 'package:untitled1/src/features/screen/fotgot_pass/forgot_pass_screen_first.dart';
import 'package:untitled1/src/features/screen/user_profile_screen.dart';
import 'package:untitled1/src/features/service/storage_service.dart';
import '../service/sing_in_service.dart';

class SignInScreenController {
  final BuildContext context;
  SignInScreenController(this.context);
  bool isError = false;
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

  Future<bool> signIn(String username, String password) async {

      _createLoadingScreen();
      final result = await _service.signIn(username, password);
      _destroyLoadingScreen();


      if (result['success']) {
        print('Login successful');
        storageService.writeSecureData('username', username);
        // Navigate to main page.
        _navigateToMainPage();
      }
      else {
        return true;
        print('Login failed: ${result['message']}');
        if (!context.mounted) return true;

        /*
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login failed: ${result['message']}'),
        ));
         */
      }
      return false;
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