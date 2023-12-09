class Song {
  String albumId;
  String albumName;
  List<Map<String, String>> artists;
  String songName;
  int popularity;

  Song({
    required this.albumId,
    required this.albumName,
    required this.artists,
    required this.songName,
    required this.popularity,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    List<Map<String, String>> parsedArtists = [];

    if (json['artists'] != null) {
      parsedArtists = List<Map<String, String>>.from(json['artists'].map((artist) {
        if (artist is Map<String, dynamic>) {
          return {
            'id': artist['id'].toString(),
            'name': artist['name'].toString()
          };
        }
        return {
          'id': '',
          'name': ''
        };
      }));
    }

    return Song(
      albumId: json['album']['id'].toString(),
      albumName: json['album']['name'].toString(),
      artists: parsedArtists,
      songName: json['name'].toString(),
      popularity: json['popularity'] as int,
    );
  }

  String getConcatenatedArtistNames() {
    return artists.map((artist) => artist['name']).join(', ');
  }
}