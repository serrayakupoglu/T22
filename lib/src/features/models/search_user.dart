class SearchUser {
  final String name;
  final String surname;
  final String username;

  SearchUser({
    required this.name,
    required this.surname,
    required this.username,
  });

  factory SearchUser.fromJson(Map<String, dynamic> json) {
    return SearchUser(
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      username: json['username'] ?? '',
    );
  }

  static List<SearchUser> parseUsersFromJson(Map<String, dynamic> jsonMap) {
    List<dynamic> results = jsonMap['results'];
    return results.map((userJson) => SearchUser.fromJson(userJson)).toList();
  }
}
