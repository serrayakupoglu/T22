import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/user.dart';
import '../service/storage_service.dart';


class UserRepository {
  Future<User> getProfileInfo(String username) async {
    final queryParams = {'username': username};
    print("Request");
    final url = Uri.parse('$kBaseUrl/get_profile').replace(queryParameters: queryParams);

    final response = await http.get(url);
    print("Response");
    if (response.statusCode == 200) {
      // Parse the JSON response and create a User object
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      print(jsonResponse);
      User user = User.fromJson(jsonResponse);


      for (int i = 0; i < user.playlists.length; i++) {
        for (int j = 0; j < user.playlists[i].tracks.length; j++) {
          print(user.playlists[i].tracks[j].songName);
        }
      }

      return user;
    } else {
      // Find a way to return errors
      throw Exception('Failed to load profile information');
    }
  }

  Future<http.Response> followUser(String targetUsername) async {
    final url = Uri.parse('$kBaseUrl/add_followings');
    final session = await storageService.readSecureData('session');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $session',
        'cookie': 'session=$session'
      },
      body: {
        'target_username': targetUsername,
      },
    );
    print(response.body);
    return response;
  }


  Future<http.Response> unfollowUser(String targetUsername) async {
    final url = Uri.parse('$kBaseUrl/unfollow');
    final session = await storageService.readSecureData('session');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $session',
        'cookie': 'session=$session'
      },
      body: {
        'target_username': targetUsername,
      },
    );
    return response;
  }

  Future<http.Response> logout(String username) async {

    final url = Uri.parse('$kBaseUrl/logout');
    final session = await storageService.readSecureData('session');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $session',
        'cookie': 'session=$session',
      },
      body: {
        'username': username,
      }
    );
    return response;
  }

  Future<http.Response> addSongToLikedList (String username, String songName) async {
    final url = Uri.parse('$kBaseUrl/add_to_liked_songs');
    final session = await storageService.readSecureData('session');
    print(songName);
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $session',
        'cookie': 'session=$session',
      },
      body: {
        'song_name': songName
      }
    );
    return response;
  }

  Future<http.Response> removeSongFromLikedList(String songName) async {
    final url = Uri.parse('$kBaseUrl/remove_from_liked_songs');
    final session = await storageService.readSecureData('session');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $session',
        'cookie': 'session=$session',
      },
      body: {
        'song_name': songName
      }
    );
    return response;
  }

  Future<http.Response> searchUser(String username) async {
    final url = Uri.parse('$kBaseUrl/search_user');
    print(username);
    final response = await http.post(
      url,
      body: {
        'username': username,
      }
    );
    return response;
  }

  Future<http.Response> getMostLikedGenre(String username) async {
    final queryParams = {'username': username};
    final url = Uri.parse('$kBaseUrl/get_higher_rated_genre').replace(queryParameters: queryParams);
    final response = await http.get(url);
    return response;
  }

  Future<http.Response> getMostLikedYear(String username) async {
    final queryParams = {'username': username};
    final url = Uri.parse('$kBaseUrl/get_average_release_year').replace(queryParameters: queryParams);
    final response = await http.get(url);
    return response;
  }

  Future<http.Response> recommendSong() async {
    final url = Uri.parse('$kBaseUrl/recommend_song');
    final session = await storageService.readSecureData('session');
    final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $session',
          'cookie': 'session=$session',
        });
    return response;
  }

  Future<http.Response> recommendSongFromFriends() async {
    final url = Uri.parse('$kBaseUrl/recommend_last_liked_song_from_friend');
    final session = await storageService.readSecureData('session');
    final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $session',
          'cookie': 'session=$session',
        });
    return response;
  }

  Future<http.Response> createPlaylist(String playlistName) async {
    print(playlistName);
    final url = Uri.parse('$kBaseUrl/create_playlist');
    final session = await storageService.readSecureData('session');
    final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $session',
          'cookie': 'session=$session',
        },
        body: {
          'playlist_name': playlistName
        }
      );
    return response;
  }

  Future<http.Response> addToPlaylist(String songName, String playlistName) async {
    final url = Uri.parse('$kBaseUrl/add_to_playlist');
    final session = await storageService.readSecureData('session');

    // Convert List<String> to a String using join
    final List<String> tracks = [songName];
    final String tracksAsString = tracks.join(',');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $session',
        'cookie': 'session=$session',
      },
      body: {
        'playlist_name': playlistName,
        'tracks[]': tracksAsString,
      },
    );
    return response;
  }


}