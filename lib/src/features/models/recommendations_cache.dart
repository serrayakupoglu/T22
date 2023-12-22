class RecommendationsCache {

  static Map<String, dynamic> _cache = {};

  static dynamic getRecommendation(String key) {
    return _cache[key];
  }

  static void setRecommendation(String key, dynamic value) {
    _cache[key] = value;
  }

  static bool containsRecommendation(String key) {
    return _cache.containsKey(key);
  }

  static void clear() {
    _cache.clear();
  }
}
