class SongMood {
  double danceability;
  double energy;
  String songName;

  SongMood({
    required this.danceability,
    required this.energy,
    required this.songName,
  });

  factory SongMood.fromJson(Map<String, dynamic> json) {
    return SongMood(
      danceability: json['danceability'] as double,
      energy: json['energy'] as double,
      songName: json['song_name'] as String,
    );
  }
}

class UserSongs {
  List<SongMood> happySongs;
  List<SongMood> sadSongs;
  String message;

  UserSongs({
    required this.happySongs,
    required this.sadSongs,
    required this.message,
  });

  factory UserSongs.fromJson(Map<String, dynamic> json) {
    final List<dynamic> happySongsJson = json['happy_songs'] ?? [];
    final List<dynamic> sadSongsJson = json['sad_songs'] ?? [];

    List<SongMood> happySongs = happySongsJson
        .map((happySongJson) => SongMood.fromJson(happySongJson))
        .toList();

    List<SongMood> sadSongs =
    sadSongsJson.map((sadSongJson) => SongMood.fromJson(sadSongJson)).toList();

    return UserSongs(
      happySongs: happySongs,
      sadSongs: sadSongs,
      message: json['message'] as String,
    );
  }
}
