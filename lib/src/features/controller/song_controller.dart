import 'package:flutter/material.dart';
import 'package:untitled1/src/features/screen/fotgot_pass/forgot_pass_screen_first.dart';
import 'package:untitled1/src/features/screen/user_profile_screen.dart';
import 'package:untitled1/src/features/service/example_song_service.dart';
import 'package:untitled1/src/features/service/storage_service.dart';
import '../service/sing_in_service.dart';

class SongController {
  final BuildContext context;
  SongController(this.context);

  final SongService _service = SongService();

  void search(String songName) async {
    print("kemo");
    final result = await _service.search(songName: songName);

  }

}