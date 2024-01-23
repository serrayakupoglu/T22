import 'package:http/http.dart' as http;

import '../constants.dart';

class SignUpRepository {
  final signUpUrl = Uri.parse('$kBaseUrl/signup');

  Future<http.Response> signUp (String username, String password, String password2, String name, String surname, String email) async {
    try {
      final response = await http.post(
        signUpUrl,
        body: {
          'username': username,
          'password': password,
          'password2' : password2,
          'email': email,
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