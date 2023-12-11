import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:untitled1/src/features/constants.dart';
import 'package:untitled1/src/features/service/storage_service.dart';

class SignInRepository {
  final signInUrl = Uri.parse('$kBaseUrl/login');

  Future<http.Response> signIn(String username, String password) async {
    try {
      final response = await http.post(
        signInUrl,
        body: {
          'username': username,
          'password': password,

        },
      );

      final String sessionString = '${response.headers['set-cookie']}';
      
      int sessionStartIndex = sessionString.indexOf('session=') + 'session='.length;
      int sessionEndIndex = sessionString.indexOf(';', sessionStartIndex);
      String session = sessionString.substring(sessionStartIndex, sessionEndIndex);
      storageService.writeSecureData('session', session);
      print(response.headers);
      print(session);
      return response;
    } catch (e) {
      return http.Response('Error: $e', 500);
    }
  }


}
