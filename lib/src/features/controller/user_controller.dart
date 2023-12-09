import 'package:flutter/material.dart';
import 'package:untitled1/src/features/screen/followers_screen.dart';
import 'package:untitled1/src/features/screen/followings_screen.dart';
import 'package:untitled1/src/features/screen/user_profile_screen.dart';
import '../models/user.dart';
import '../screen/another_user_list.dart';
import '../screen/another_user_profile_screen.dart';
import '../screen/user_lists_screen.dart';
import '../service/user_service.dart';

class UserController {

  final BuildContext context;
  final UserService _userService = UserService();

  UserController({required this.context});

  Future<User> getUserProfile(String username) async {
    try {
      // Call the service to fetch user profile
      User userProfile = await _userService.fetchUserProfile(username);
      return userProfile;
    } catch (e) {
      print('Error in UserController: $e');
      rethrow;
    }
  }

  Future<bool> followUser(String currentUsername, String targetUsername) async {
    final success = await _userService.followUser(currentUsername, targetUsername);
    return success;
  }

  Future<bool> unfollowUser(String currentUsername, String targetUsername) async {
    try {
      bool success = await _userService.unfollowUser(currentUsername, targetUsername);
      return success;
    } catch (e) {
      print('Error in UserController unfollowUser: $e');
      return false;
    }
  }

  void navigateToFollowers(List<String> followers, List<String> followings, String username) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return FollowersPage(followers: followers, followings: followings, currentUserName: username);
    }));
  }

  void navigateToFollowings(List<String> followings, List<String> baseFollowings, String username) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return FollowingsPage(baseFollowings: baseFollowings, followings: followings, currentUserName: username);
    }));
  }

  void navigateToAnotherUserProfile(String username, List<String> baseFollowings) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return AnotherUserProfile(username: username, baseFollowings: baseFollowings,);
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

}




