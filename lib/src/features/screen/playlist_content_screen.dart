import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:untitled1/src/features/common_widgets/common_app_bar.dart';
import 'package:untitled1/src/features/common_widgets/slidable_song_box.dart';
import 'package:untitled1/src/features/common_widgets/song_box.dart';
import 'package:untitled1/src/features/constants.dart';
import 'package:untitled1/src/features/controller/user_controller.dart';
import 'package:untitled1/src/features/service/storage_service.dart';

import '../models/song.dart';
import '../models/user.dart';

class PlaylistContentPage extends StatefulWidget {
  final List<Song> listOfSongs;
  final String listName;
  const PlaylistContentPage({super.key,  required this.listName, required this.listOfSongs,});

  @override
  State<StatefulWidget> createState() => _PlaylistContentPageState();
}

class _PlaylistContentPageState extends State<PlaylistContentPage> {

  late UserController _userController;
  late List<Song> songList;
  @override
  void initState() {
    _userController = UserController(context: context);
    songList = widget.listOfSongs;
    super.initState();
  }

  void callSetState() {
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(kOpeningBG),
      appBar: CommonAppBar(appBarText: widget.listName, canGoBack: true),
      body: ListView.builder(
        itemCount: songList.length,
        itemBuilder: (context, index) {
          Song song = songList[index];
          return SlidableSongBoxPlaylist(

              removeButtonFunction: (context) async {
                bool response = await _userController.removeSongFromPlaylist(song.songName, widget.listName);
                if (response == true) {
                  String? username = await StorageService().readSecureData('username');
                  await _userController.updateUserProfile('$username');
                  songList.remove(song);
                  callSetState();
                }
              },
              child: SongBox(
                songName: song.songName,
                artistName: song.getConcatenatedArtistNames(),
              )
          );
        },
      ),
    );
  }
}

