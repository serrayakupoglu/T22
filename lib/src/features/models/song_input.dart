class SongData {
  final String id;
  final String name;
  final int durationMs;
  final int popularity;
  final Map<String, dynamic> album;
  final List<Map<String, dynamic>> artists;

  SongData({
    required this.id,
    required this.name,
    required this.durationMs,
    required this.popularity,
    required this.album,
    required this.artists,
  });

  factory SongData.fromJson(Map<String, dynamic> json) {
    final albumJson = json['album'] as Map<String, dynamic> ?? {};
    final List<dynamic>? artistsJson = json['artists'];

    return SongData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      durationMs: json['duration_ms'] ?? 0,
      popularity: json['popularity'] ?? 0,
      album: albumJson,
      artists: artistsJson?.cast<Map<String, dynamic>>() ?? [],
    );
  }
}