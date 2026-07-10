class VotingItem {
  final String id;
  final String opinion;
  final int agreeCount;
  final int disagreeCount;
  final String? userReaction; // 'agree' | 'disagree' | null

  const VotingItem({
    required this.id,
    required this.opinion,
    required this.agreeCount,
    required this.disagreeCount,
    this.userReaction,
  });

  VotingItem copyWith({
    int? agreeCount,
    int? disagreeCount,
    String? userReaction,
    bool clearReaction = false,
  }) {
    return VotingItem(
      id: id,
      opinion: opinion,
      agreeCount: agreeCount ?? this.agreeCount,
      disagreeCount: disagreeCount ?? this.disagreeCount,
      userReaction: clearReaction ? null : (userReaction ?? this.userReaction),
    );
  }

  factory VotingItem.fromJson(Map<String, dynamic> json) {
    return VotingItem(
      id: json['id'] ?? '',
      opinion: json['opinion'] ?? '',
      agreeCount: json['agree_count'] ?? 0,
      disagreeCount: json['disagree_count'] ?? 0,
      userReaction: json['user_reaction'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'opinion': opinion,
      'agree_count': agreeCount,
      'disagree_count': disagreeCount,
      'user_reaction': userReaction,
    };
  }
}
