class TopRated {
  final double averageRating;
  final String higherRatedGenre;

  TopRated({required this.averageRating, required this.higherRatedGenre});

  factory TopRated.fromJson(Map<String, dynamic> json) {
    return TopRated(
      averageRating: json['average_rating'] as double,
      higherRatedGenre: json['higher_rated_genre'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average_rating': averageRating,
      'higher_rated_genre': higherRatedGenre,
    };
  }
}
