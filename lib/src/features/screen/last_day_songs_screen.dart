import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/common_app_bar.dart';
import 'package:untitled1/src/features/controller/user_controller.dart';
import 'package:untitled1/src/features/service/storage_service.dart';

import '../common_widgets/song_box_without_icon.dart';
import '../common_widgets/rating_dialog.dart';
import '../common_widgets/slidable_song_box_recommended_playlist.dart';
import '../constants.dart';
import '../models/last_day_songs.dart';
import '../models/recommendations_cache.dart';
import '../models/song.dart';
import '../models/user.dart';

class LastDaySongsScreen extends StatefulWidget {
  const LastDaySongsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState()  => _LastDaySongsScreenState();
}

class _LastDaySongsScreenState extends State<LastDaySongsScreen> {
  late Future<LastDaySongsList> lastDaySongsList;
  late User userData;
  late UserController userController;

  @override
  void initState() {
    fetchLastDaySongsList();
    fetchUserData();
    userController = UserController(context: context);
    super.initState();
  }

  void fetchLastDaySongsList() async {
    lastDaySongsList = RecommendationsCache.getRecommendation('lastDayList');
  }

  fetchUserData() async {
    String? username = await StorageService().readSecureData('username');
    userData = await userController.getUserProfile('$username');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(appBarText: 'Last Day Songs', canGoBack: true),
      backgroundColor: const Color(kOpeningBG),
      body: FutureBuilder<LastDaySongsList>(
        future: lastDaySongsList,
        builder: (BuildContext context, AsyncSnapshot<LastDaySongsList> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No last day songs available.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.lastDaySongsList.length,
              itemBuilder: (context, index) {
                var lastDaySong = snapshot.data!.lastDaySongsList[index];
                return RecommendedSongSlidable(
                  rateButtonFunction: (context) async {
                    Song s = Song(
                      songName: lastDaySong.songName, albumId: '', albumName: '', artists: [], popularity: 0,
                    );
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return RatingDialog(song: s);
                      },
                    );
                  },
                  addButtonFunction: (context) async {
                    await addToPlaylistAndShowDialog(context, lastDaySong.songName);
                  },
                  likeButtonFunction: (context) async {
                    likeSong(lastDaySong.songName);
                  },
                  child: SongBoxWithoutIcon(
                    songName: lastDaySong.songName,
                    artistName: lastDaySong.artistName,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<void> likeSong(String songName) async {
    {
      final response = await userController.addSongToLikedList(userData.username, songName);
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(response ? 'Success' : 'Error'),
              content: Text(response ? 'Song is successfully added to the list.' : 'Song cannot be added to the List.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      });
    }
  }

  Future<void> addToPlaylistAndShowDialog(BuildContext context, String songName) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Playlist'),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: userData.playlists.length,
              itemBuilder: (context, index) {
                String playlistName = userData.playlists[index].name;

                return ListTile(
                  title: Text(playlistName),
                  onTap: () async {
                    await userController.addToPlaylist(songName, playlistName).then((success) {
                      if (success) {
                        userController.updateUserProfile(userData.username);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Success'),
                              content: const Text('Song Successfully Added To The Playlist!'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop(); // Close the previous dialog
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Failed'),
                              content: Text('Failed To Add.'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Retry'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop(); // Close the previous dialog
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    });
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

