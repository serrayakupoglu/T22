import 'package:flutter/material.dart';
import 'package:untitled1/src/features/screen/forgot_pass/forgot_pass_screen_first.dart';
import 'package:untitled1/src/features/screen/user_profile_screen.dart';
import 'package:untitled1/src/features/service/song_service.dart';
import 'package:untitled1/src/features/service/storage_service.dart';
import '../models/song.dart';
import '../service/sing_in_service.dart';

class SongController {
  final BuildContext context;
  SongController(this.context);

  final SongService _service = SongService();


  Future<List<Song>> search(String songName) async {
    return await _service.search(songName: songName);
  }

  Future<bool> rateSong(String songName, int rating) async {
    return await _service.rateSong(songName, rating);
  }

}