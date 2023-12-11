class RecommendedSong {
  final String genre;
  final String recommendedSong;

  RecommendedSong({
    required this.genre,
    required this.recommendedSong,
  });

  factory RecommendedSong.fromJson(Map<String, dynamic> json) {
    return RecommendedSong(
      genre: json['genre'] ?? '',
      recommendedSong: json['recommended_song'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'genre': genre,
      'recommended_song': recommendedSong,
    };
  }
}