import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/common_app_bar.dart';
import '../common_widgets/playlist_creation_dialog.dart';
import '../constants.dart';
import '../controller/user_controller.dart';
import '../models/user.dart';
import '../service/storage_service.dart';

class SongListScreen extends StatefulWidget{
  final String username;
  final bool hasFloatingButton;
  const SongListScreen({super.key, required this.username, required this.hasFloatingButton});

  @override
  State<StatefulWidget> createState() => _SongListScreenState();

}

class _SongListScreenState extends State<SongListScreen>{
  late UserController controller;
  late Future<User?> userData;

  @override
  void initState() {
    controller = UserController(context: context);
    userData = fetchData();
    super.initState();
  }

  Future<User?> fetchData() async {
    return controller.getUserProfile(widget.username);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: widget.hasFloatingButton ? FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return PlaylistCreationDialog(
                onSuccess: () {
                  setState(() {});
                },
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ) : null,
      backgroundColor: const Color(kSignInPageBG),
      appBar:  CommonAppBar(canGoBack: true, appBarText: widget.hasFloatingButton ? kMyListsAppBarText : kListsAppBarText),
      body:  FutureBuilder(
        future: userData,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Display a loading indicator while fetching data
          } else if(snapshot.hasData && snapshot.data != null) {
            User? user = snapshot.data!;
            for (int i = 0; i < user.playlists.length; i++) {
              for (int j = 0; j < user.playlists[i].tracks.length; j++) {
                print(user.playlists[i].tracks[j].songName);
              }
            }
            return ListView.builder(
              itemCount: user.playlists.length  ?? 0,
              itemBuilder: (context, index) {
                String playlistName = user.playlists[index].name ?? '';
                int songCount = user.playlists[index].tracks.length;
                String isOrAre = songCount > 1 ? 'are' : 'is';
                String singleOrNot = songCount > 1 ? 's' : '';

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    tileColor: Colors.grey[200], // Background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(
                        Icons.music_note,
                        color: Colors.black,
                      ),
                    ),
                    title: Text(
                      '$playlistName',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      'There $isOrAre $songCount song$singleOrNot in this playlist',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[600],
                      ),
                    ),
                    onTap: () {
                      controller.navigateToPlaylistContentPage(context, user.playlists[index].tracks, user.playlists[index].name, widget.hasFloatingButton, widget.username);
                    },
                  ),
                );




              },
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

}