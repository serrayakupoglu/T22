import 'dart:convert';

import 'package:untitled1/src/features/models/song.dart';

class User {
  final String username;
  final String name;
  final String surname;
  final List<String> followers;
  final List<String> followings;
  final List<Map<String, String>> likedSongs;
  final List<Playlist> playlists;

  User({
    required this.username,
    required this.name,
    required this.surname,
    required this.followers,
    required this.followings,
    required this.likedSongs,
    required this.playlists,
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
        var songMap = jsonDecode(song.replaceAll("'", '"'));
        return Map<String, String>.from(songMap);
      }).toList();
    }

    List<Playlist> playlists = [];

    if (profileInfo.containsKey('playlists')) {
      var playlistsList = profileInfo['playlists'] as List<dynamic>;
      playlists = playlistsList.map((playlist) {
        String playlistName = playlist['playlist_name'].toString();

        List<Song> songs = [];

        if (playlist.containsKey('tracks')) {
          var tracksList = playlist['tracks'] as List<dynamic>;
          songs = tracksList.map<Song>((track) {
            return Song.fromJson(track as Map<String, dynamic>);
          }).toList();
        }

        return Playlist(name: playlistName, tracks: songs);
      }).toList();
    }

    return User(
      username: profileInfo['username'],
      name: profileInfo['name'],
      surname: profileInfo['surname'],
      followers: followers,
      followings: followings,
      likedSongs: likedSongs,
      playlists: playlists,
    );
  }
}

class Playlist {
  final String name;
  final List<Song> tracks;

  Playlist({
    required this.name,
    required this.tracks,
  });

}
