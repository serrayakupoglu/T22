import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/body_text.dart';
import 'package:untitled1/src/features/controller/song_controller.dart';
import 'package:untitled1/src/features/controller/user_controller.dart';
import 'package:untitled1/src/features/models/recommendations_cache.dart';
import 'package:untitled1/src/features/models/recommended_song.dart';
import 'package:untitled1/src/features/repository/user_repository.dart';
import 'package:untitled1/src/features/service/storage_service.dart';
import '../models/friend_recommended_song.dart';
import '../models/last_day_songs.dart';
import '../models/playlist_recommendation_instance.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserController userController;
  late SongController songController;
  late Future<RecommendedSong?> song;
  late Future<FriendSong?> friendSong;
  late Future<String?> username;
  late Future<List<PlaylistRecommendation>> relaxingPlaylist;
  late Future<List<PlaylistRecommendation>> energeticPlaylist;
  late Future<List<PlaylistRecommendation>> playlist;
  late Future<LastDaySongsList> lastDaySongsList;

  @override
  void initState() {
    userController = UserController(context: context);
    songController = SongController(context);
    fetchData();
    super.initState();
  }

  void fetchData() async {
    username = StorageService().readSecureData('username');
    if (!RecommendationsCache.containsRecommendation('recommendedSong')) {
      song = userController.recommendSong();
      RecommendationsCache.setRecommendation('recommendedSong', song);
    } else {
      song = RecommendationsCache.getRecommendation('recommendedSong');
    }

    if (!RecommendationsCache.containsRecommendation('friendSong')) {
      friendSong = userController.recommendSongFromFriends();
      RecommendationsCache.setRecommendation('friendSong', friendSong);
    } else {
      friendSong = RecommendationsCache.getRecommendation('friendSong');
    }

    if (!RecommendationsCache.containsRecommendation('relaxingPlaylist')) {
      relaxingPlaylist = songController.recommendRelaxingPlaylist();
      RecommendationsCache.setRecommendation(
          'relaxingPlaylist', relaxingPlaylist);
    } else {
      relaxingPlaylist =
          RecommendationsCache.getRecommendation('relaxingPlaylist');
    }

    if (!RecommendationsCache.containsRecommendation('energeticPlaylist')) {
      energeticPlaylist = songController.recommendEnergeticPlaylist();
      RecommendationsCache.setRecommendation(
          'energeticPlaylist', energeticPlaylist);
    } else {
      energeticPlaylist =
          RecommendationsCache.getRecommendation('energeticPlaylist');
    }

    if (!RecommendationsCache.containsRecommendation('playlist')) {
      playlist = songController.recommendPlaylist();
      RecommendationsCache.setRecommendation('playlist', playlist);
    } else {
      playlist = RecommendationsCache.getRecommendation('playlist');
    }

    if (!RecommendationsCache.containsRecommendation('lastDayList')) {
      lastDaySongsList = songController.getLastDaySongs();
      RecommendationsCache.setRecommendation('lastDayList', lastDaySongsList);
    } else {
      lastDaySongsList = RecommendationsCache.getRecommendation('lastDayList');
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
        relaxingPlaylist = songController.recommendRelaxingPlaylist();
        RecommendationsCache.setRecommendation('relaxingPlaylist', relaxingPlaylist);
        setState(() {});
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                child: FutureBuilder<String?>(
                  future: username,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return Padding(
                        padding: const EdgeInsets.all(15),
                        child: Text(
                          'Hello, if you would like some music, here are some recommendations!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      );
                    } else {
                      return Container(); // Or some other placeholder
                    }
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle("From Your Recent Likes", Icons.favorite),
                    FutureBuilder<RecommendedSong?>(
                      future: song,
                      builder: (BuildContext context, AsyncSnapshot<RecommendedSong?> snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          final recommendedSong = snapshot.data!;
                          return buildRecommendedSongSection(recommendedSong);
                        } else {
                          return Container(); // Or some other placeholder
                        }
                      },
                    ),
                    sectionTitle("From Your Friend", Icons.group),
                    FutureBuilder<FriendSong?>(
                      future: friendSong,
                      builder: (BuildContext context, AsyncSnapshot<FriendSong?> snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          final friendSong = snapshot.data!;
                          return buildFriendSongSection(friendSong);
                        } else {
                          return Container(); // Or some other placeholder
                        }
                      },
                    ),
                  ],
                )
              ),

              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    sectionTitle("For Your Mood", Icons.sentiment_very_satisfied),
                    moodPlaylistSection("Energetic", Icons.flash_on,
                            () => userController.navigateToRecommendedPlaylistPage(context, 'energeticPlaylist')),
                    moodPlaylistSection("Relaxing", Icons.spa,
                            () => userController.navigateToRecommendedPlaylistPage(context, 'relaxingPlaylist')),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    sectionTitle("From Your Liked Songs", Icons.music_note),
                    buildLikedSongsSection(context),
                  ],
                )

              ),
              Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      sectionTitle("Recently Added Songs", Icons.music_note),
                      moodPlaylistSection('Recent Songs', Icons.update,
                              () => userController.navigateToRecentSongs()),
                    ],
                  )

              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[700], size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRecommendedSongSection(RecommendedSong recommendedSong) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BodyText(msg: "Song:"),
          Text(
            recommendedSong.recommendedSong == ""
                ? "You need To Like a Song"
                : recommendedSong.recommendedSong,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFriendSongSection(FriendSong friendSong) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BodyText(msg: "Recommended by @${friendSong.friend}:"),
          Text(
            friendSong.added == ""
                ? "You Need To Follow At Least One Person"
                : friendSong.added,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget moodPlaylistSection(String title, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.green[700]),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget buildLikedSongsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              userController.navigateToRecommendedPlaylistPage(context, 'playlist');
            },
            child: const Text(
              "Recommended playlist based on your liked songs!",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Change the color to your preference
                decoration: TextDecoration.underline, // Optional underline
              ),
            ),
          ),
          // You can include other widgets here
        ],
      ),
    );
  }

}
