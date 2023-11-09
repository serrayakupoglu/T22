import 'package:flutter/material.dart';
import 'package:untitled1/src/features/service/storage_service.dart';


class SignInService {
  Future<void> signIn(String email, String password) async {
    storageService.writeSecureData("email", email);
    storageService.writeSecureData("password", password);
    debugPrint("Sign In Clicked");
  }
}