import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:untitled1/src/features/constants.dart';
import 'package:untitled1/src/features/service/storage_service.dart';

import '../models/playlist_recommendation_instance.dart';
import '../models/song_input.dart';

class SongRepository {


  Future<http.Response> search(String songName) async {

    final songSearchUrl = Uri.parse('$kBaseUrl/search_song');

    try {
      final response = await http.post(
        songSearchUrl,
        body: {
          "song_name" : songName,
        }
      );
      return response;
    } catch (e) {
      return http.Response('Error: $e', 500);
    }
  }


  Future<http.Response> rateSong(String songName, int rating) async {

      final rateSongUrl = Uri.parse('$kBaseUrl/rate_song');
      final session = await storageService.readSecureData('session');

      print(session);
      print(rating);

      try {
        final response = await http.post(
          rateSongUrl,
          headers: {
            'Authorization': 'Bearer $session',
            'cookie': 'session=$session'
          },
          body: {
            'song_name' : songName,
            'rating' : rating.toString()
          },
        );
        print(response.body);
        return response;
      } catch(e) {
        print(e);
        throw Future.error(e);
      }
  }

  Future<http.Response> addSongManually(SongData songData) async {
    final url = Uri.parse('$kBaseUrl/add_track_man');

    final response = http.post(
        url,
        body: {
          'album_id': songData.album['id'],
          'album_name': songData.album['name'],
          'release_date': songData.album['release_date'],
          'artist_id': songData.artists[0]['id'],
          'artist_name': songData.artists[0]['name'],
          'num_artists': songData.artists.length.toString(), // Example for handling multiple artists
          'duration_ms': songData.durationMs.toString(),
          'track_id': songData.id,
          'track_name': songData.name,
          'popularity': songData.popularity.toString(),
        }
    );
    return response;

  }

  Future<List<PlaylistRecommendation>> recommendRelaxingPlaylist() async {
    final url = Uri.parse('$kBaseUrl/recommend_relaxing_playlist');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);

      if (responseData is Map<String, dynamic> &&
          responseData.containsKey("recommendations")) {
        final List<dynamic> data = responseData["recommendations"];

        List<PlaylistRecommendation> playlistRecommendations = data
            .map((json) =>
            PlaylistRecommendation.fromJson(json))
            .toList();

        return playlistRecommendations;
      } else {
        throw Exception('Unexpected response format. Expected a Map with "recommendations" key.');
      }
    } else {
      throw Exception('Failed to load relaxing playlist recommendations');
    }
  }

  Future<List<PlaylistRecommendation>> recommendEnergeticPlaylist() async {
    final url = Uri.parse('$kBaseUrl/recommend_energetic_playlist');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);

      if (responseData is Map<String, dynamic> &&
          responseData.containsKey("recommendations")) {
        final List<dynamic> data = responseData["recommendations"];

        List<PlaylistRecommendation> playlistRecommendations = data
            .map((json) =>
            PlaylistRecommendation.fromJson(json))
            .toList();

        return playlistRecommendations;
      } else {
        throw Exception('Unexpected response format. Expected a Map with "recommendations" key.');
      }
    } else {
      throw Exception('Failed to load relaxing playlist recommendations');
    }
  }

  Future<List<PlaylistRecommendation>> recommendPlaylist() async {
    final url = Uri.parse('$kBaseUrl/recommend_playlist');
    final session = await storageService.readSecureData('session');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $session',
        'cookie': 'session=$session',
      },
    );

    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);

      if (responseData is Map<String, dynamic> &&
          responseData.containsKey("recommendations")) {
        final List<dynamic> data = responseData["recommendations"];

        List<PlaylistRecommendation> playlistRecommendations = data
            .map((json) =>
            PlaylistRecommendation.fromJson(json))
            .toList();

        return playlistRecommendations;
      } else {
        throw Exception('Unexpected response format. Expected a Map with "recommendations" key.');
      }
    } else {
      throw Exception('Failed to load playlist recommendations');
    }
  }

  

}

