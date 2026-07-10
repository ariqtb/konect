import '../models/voting_item.dart';

class VotingRepository {
  // In-memory store so castVote() persists across rebuilds in one session.
  final List<VotingItem> _items = [
    const VotingItem(
      id: 'v1',
      opinion:
          'SHU tahun ini sebaiknya dialokasikan 60% untuk cadangan dan 40% untuk jasa modal anggota.',
      agreeCount: 18,
      disagreeCount: 4,
    ),
    const VotingItem(
      id: 'v2',
      opinion:
          'Koperasi perlu membuka unit usaha baru: toko sarana produksi pertanian.',
      agreeCount: 27,
      disagreeCount: 2,
    ),
    const VotingItem(
      id: 'v3',
      opinion:
          'Jasa pinjaman sebaiknya diturunkan dari 1.5% ke 1.2% per bulan untuk anggota.',
      agreeCount: 9,
      disagreeCount: 11,
    ),
  ];

  Future<List<VotingItem>> getPolls() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_items);
  }

  Future<VotingItem> castVote({
    required String id,
    required String reaction, // 'agree' | 'disagree'
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _items.indexWhere((it) => it.id == id);
    if (idx == -1) {
      throw StateError('VotingItem $id not found');
    }
    final current = _items[idx];

    // Revert previous reaction, then apply new one. Toggling the same
    // reaction removes it.
    int agree = current.agreeCount;
    int disagree = current.disagreeCount;
    String? nextReaction = reaction;

    if (current.userReaction == 'agree') agree = (agree - 1).clamp(0, 1 << 30);
    if (current.userReaction == 'disagree') {
      disagree = (disagree - 1).clamp(0, 1 << 30);
    }
    if (current.userReaction == reaction) {
      // Toggling off
      nextReaction = null;
    } else {
      if (reaction == 'agree') agree += 1;
      if (reaction == 'disagree') disagree += 1;
    }

    final updated = current.copyWith(
      agreeCount: agree,
      disagreeCount: disagree,
      userReaction: nextReaction,
      clearReaction: nextReaction == null,
    );
    _items[idx] = updated;
    return updated;
  }
}

final votingRepository = VotingRepository();
