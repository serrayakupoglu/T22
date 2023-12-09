import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/common_app_bar.dart';
import 'package:untitled1/src/features/common_widgets/song_box.dart';
import 'package:untitled1/src/features/constants.dart';

import '../models/user.dart';

class LikedSongsPage extends StatefulWidget {
  final User user;

  const LikedSongsPage({super.key, required this.user});

  @override
  State<StatefulWidget> createState() => _LikedSongsPageState();
}

class _LikedSongsPageState extends State<LikedSongsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(kOpeningBG),
      appBar: const CommonAppBar(appBarText: 'Liked Songs'),
      body: ListView.builder(
        itemCount: widget.user.likedSongs.length,
        itemBuilder: (context, index) {
          Map<dynamic, dynamic> song = widget.user.likedSongs[index];
          return SongBox(songName: song['song'], artistName: song['artist']);
        },
      ),
    );
  }
}
