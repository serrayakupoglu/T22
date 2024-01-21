import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/common_app_bar.dart';
import 'package:untitled1/src/features/common_widgets/liked_songs_bottom_sheet.dart';
import 'package:untitled1/src/features/common_widgets/song_box.dart';
import 'package:untitled1/src/features/constants.dart';
import 'package:untitled1/src/features/controller/user_controller.dart';
import 'package:untitled1/src/features/models/user_cache.dart';

import '../models/user.dart';

class LikedSongsPage extends StatefulWidget {
  final User user;

  const LikedSongsPage({super.key, required this.user});

  @override
  State<StatefulWidget> createState() => _LikedSongsPageState();
}

class _LikedSongsPageState extends State<LikedSongsPage> {

  late UserController userController;
  late User userData;
  @override
  void initState() {
    super.initState();
    userController = UserController(context: context);
    userData = widget.user;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void callSetState(){
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(kOpeningBG),
      appBar: const CommonAppBar(appBarText: 'Liked Songs', canGoBack: true),
      body: ListView.builder(
        itemCount: userData.likedSongs.length,
        itemBuilder: (context, index) {
          Map<dynamic, dynamic> song = userData.likedSongs[index];
          return SongBox(songName: song['song'], artistName: song['artist'], onIconPressed: (){

                showModalBottomSheet(
                    backgroundColor: Colors.green.shade400,
                    isScrollControlled: false,
                    context: context,
                    builder: (BuildContext context) {
                  return Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.11,
                    ),
                    child: LikedSongBottomSheet(
                      song: song,
                      likeSongFunction: () async {
                        // Capture the context before entering the async function
                        BuildContext contextCopy = context;

                        bool response = await userController.removeSongFromLikedList(song['song']);
                        String username = widget.user.username;
                        await userController.updateUserProfile(widget.user.username);
                        userData = UserProfileCache.getUserProfile(username)!;
                        callSetState();
                        String msg = response
                            ? 'Song Successfully Removed From The List'
                            : 'Failed To Remove The Song';
                        String titleMsg = response ? 'Success' : 'Error';
                        if(context.mounted) {
                          showDialog(
                            context: contextCopy, // Use the captured context
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(titleMsg),
                                content: Text(msg), // Display the result message
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () {

                                      if(context.mounted){Navigator.of(context).pop();}

                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }

                      },
                      addSongFunction: () async {
                        showDialog(
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
                                        await userController.addToPlaylist(song['song'], playlistName).then((success) {
                                          if(success) {
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
                                          }
                                          else {
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
                                        } );

                                      },
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),


                  );
                });
          },);
        },
      ),
    );
  }
}
