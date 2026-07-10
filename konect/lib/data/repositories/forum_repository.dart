import '../models/forum_topic.dart';

class ForumRepository {
  // In-memory store so createTopic() survives across screens in one session.
  final List<ForumTopic> _topics = [
    ForumTopic(
      id: '1',
      title: 'Musyawarah Anggaran Tahunan 2026',
      preview:
          'Bagaimana alokasi SHU tahun ini? Mohon pendapat anggota terkait prioritas program.',
      commentCount: 12,
      authorName: 'Pak Hartono',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    ForumTopic(
      id: '2',
      title: 'Usul penambahan unit usaha simpan pinjam',
      preview:
          'Banyak anggota yang membutuhkan akses pinjaman cepat dengan bunga ringan.',
      commentCount: 7,
      authorName: 'Bu Sulastri',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ForumTopic(
      id: '3',
      title: 'Transparansi laporan keuangan Q1',
      preview:
          'Berikut ringkasan keuangan triwulan I. Mohon review dan masukan dari anggota.',
      commentCount: 23,
      authorName: 'Admin Koperasi',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  Future<List<ForumTopic>> getTopics() async {
    // Placeholder network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_topics.reversed);
  }

  Future<ForumTopic> createTopic({
    required String title,
    required String content,
    required String authorName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final topic = ForumTopic(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      preview: content,
      commentCount: 0,
      authorName: authorName,
      createdAt: DateTime.now(),
    );
    _topics.add(topic);
    return topic;
  }
}

// Singleton instance — same shape as authRepository
final forumRepository = ForumRepository();
