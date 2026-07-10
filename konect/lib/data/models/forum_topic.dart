class ForumTopic {
  final String id;
  final String title;
  final String preview;
  final int commentCount;
  final String authorName;
  final DateTime createdAt;

  ForumTopic({
    required this.id,
    required this.title,
    required this.preview,
    required this.commentCount,
    required this.authorName,
    required this.createdAt,
  });

  factory ForumTopic.fromJson(Map<String, dynamic> json) {
    return ForumTopic(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      preview: json['preview'] ?? '',
      commentCount: json['comment_count'] ?? 0,
      authorName: json['author_name'] ?? 'Anonim',
      createdAt:
          DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'preview': preview,
      'comment_count': commentCount,
      'author_name': authorName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
