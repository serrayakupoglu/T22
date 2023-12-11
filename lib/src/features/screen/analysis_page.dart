import 'package:charts_flutter_new/flutter.dart' as charts;
import 'package:charts_flutter_new/flutter.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/common_app_bar.dart';
import 'package:untitled1/src/features/common_widgets/genre_percentage_chart.dart';
import 'package:untitled1/src/features/common_widgets/header_text.dart';
import 'package:untitled1/src/features/common_widgets/song_box.dart';
import 'package:untitled1/src/features/constants.dart';
import 'package:untitled1/src/features/controller/user_controller.dart';
import 'package:untitled1/src/features/models/user.dart';
import '../common_widgets/analysis_box.dart';
import '../models/top_rated.dart';

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


  @override
  void initState() {
    super.initState();
    userController = UserController(context: context);
    mostLikedGenre = fetchMostLikedGenre();
    mostLikedYear = fetchMostLikedYear();
  }

  Future<TopRated> fetchMostLikedGenre() async {
    return userController.getMostLikedGenre(widget.username);
  }
  Future<int> fetchMostLikedYear() async {
    return userController.getMostLikedYear(widget.username);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(appBarText: "Analysis", canGoBack: true),
      backgroundColor: Colors.black26,
      body: Column(
        children: [
          FutureBuilder<TopRated>(
            future: mostLikedGenre,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return AnalysisBox(
                  innerText: "Most Liked Genre: ${snapshot.data!.higherRatedGenre.toUpperCase()}, Avg Rating: ${snapshot.data!.averageRating}",
                );
              } else {
                return HeaderText(msg: "Data Is Loading...");
              }
            },
          ),
          FutureBuilder<int>(
            future: mostLikedYear,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return AnalysisBox(
                  innerText: "Average Year Of Likings: ${snapshot.data!}",
                );
              } else {
                return HeaderText(msg: "Data Is Loading...");
              }
            },
          ),
        ],
      ),
    );
  }
}


