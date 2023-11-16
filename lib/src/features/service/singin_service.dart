import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:untitled1/src/features/constants.dart';
import 'package:untitled1/src/features/repository/signin_repository.dart';

class SignInService {
  final SignInRepository repository = SignInRepository();

  Future<Map<String, dynamic>> signIn(String username, String password) async {
    try {
      final response = await repository.signIn(username, password);
      if (response.statusCode == kSuccessCode) {
        return {'success': true, 'data': response.body};
      } else if (response.statusCode == kInvalidCredentialsCode) {
        return {'success': false, 'message': kInvalidCredentialsMsg};
      } else if (response.statusCode == kMissingCredentialsCode) {
        return {'success': false, 'message': kMissingCredentialsMsg};
      } else if (response.statusCode == kAlreadyLoggedInCode) {
        return {'success': false, 'message': kAlreadyLoggedInMsg};
      } else {
        return {'success': false, 'message': 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}