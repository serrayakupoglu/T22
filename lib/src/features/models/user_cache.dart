import 'package:untitled1/src/features/models/user.dart';

class UserProfileCache {
  static Map<String, User> _cache = {};

  static User? getUserProfile(String username) {
    return _cache[username];
  }

  static void cacheUserProfile(String username, User user) {
    _cache[username] = user;
  }

  static void clearCache() {
    _cache.clear();
  }


}
