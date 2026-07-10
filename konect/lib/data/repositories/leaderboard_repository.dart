import '../models/leaderboard_user.dart';

class LeaderboardRepository {
  final List<LeaderboardUser> _rankings = [
    const LeaderboardUser(
      id: 'u1',
      name: 'Ibu Rahayu',
      score: 9850,
      rank: 1,
      isCurrentUser: false,
    ),
    const LeaderboardUser(
      id: 'u2',
      name: 'Ahmad Sulaiman',
      score: 8450,
      rank: 2,
      isCurrentUser: true,
    ),
    const LeaderboardUser(
      id: 'u3',
      name: 'Rian',
      score: 8230,
      rank: 3,
      isCurrentUser: false,
    ),
    const LeaderboardUser(
      id: 'u4',
      name: 'Bpk. Slamet',
      score: 8110,
      rank: 4,
      isCurrentUser: false,
    ),
  ];

  Future<List<LeaderboardUser>> getLeaderboard() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_rankings);
  }

  Future<bool> claimReward() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return true; // Simulate successful points claim/redemption
  }
}

final leaderboardRepository = LeaderboardRepository();
