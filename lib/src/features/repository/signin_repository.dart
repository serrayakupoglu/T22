import 'package:http/http.dart' as http;
import 'package:untitled1/src/features/constants.dart';

class SignInRepository {
  final loginUrl = Uri.parse('$kBaseUrl/login');

  Future<http.Response> signIn(String username, String password) async {
    try {
      final response = await http.post(
        loginUrl,
        body: {
          'username': username,
          'password': password,
        },
      );
      return response;
    } catch (e) {
      return http.Response('Error: $e', 500);
    }
  }


}

