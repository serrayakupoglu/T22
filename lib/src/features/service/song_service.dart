import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:untitled1/src/features/models/song.dart';
import 'package:untitled1/src/features/repository/song_repository.dart';
import '../constants.dart';
import '../models/song_input.dart';

class SongService {
  final SongRepository _repository = SongRepository();

  Future<List<Song>> search({
    required String songName,
  }) async {
    final response = await _repository.search(songName);
    List<dynamic> results = json.decode(response.body)['results'];
    List<Song> songList = results.map((result) {
      return Song.fromJson(result);
    }).toList();
    return songList;
  }

  Future<bool> rateSong(String songName, int rating) async {
    final response = await _repository.rateSong(songName, rating);
    return response.statusCode == 200;
  }

  Future<bool> addSongManually (SongData songData) async {
    final response = await _repository.addSongManually(songData);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

}