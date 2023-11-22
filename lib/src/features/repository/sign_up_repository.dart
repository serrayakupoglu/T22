import 'package:http/http.dart' as http;

import '../constants.dart';

class SignUpRepository {
  final signUpUrl = Uri.parse('$kBaseUrl/signup');

  Future<http.Response> signUp (String username, String password, String password2, String name, String surname) async {
    try {
      final response = await http.post(
        signUpUrl,
        body: {
          'username': username,
          'password': password,
          'password2' : password2,
          'name': name,
          'surname': surname
        },
      );
      return response;
    } catch (e) {
      return http.Response('Error: $e', 500);
    }
  }

}