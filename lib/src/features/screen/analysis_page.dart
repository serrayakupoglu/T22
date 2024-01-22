
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
import '../common_widgets/pie_widget.dart';
import '../models/genre_percentage.dart';
import '../models/top_rated.dart';
import '../constants.dart';
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

  @override
  void initState() {
    super.initState();
    userController = UserController(context: context);
    mostLikedGenre = fetchMostLikedGenre();
    mostLikedYear = fetchMostLikedYear();
    genrePercentages = fetchGenrePercentage();
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
                    'Avg Rating: ${snapshot.data!.averageRating}',
                  ),
                );
              } else {
                return HeaderText(msg: "Data Is Loading...");
              }
            },
          ),


          // FutureBuilder<int>(
          //   future: mostLikedYear,
          //   builder: (context, snapshot) {
          //     if (snapshot.hasData) {
          //       return AnalysisBox(
          //         //innerText: "Average Year Of Likings: ${snapshot.data!}",
          //       );
          //     } else {
          //       return HeaderText(msg: "Data Is Loading...");
          //     }
          //   },
          // ),
          // FutureBuilder<GenrePercentage>(
          //   future: genrePercentages, // Assuming getGenrePercentage returns GenrePercentage
          //   builder: (context, snapshot) {
          //     if (snapshot.connectionState == ConnectionState.waiting) {
          //       return HeaderText(msg: "Data Is Loading...");
          //     } else if (snapshot.hasError) {
          //       return HeaderText(msg: "Error: ${snapshot.error}");
          //     } else {
          //       GenrePercentage genrePercentage = snapshot.data!;
          //
          //       // Access the data within GenrePercentage
          //       Map<String, double> data = genrePercentage.data;
          //
          //       return Column(
          //         children: [
          //           // Display the Pie Chart using the PieChartWidget class
          //           PieChartWidget(data),
          //           // Display additional information or customize the UI as needed
          //
          //         ],
          //       );
          //     }
          //   },
          // ),
        ],
      ),
    );
  }
}


