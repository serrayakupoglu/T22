import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/common_app_bar.dart';
import 'package:untitled1/src/features/constants.dart';
import 'package:untitled1/src/features/controller/user_controller.dart';

class LikedListsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> likedPlaylists; // Add this line

  const LikedListsScreen({Key? key, required this.likedPlaylists})
      : super(key: key); // Add this line

  @override
  State<StatefulWidget> createState() => _LikedListsScreenState();
}

class _LikedListsScreenState extends State<LikedListsScreen> {
  late UserController userController;

  @override
  void initState() {
    userController = UserController(context: context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(kOpeningBG),
      appBar: const CommonAppBar(canGoBack: true, appBarText: 'Liked Lists'),
      body: ListView.builder(
        itemCount: widget.likedPlaylists.length,
        itemBuilder: (context, index) {
          var playlist = widget.likedPlaylists[index];
          String friend = playlist['friend'];
          String playlistName = playlist['playlist_name'];

          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 4,
            child: ListTile(
              contentPadding:
              EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                '$friend\'s Playlist',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colors.black87,
                ),
              ),
              subtitle: Text(
                'Playlist Name: $playlistName',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[600],
                ),
              ),
              onTap: () {
                userController.navigateToLikedListContentPage(context, playlistName, friend);
              },
            ),
          );
        },
      ),
    );
  }
}
