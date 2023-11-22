import 'package:flutter/material.dart';
import 'package:untitled1/src/features/repository/sign_up_repository.dart';

import '../constants.dart';

class SignUpService {
  final SignUpRepository _repository = SignUpRepository();

  Future<Map<String, dynamic>> signUp({
    required String username,
    required String password,
    required String password2,
    required String name,
    required String surname,
  }) async {
    try {
      final response = await _repository.signUp(username,password,password2,name,surname);
      if (response.statusCode == kSuccessCode) {
        return {'success': true, 'data': response.body};
      } else if (response.statusCode == kUserAlreadyExistsCode) {
        return {'success': false, 'message': kUserAlreadyExistsMsg};
      } else if (response.statusCode == kPasswordsDoNotMatchCode) {
        return {'success': false, 'message': kPasswordsDoNotMatchMsg};
      } else {
        return {'success': false, 'message': 'Sign Up Failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}