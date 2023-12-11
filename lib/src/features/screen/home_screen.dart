import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/body_text.dart';
import 'package:untitled1/src/features/common_widgets/common_app_bar.dart';
import 'package:untitled1/src/features/controller/user_controller.dart';
import 'package:untitled1/src/features/models/recommended_song.dart';
import 'package:untitled1/src/features/screen/search_screen.dart';
import 'package:untitled1/src/features/screen/user_profile_screen.dart';

import '../models/friend_recommended_song.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserController userController;
  late Future<RecommendedSong?> song;
  late Future<FriendSong?> friendSong;

  @override
  void initState() {
    userController = UserController(context: context);
    song = userController.recommendSong();
    friendSong = userController.recommendSongFromFriends();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<RecommendedSong?>(
          future: song,
          builder: (BuildContext context,
              AsyncSnapshot<RecommendedSong?> snapshot) {
            if (snapshot.hasData) {
              final recommendedSong = snapshot.data!;
              return Container(
                child: Column(
                  children: [
                    SizedBox(height: 10,),
                    BodyText(msg: "From Your Recent Likes:"),
                    SizedBox(height: 10), // Add space between texts
                    Text(
                      recommendedSong.recommendedSong == "" ? "You need To Like a Song" : recommendedSong.recommendedSong,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue, // Customize text color
                      ),
                    ),
                    SizedBox(height: 10,)
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        ),
        FutureBuilder<FriendSong?>(
          future: friendSong,
          builder: (BuildContext context,
              AsyncSnapshot<FriendSong?> snapshot) {
            if (snapshot.hasData) {
              final friendSong = snapshot.data!;
              return Container(
                child: Column(
                  
                  children: [
                    BodyText(msg: "From Your Friend @${friendSong.friend}:"),
                    SizedBox(height: 10), // Add space between texts
                    Text(
                      friendSong.added == "" ? "You Need To Follow At Least One Person": friendSong.added,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue, // Customize text color
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        )
      ],
    );
  }
}


