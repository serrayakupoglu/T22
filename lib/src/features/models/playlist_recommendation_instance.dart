class PlaylistRecommendation {
  String artist;
  String songName;

  PlaylistRecommendation._(this.artist, this.songName);

  factory PlaylistRecommendation.fromJson(Map<String, dynamic> json) {
    return PlaylistRecommendation._(json["artist"], json["song_name"]);
  }

  @override
  String toString() {
    return 'Artist: $artist, Song: $songName';
  }
}