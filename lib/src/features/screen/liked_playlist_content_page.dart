import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/common_app_bar.dart';
import 'package:untitled1/src/features/common_widgets/song_box_without_icon.dart';
import 'package:untitled1/src/features/constants.dart';

import '../controller/user_controller.dart';
import '../models/song.dart';
import '../models/user.dart';

class LikedListContentPage extends StatefulWidget {
  final String playlistName;

  final String username;

  const LikedListContentPage({
    Key? key,
    required this.playlistName,

    required this.username,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LikedListContentPageState();
}

class _LikedListContentPageState extends State<LikedListContentPage> {
  late UserController _userController;
  late Future<User?> userData;

  @override
  void initState() {
    super.initState();
    _userController = UserController(context: context);
    userData = _userController.getUserProfile(widget.username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(kOpeningBG),
      appBar: CommonAppBar(
        canGoBack: true,
        appBarText: widget.playlistName,
      ),
      body: FutureBuilder<User?>(
        future: userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error loading user data'),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text('No user data available'),
            );
          } else {
            var user = snapshot.data!;
            List<Song> playlistContent = [];

            for (var playlist in user.playlists) {

              if (playlist.name == widget.playlistName) {

                playlistContent = List<Song>.from(playlist.tracks);
                break;
              }
            }

            return ListView.builder(
              itemCount: playlistContent.length,
              itemBuilder: (context, index) {
                var song = playlistContent[index];
                String songName = song.songName;
                String artist = song.getConcatenatedArtistNames();

                return SongBoxWithoutIcon(songName: songName, artistName: artist);
              },
            );
          }
        },
      ),
    );
  }
}
