import '../models/user.dart';
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

  Future<bool> followUser(String currentUsername, String targetUsername) async {
    try {
      final response = await _userRepository.followUser(currentUsername, targetUsername);

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

  Future<bool> unfollowUser(String currentUsername, String targetUsername) async {
    try {
      final response = await _userRepository.unfollowUser(currentUsername, targetUsername);

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



}
