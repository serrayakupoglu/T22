import 'package:flutter/material.dart';
import 'package:untitled1/src/features/common_widgets/common_app_bar.dart';
import 'package:untitled1/src/features/models/recommendations_cache.dart';

import '../constants.dart';
import '../models/playlist_recommendation_instance.dart';

class RecommendedPlaylistScreen extends StatefulWidget {
  final String playlistName;
  const RecommendedPlaylistScreen({super.key, required this.playlistName});
  
  @override
  State<StatefulWidget> createState() => _RecommendedPlaylistScreenState();

}

class _RecommendedPlaylistScreenState extends State<RecommendedPlaylistScreen>{
  late Future<List<PlaylistRecommendation>> playlist;
  
  @override
  void initState() {
    fetchPlaylist();
    super.initState();
  }
  
  void fetchPlaylist () async {
    playlist = RecommendationsCache.getRecommendation(widget.playlistName);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(appBarText: widget.playlistName, canGoBack: true),
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
                return Card(
                  child: ListTile(
                    title: Text(recommendation.artist),
                    subtitle: Text(recommendation.songName),
                  ),
                );
              },
            );
          }
        },
      ),

    );
  }

}