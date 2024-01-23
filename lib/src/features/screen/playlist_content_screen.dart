import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/common_app_bar.dart';
import 'package:untitled1/src/features/common_widgets/slidable_song_box.dart';
import 'package:untitled1/src/features/common_widgets/song_box.dart';
import 'package:untitled1/src/features/common_widgets/song_box_without_icon.dart';
import 'package:untitled1/src/features/constants.dart';
import 'package:untitled1/src/features/controller/user_controller.dart';
import 'package:untitled1/src/features/service/storage_service.dart';
import '../models/song.dart';


class PlaylistContentPage extends StatefulWidget {
  final List<Song> listOfSongs;
  final String listName;
  final bool isOwn;
  final String username;
  const PlaylistContentPage({super.key,  required this.listName, required this.listOfSongs, required this.isOwn, required this.username,});

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
      floatingActionButton: !widget.isOwn ? FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          bool response = await _userController.likePlaylist(widget.listName, widget.username);
          SnackBar(
            backgroundColor: Colors.green,
            content: response ? Text('Playlist Liked') : Text('Failed To Like Playlist'),
            duration: Duration(seconds: 2),
          );
        },
        child: const Icon(Icons.favorite),
      ) : null,
      appBar: CommonAppBar(appBarText: widget.listName, canGoBack: true),
      body: ListView.builder(
        itemCount: songList.length,
        itemBuilder: (context, index) {
          Song song = songList[index];
          return widget.isOwn ? SlidableSongBoxPlaylist(

              removeButtonFunction: (context) async {
                bool response = await _userController.removeSongFromPlaylist(song.songName, widget.listName);
                if (response == true) {
                  String? username = await StorageService().readSecureData('username');
                  await _userController.updateUserProfile('$username');
                  songList.remove(song);
                  callSetState();
                }
              },
              child:  SongBoxWithoutIcon(
                songName: song.songName,
                artistName: song.getConcatenatedArtistNames(),
              )
          ) :
          SongBoxWithoutIcon(songName: song.songName, artistName: song.getConcatenatedArtistNames());

        },
      ),
    );
  }
}

