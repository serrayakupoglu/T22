import 'package:flutter/material.dart';
import 'package:untitled1/src/features/repository/song_repository.dart';
import '../constants.dart';

class SongService {
  final SongRepository _repository = SongRepository();
  Future<Map<String, dynamic>> search({
    required String songName,
  }) async {
    try {
      final response = await _repository.search(songName);
      print(response.body);
      return {'success': false, 'message': 'Error:'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}