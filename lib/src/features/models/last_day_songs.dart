class LastDaySongsList {
  List<LastDaySongs> lastDaySongsList;

  LastDaySongsList({required this.lastDaySongsList});

  factory LastDaySongsList.fromJson(List<dynamic> json) {
    List<LastDaySongs> lastDaySongs = json.map((item) => LastDaySongs.fromJson(item)).toList();
    return LastDaySongsList(lastDaySongsList: lastDaySongs);
  }
}

class LastDaySongs {
  String artistName;
  List<String> genre;
  String songName;

  LastDaySongs({
    required this.artistName,
    required this.genre,
    required this.songName,
  });

  factory LastDaySongs.fromJson(Map<String, dynamic> json) {
    return LastDaySongs(
      artistName: json['artist_name'],
      genre: List<String>.from(json['genre']),
      songName: json['song_name'],
    );
  }
}