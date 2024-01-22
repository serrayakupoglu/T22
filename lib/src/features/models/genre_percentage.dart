class GenrePercentage {
  final Map<String, double> data;

  GenrePercentage(this.data);

  factory GenrePercentage.fromJson(Map<String, dynamic> json) {
    // Convert the dynamic map to Map<String, double>
    Map<String, double> parsedData = {};
    json.forEach((key, value) {
      parsedData[key] = value.toDouble(); // Assuming the values are always numeric
    });

    return GenrePercentage(parsedData);
  }
}