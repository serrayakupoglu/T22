import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/common_app_bar.dart';
import 'package:untitled1/src/features/common_widgets/header_text.dart';
import 'package:untitled1/src/features/controller/user_controller.dart';
import 'package:untitled1/src/features/repository/user_repository.dart';
import '../common_widgets/analysis_box.dart';
import '../common_widgets/pie_widget.dart';
import '../models/genre_percentage.dart';
import '../models/top_rated.dart';
import '../models/user_mood_model.dart';

class AnalysisPage extends StatefulWidget{
  final String username;

  const AnalysisPage({super.key, required this.username});

  @override
  State<StatefulWidget> createState() => _AnalysisPageState();

}

class _AnalysisPageState extends State<AnalysisPage> {
  late UserController userController;
  late Future<TopRated> mostLikedGenre;
  late Future<int> mostLikedYear;
  late Future<GenrePercentage> genrePercentages;
  late Future<UserSongs> moodSongs;
  @override
  void initState() {
    super.initState();
    userController = UserController(context: context);
    mostLikedGenre = fetchMostLikedGenre();
    mostLikedYear = fetchMostLikedYear();
    genrePercentages = fetchGenrePercentage();
    moodSongs = fetchMoodData();
    UserRepository().analyzeUserMode();
  }

  Future<TopRated> fetchMostLikedGenre() async {
    return userController.getMostLikedGenre(widget.username);
  }
  Future<int> fetchMostLikedYear() async {
    return userController.getMostLikedYear(widget.username);
  }

  Future<GenrePercentage> fetchGenrePercentage() async {
    return userController.getGenrePercentage(widget.username);
  }

  Future<UserSongs> fetchMoodData() async {
    return userController.analyzeUserMode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: const CommonAppBar(appBarText: "Analysis", canGoBack: true),
      body: ListView(
        children: [
          FutureBuilder<TopRated>(
            future: mostLikedGenre,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return AnalysisBox(
                  headerText: "Most Liked Genre: ${snapshot.data!.higherRatedGenre.toUpperCase()}",
                  innerWidget: Text(
                    style: const TextStyle(color: Colors.green),
                    'Avg Rating: ${snapshot.data!.averageRating}',
                  ),
                );
              }
              else {
                return const HeaderText(msg: "");
              }
            },
          ),


          FutureBuilder<int>(
            future: mostLikedYear,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return AnalysisBox(
                  headerText: 'Average Year Of Likings',
                  innerWidget: Text('${snapshot.data!}',style: const TextStyle(color: Colors.green),),
                );
              } else {
                return HeaderText(msg: "");
              }
            },
          ),
          FutureBuilder<GenrePercentage>(
            future: genrePercentages, // Assuming getGenrePercentage returns GenrePercentage
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return HeaderText(msg: "");
              } else if (snapshot.hasError) {
                return HeaderText(msg: "Error: ${snapshot.error}");
              } else {
                GenrePercentage genrePercentage = snapshot.data!;
                // Access the data within GenrePercentage
                Map<String, double> data = genrePercentage.data;
                return AnalysisBox(headerText: 'Genre Percentages', innerWidget: PieChartWidget(data));
              }
            },
          ),
        FutureBuilder<UserSongs>(
          future: moodSongs, // Assuming moodSongs is a Future<UserSongs>
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return HeaderText(msg: "");
            } else if (snapshot.hasError) {
              return HeaderText(msg: "Error: ${snapshot.error}");
            } else {
                UserSongs userSongs = snapshot.data!;
                String msg = userSongs.message;
                List<SongMood> happySongs = userSongs.happySongs;
                List<SongMood> sadSongs = userSongs.sadSongs;
                return AnalysisBox(
                    headerText: 'Mood Analysis',
                    innerWidget: Text(msg,style: const TextStyle(color: Colors.green),)
                );
              }
            },
          )
        ],
      ),
    );
  }
  Widget buildSongListWidget(List<SongMood> songs) {
    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        SongMood song = songs[index];
        return ListTile(
          title: Text(song.songName),
          subtitle: Text('Danceability: ${song.danceability}, Energy: ${song.energy}'),
        );
      },
    );
  }
}


