import 'dart:convert';
import 'dart:ffi';

import 'package:untitled1/src/features/models/song.dart';
class User {
  final String username;
  final String name;
  final String surname;
  final List<String> followers;
  final List<String> followings;
  final List<Map<String, dynamic>> likedSongs; // Correct type to Map<String, dynamic>
  final List<Playlist> playlists;
  final List<Map<String, dynamic>> ratedSongs;
  final List<Map<String, dynamic>> likedPlaylists;
  User({
    required this.username,
    required this.name,
    required this.surname,
    required this.followers,
    required this.followings,
    required this.likedSongs,
    required this.playlists,
    required this.ratedSongs,
    required this.likedPlaylists,
  });

  List<Map<String, dynamic>> searchSongsByName(String songName) {
    return ratedSongs.where((ratedSong) {
      return ratedSong['song_name'].toLowerCase() == songName.toLowerCase();
    }).toList();
  }

  factory User.fromJson(Map<String, dynamic> json) {



    var profileInfo = json['profile_info'];
    List<Map<String, dynamic>> ratedSongs = [];
    if (profileInfo.containsKey('rated_songs')) {
      var ratedSongsList = profileInfo['rated_songs'] as List<dynamic>;
      ratedSongs = ratedSongsList.map((ratedSong) {
        // Extract the song name and rating
        String songName = ratedSong.keys.first;
        int rating = ratedSong[songName];

        return {
          'song_name': songName,
          'rating': rating,
        };
      }).toList();
    }

    List<Map<String, dynamic>> likedPlaylists = [];

    if (profileInfo.containsKey('likedPlaylists')) {
      var likedPlaylistsList = profileInfo['likedPlaylists'] as List<dynamic>;
      likedPlaylists = likedPlaylistsList.map((playlist) {
        String friend = playlist['friend'].toString();
        String playlistName = playlist['playlist_name'].toString();

        return {
          'friend': friend,
          'playlist_name': playlistName,
        };
      }).toList();
    }

    List<String> followers = List<String>.from(profileInfo['followers']);
    List<String> followings = profileInfo.containsKey('following')
        ? List<String>.from(profileInfo['following'])
        : [];

    List<Map<String, dynamic>> likedSongs = [];

    if (profileInfo.containsKey('likedSongs')) {
      var likedSongsList = profileInfo['likedSongs'] as List<dynamic>;
      likedSongs = likedSongsList.map((song) {

        // Convert the datetime string to a Dart DateTime object
        DateTime likedAt = DateTime.parse(song['liked_at']);

        // Extract the rating, handling the case when it's null
        var rating = song['rating'] ;
        rating = rating ?? -1;
        var artist = song['artist'];
        artist = artist ?? "";
        return {
          'song': song['song'],
          'artist': artist,
          'liked_at': likedAt,
          'rating': rating,
        };

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
      ratedSongs: ratedSongs,
      likedPlaylists: likedPlaylists,
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
