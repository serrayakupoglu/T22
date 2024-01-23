import 'package:flutter/material.dart';
import 'package:untitled1/src/features/models/friend_recommended_song.dart';
import 'package:untitled1/src/features/models/genre_percentage.dart';
import 'package:untitled1/src/features/screen/followers_screen.dart';
import 'package:untitled1/src/features/screen/followings_screen.dart';
import 'package:untitled1/src/features/screen/liked_lists_screen.dart';
import 'package:untitled1/src/features/screen/opening_screen.dart';
import 'package:untitled1/src/features/screen/playlists_screen.dart';
import 'package:untitled1/src/features/screen/recommended_playlist_screen.dart';
import 'package:untitled1/src/features/service/storage_service.dart';
import '../models/recommended_song.dart';
import '../models/search_user.dart';
import '../models/song.dart';
import '../models/top_rated.dart';
import '../models/user.dart';
import '../models/user_cache.dart';
import '../models/user_mood_model.dart';
import '../screen/analysis_page.dart';
import '../screen/another_user_followers.dart';
import '../screen/another_user_followings.dart';
import '../screen/another_user_list.dart';


import '../screen/another_user_profile_screen.dart';
import '../screen/last_day_songs_screen.dart';
import '../screen/liked_playlist_content_page.dart';
import '../screen/liked_songs_screen.dart';
import '../screen/playlist_content_screen.dart';
import '../service/user_service.dart';

class UserController {

  final BuildContext context;
  final UserService _userService = UserService();

  UserController({required this.context});

  Future<User> getUserProfile(String username) async {

    User? userProfile = UserProfileCache.getUserProfile(username);

    if( userProfile != null){
      return userProfile;
    }

    try {
      User userProfile = await _userService.fetchUserProfile(username);
      UserProfileCache.cacheUserProfile(userProfile.username, userProfile);
      return userProfile;
    } catch (e) {
      print('Error in UserController: $e');
      rethrow;
    }
  }

  Future<User> updateUserProfile(String username) async {

    try {
      User userProfile = await _userService.fetchUserProfile(username);
      UserProfileCache.cacheUserProfile(userProfile.username, userProfile);
      return userProfile;
    } catch (e) {
      print('Error in UserController: $e');
      rethrow;
    }
  }

  Future<bool> followUser(String targetUsername) async {
    final success = await _userService.followUser(targetUsername);

    return success;
  }

  Future<bool> unfollowUser(String targetUsername) async {
    try {
      bool success = await _userService.unfollowUser(targetUsername);
      return success;
    } catch (e) {
      print('Error in UserController unfollowUser: $e');
      return false;
    }
  }

  Future<void> logout (String username) async {
    print('object2');
    final success = await _userService.logout(username);
    if(success == true) {
      storageService.deleteSecureData('username');
      storageService.deleteSecureData('session');
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return OpeningPage();
      }));
    }
  }

  Future<bool> addSongToLikedList (String username, String songName) async {

    final response = await _userService.addSongToLikedList(username, songName);
    if (response == true) updateUserProfile(username);
    return response;
  }

  Future<bool> removeSongFromLikedList(String songName) async {
    final response = await _userService.removeSongFromLikedList(songName);
    return response;
  }

  Future<bool> removeSongFromPlaylist(String songName, String playlistName) async {
    final response = await _userService.removeSongFromPlaylist(songName, playlistName);
    return response;
  }

  Future<List<SearchUser>> searchUser(String username) async {
    return await _userService.searchUser(username);
  }

  Future<TopRated> getMostLikedGenre(String username) async {
    final response = await _userService.getMostLikedGenre(username);
    return response;
  }

  Future<int> getMostLikedYear(String username) async {
    final response = await _userService.getMostLikedYear(username);
    return response;
  }

  Future<GenrePercentage> getGenrePercentage(String username) async {
    final response = await _userService.getGenrePercentage(username);
    return response;
  }

  Future<UserSongs> analyzeUserMode() async {
    final response = await _userService.analyzeUserMode();
    return response;
  }

  Future<RecommendedSong> recommendSong() async {
    final response = await _userService.recommendSong();
    return response;
  }

  Future<FriendSong> recommendSongFromFriends() async {
    final response = await _userService.recommendSongFromFriends();
    return response;
  }

  Future<bool> createPlaylist(String playlistName) async {
    final response = await _userService.createPlaylist(playlistName);
    return response;
  }

  Future<bool> addToPlaylist(String songName, String playlistName) async {
    final response = await _userService.addToPlaylist(songName, playlistName);
    return response;
  }

  Future<bool> likePlaylist(String playlistName, String friendName) async {
    final response = await _userService.likePlaylist(playlistName, friendName);
    return response;
  }

  void navigateToRecentSongs() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return LastDaySongsScreen();
    }));
  }

  void navigateToFollowers(List<String> followers, List<String> followings, String username, VoidCallback onAction) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return FollowersPage(followers: followers, followings: followings, currentUserName: username, onUpdate: onAction,);
    }));
  }

  void navigateToFollowings(List<String> followings, List<String> baseFollowings, String username, VoidCallback onAction) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return FollowingsPage(baseFollowings: baseFollowings, followings: followings, currentUserName: username, onUpdate: onAction);
    }));
  }

  void navigateToAnotherUserFollowers(String username, VoidCallback onAction) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return AnotherUserFollowersPage(currentUserName: username, onUpdate: (){},);
    }));
  }

  void navigateToAnotherUserFollowings(String username, VoidCallback onAction) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return AnotherUserFollowingsPage(currentUserName: username, onUpdate: (){},);
    }));
  }

  void navigateToAnalysis(String username) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return AnalysisPage(username: username);
    }));
  }

  void navigateToLikedLists(List<Map<String, dynamic>> likedLists) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return LikedListsScreen(likedPlaylists: likedLists);
    }));
  }



  void navigateToAnotherUserProfile(String username, VoidCallback onAction) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return AnotherUserProfile(username: username, onUpdate: onAction,);
    }));
  }

  void navigateToLikedSongsPage(BuildContext context, User user) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return LikedSongsPage(user: user);
    }));
  }

  void navigateOthersToLikedSongsPage(BuildContext context, User user) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return OthersLikedSongsPage(user: user);
    }));
  }

  void navigateToMyListsPage(BuildContext context, String username, bool hasAddButton) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return SongListScreen(username: username, hasFloatingButton: hasAddButton);
    }));
  }

  void navigateToPlaylistContentPage(BuildContext context, List<Song> songList, String listName, bool isOwn, String username) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return PlaylistContentPage(listOfSongs: songList, listName: listName, isOwn: isOwn, username: username);
    }));
  }

  void navigateToLikedListContentPage(BuildContext context, String playlistName, String username) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return LikedListContentPage(playlistName: playlistName, username: username);
    }));
  }

  void navigateToRecommendedPlaylistPage(BuildContext context, String listName) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return RecommendedPlaylistScreen(playlistName: listName);
    }));
  }

}




