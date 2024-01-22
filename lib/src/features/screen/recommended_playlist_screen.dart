
import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/common_app_bar.dart';
import 'package:untitled1/src/features/common_widgets/song_box.dart';
import 'package:untitled1/src/features/controller/user_controller.dart';
import 'package:untitled1/src/features/models/recommendations_cache.dart';
import 'package:untitled1/src/features/service/storage_service.dart';

import '../SongBoxWithoutIcon.dart';
import '../common_widgets/rating_dialog.dart';
import '../common_widgets/slidable_song_box_recommended_playlist.dart';
import '../constants.dart';
import '../models/playlist_recommendation_instance.dart';
import '../models/song.dart';
import '../models/user.dart';

class RecommendedPlaylistScreen extends StatefulWidget {
  final String playlistName;
  const RecommendedPlaylistScreen({super.key, required this.playlistName});
  
  @override
  State<StatefulWidget> createState() => _RecommendedPlaylistScreenState();

}

class _RecommendedPlaylistScreenState extends State<RecommendedPlaylistScreen>{
  late Future<List<PlaylistRecommendation>> playlist;
  late User userData;
  late UserController userController;
  late String playlistNameAppBar;
  @override
  void initState() {
    fetchPlaylist();
    fetchUserData();
    userController = UserController(context: context);
    if(widget.playlistName == 'energeticPlaylist') playlistNameAppBar = 'Energetic Playlist';
    if(widget.playlistName == 'relaxingPlaylist') playlistNameAppBar = 'Relaxing Playlist';
    if(widget.playlistName == 'playlist') playlistNameAppBar = 'Personalized Playlist';

    super.initState();

  }
  
  void fetchPlaylist () async {
    playlist = RecommendationsCache.getRecommendation(widget.playlistName);
  }
  fetchUserData () async {
    String? username = await StorageService().readSecureData('username');
    userData = await userController.getUserProfile('$username');
    setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(appBarText: playlistNameAppBar, canGoBack: true),
      backgroundColor: const Color(kOpeningBG),
      body: FutureBuilder<List<PlaylistRecommendation>>(
        future: playlist, // Your Future<List<PlaylistRecommendation>> here
        builder: (BuildContext context, AsyncSnapshot<List<PlaylistRecommendation>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading state
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Error state
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Empty data state
            return Center(child: Text('No recommendations available.'));
          } else {
            // Data state
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                PlaylistRecommendation recommendation = snapshot.data![index];
                return RecommendedSongSlidable(
                  rateButtonFunction: (context) async{
                    Song s = Song(albumId: '', albumName: '', artists: [], songName: recommendation.songName, popularity: 0, );
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return RatingDialog(song: s);
                      },
                    );
                  },
                  addButtonFunction: (context) async {
                    await addToPlaylistAndShowDialog(context, recommendation.songName);
                  },
                  likeButtonFunction: (context) async {
                    likeSong(recommendation.songName);
                  },
                  child:SongBoxWithoutIcon(
                      songName: recommendation.songName, artistName: recommendation.artist,
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