class FriendSong {
  final String added;
  final String by;
  final String friend;

  FriendSong({
    required this.added,
    required this.by,
    required this.friend,
  });

  factory FriendSong.fromJson(Map<String, dynamic> json) {
    return FriendSong(
      added: json['added'] ?? '',
      by: json['by'] ?? '',
      friend: json['friend'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'added': added,
      'by': by,
      'friend': friend,
    };
  }
}