import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/user.dart';


class UserRepository {
  Future<User> getProfileInfo(String username) async {
    final queryParams = {'username': username};
    print("Request");
    final url = Uri.parse('$kBaseUrl/get_profile').replace(queryParameters: queryParams);

    final response = await http.get(url);
    print(response.body);
    print("Response");
    if (response.statusCode == 200) {
      // Parse the JSON response and create a User object
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      User user = User.fromJson(jsonResponse);
      print(user.likedSongs);
      return user;
    } else {
      // Find a way to return errors
      throw Exception('Failed to load profile information');
    }
  }

  Future<http.Response> followUser(String currentUsername, String targetUsername) async {
    final url = Uri.parse('$kBaseUrl/add_followings');
    final response = await http.post(
      url,
      body: {
        'target_username': targetUsername,
      },
    );
    print(response.body);
    return response;
  }


  Future<http.Response> unfollowUser(String currentUsername, String targetUsername) async {
    final url = Uri.parse('$kBaseUrl/unfollow');

    final response = await http.post(
      url,
      body: {
        'target_username': targetUsername,
      },
    );
    return response;
  }
}