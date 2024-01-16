import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/body_text.dart';
import 'package:untitled1/src/features/controller/user_controller.dart';
import 'package:untitled1/src/features/models/recommendations_cache.dart';
import 'package:untitled1/src/features/models/recommended_song.dart';
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
    fetchData();
    super.initState();
  }

  void fetchData () async {

    if(!RecommendationsCache.containsRecommendation('recommendedSong')) {
      song = userController.recommendSong();
      RecommendationsCache.setRecommendation('recommendedSong', song);
    } else {
      song = RecommendationsCache.getRecommendation('recommendedSong');
    }

    if(!RecommendationsCache.containsRecommendation('friendSong')) {
      friendSong = userController.recommendSongFromFriends();
      RecommendationsCache.setRecommendation('friendSong', friendSong);
    } else {
      friendSong =  RecommendationsCache.getRecommendation('friendSong');
    }

  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        song = userController.recommendSong();
        RecommendationsCache.setRecommendation('recommendedSong', song);
        friendSong = userController.recommendSongFromFriends();
        RecommendationsCache.setRecommendation('friendSong', friendSong);
        setState(() {});
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            FutureBuilder<RecommendedSong?>(
              future: song,
              builder: (BuildContext context,
                  AsyncSnapshot<RecommendedSong?> snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
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
                if (snapshot.hasData && snapshot.data != null) {
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
        ),
      ),
    );
  }
}


