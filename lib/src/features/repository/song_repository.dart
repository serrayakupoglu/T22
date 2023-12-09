import 'package:http/http.dart' as http;
import 'package:untitled1/src/features/constants.dart';

class SongRepository {


  Future<http.Response> search(String songName) async {
    final queryParams = {'song_name': songName};

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
    final response = await http.post(
      rateSongUrl,
      body: {
        'song_name': songName,
        'rating': rating.toString(),
      },
    );
    return response;
  }

}