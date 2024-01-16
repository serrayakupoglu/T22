import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/common_app_bar.dart';
import 'package:untitled1/src/features/common_widgets/song_box.dart';
import 'package:untitled1/src/features/constants.dart';

import '../models/song.dart';

class PlaylistContentPage extends StatefulWidget {
  final List<Song> songList;
  final String listName;
  const PlaylistContentPage({super.key, required this.songList, required this.listName,});

  @override
  State<StatefulWidget> createState() => _PlaylistContentPageState();
}

class _PlaylistContentPageState extends State<PlaylistContentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(kOpeningBG),
      appBar: CommonAppBar(appBarText: widget.listName, canGoBack: true),
      body: ListView.builder(
        itemCount: widget.songList.length,
        itemBuilder: (context, index) {
          Song song = widget.songList[index];
          return SongBox(songName: song.songName, artistName: song.getConcatenatedArtistNames());
        },
      ),
    );
  }
}
