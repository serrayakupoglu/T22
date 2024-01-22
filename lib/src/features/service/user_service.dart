import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:untitled1/src/features/models/genre_percentage.dart';
import 'package:untitled1/src/features/models/recommendations_cache.dart';
import 'package:untitled1/src/features/models/user_cache.dart';
import 'package:untitled1/src/features/service/storage_service.dart';

import '../models/friend_recommended_song.dart';
import '../models/recommended_song.dart';
import '../models/search_user.dart';
import '../models/top_rated.dart';
import '../models/user.dart';
import '../models/user_mood_model.dart';
import '../repository/user_repository.dart';

class UserService {
  final UserRepository _userRepository = UserRepository();

  Future<User> fetchUserProfile(String username) async {
    try {
      // Fetch profile information from the repository
      User user = await _userRepository.getProfileInfo(username);
      return user;
    } catch (e) {
      print('Error fetching user profile: $e');
      rethrow; // Return error
    }
  }

  Future<bool> followUser(String targetUsername) async {
    try {
      final response = await _userRepository.followUser(targetUsername);

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error following user: $e');
      return false;
    }
  }

  Future<bool> unfollowUser(String targetUsername) async {
    try {
      final response = await _userRepository.unfollowUser(targetUsername);

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error unfollowing user: $e');
      return false;
    }
  }

  Future<bool> logout(String username) async {
    try{
      final response = await _userRepository.logout(username);

      if (response.statusCode == 200) {
        UserProfileCache.clearCache();
        RecommendationsCache.clear();
        StorageService().deleteSecureData('username');
        StorageService().deleteSecureData('session');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error Logout: $e');
      return false;
    }
  }

  Future<bool> addSongToLikedList (String username, String songName) async {
    final response = await _userRepository.addSongToLikedList(username, songName);

    if(response.statusCode == 200) {

      return true;
    }
    return false;
  }

  Future<bool> removeSongFromLikedList(String songName) async {
    final response = await _userRepository.removeSongFromLikedList(songName);

    if(response.statusCode == 200) {
      return true;
    }
    return false;
  }


  Future<bool> removeSongFromPlaylist(String songName, String playlistName) async {
    final response = await _userRepository.removeSongFromPlaylist(songName, playlistName);
    if(response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<List<SearchUser>> searchUser(String username) async {
    final response = await _userRepository.searchUser(username);

    final Map<String, dynamic> jsonMap = json.decode(response.body);
    List<SearchUser> userList = SearchUser.parseUsersFromJson(jsonMap);
    return userList;
    
  }

  Future<TopRated> getMostLikedGenre(String username) async {
    final response = await _userRepository.getMostLikedGenre(username);
    final Map<String, dynamic> jsonData = json.decode(response.body);
    return TopRated.fromJson(jsonData);
  }

  Future<int> getMostLikedYear(String username) async {
    final response = await _userRepository.getMostLikedYear(username);
    Map<String, dynamic> data = json.decode(response.body);
    dynamic value = data['most liked average year'];
    return value;
  }

  Future<GenrePercentage> getGenrePercentage(String username) async {
    final response = await _userRepository.getGenrePercentage(username);
    return response;
  }

  Future<UserSongs> analyzeUserMode() async {
    final response = await _userRepository.analyzeUserMode();
    return response;
  }

  Future<RecommendedSong> recommendSong() async {
    final response = await _userRepository.recommendSong();
    final Map<String, dynamic> responseBody = json.decode(response.body);
    final RecommendedSong recommendedSong = RecommendedSong.fromJson(responseBody);
    return recommendedSong;
  }

  Future<FriendSong> recommendSongFromFriends() async {
    final response = await _userRepository.recommendSongFromFriends();
    final Map<String, dynamic> responseBody = json.decode(response.body);
    final FriendSong friendSong = FriendSong.fromJson(responseBody);
    return friendSong;

  }

  Future<bool> createPlaylist(String playlistName) async {
    final response = await _userRepository.createPlaylist(playlistName);

    if(response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> addToPlaylist(String songName, String playlistName) async {
    final response = await _userRepository.addToPlaylist(songName, playlistName);
    if(response.statusCode == 200) {
      return true;
    }
    return false;
  }




}
