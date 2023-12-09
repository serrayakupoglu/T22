import 'dart:convert';

class User {
  final String username;
  final String name;
  final String surname;
  final List<String> followers;
  final List<String> followings;
  final List<Map<String, String>> likedSongs;

  User({
    required this.username,
    required this.name,
    required this.surname,
    required this.followers,
    required this.followings,
    required this.likedSongs,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    var profileInfo = json['profile_info'];

    List<String> followers = List<String>.from(profileInfo['followers']);
    List<String> followings = profileInfo.containsKey('following')
        ? List<String>.from(profileInfo['following'])
        : [];

    List<Map<String, String>> likedSongs = [];

    if (profileInfo.containsKey('likedSongs')) {
      var likedSongsList = profileInfo['likedSongs'] as List<dynamic>;
      likedSongs = likedSongsList.map((song) {
        // Assuming 'song' is in the format: {'song': 'Umbrella', 'artist': 'Rihanna'}
        var songMap = jsonDecode(song.replaceAll("'", '"'));
        return Map<String, String>.from(songMap);
      }).toList();
    }

    return User(
      username: profileInfo['username'],
      name: profileInfo['name'],
      surname: profileInfo['surname'],
      followers: followers,
      followings: followings,
      likedSongs: likedSongs,
    );
  }
}




