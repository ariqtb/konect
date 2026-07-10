class LeaderboardUser {
  final String id;
  final String name;
  final int score;
  final int rank;
  final bool isCurrentUser;

  const LeaderboardUser({
    required this.id,
    required this.name,
    required this.score,
    required this.rank,
    required this.isCurrentUser,
  });

  LeaderboardUser copyWith({
    String? id,
    String? name,
    int? score,
    int? rank,
    bool? isCurrentUser,
  }) {
    return LeaderboardUser(
      id: id ?? this.id,
      name: name ?? this.name,
      score: score ?? this.score,
      rank: rank ?? this.rank,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      score: json['score'] ?? 0,
      rank: json['rank'] ?? 0,
      isCurrentUser: json['is_current_user'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'score': score,
      'rank': rank,
      'is_current_user': isCurrentUser,
    };
  }
}
