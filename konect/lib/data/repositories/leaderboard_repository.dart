import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../models/leaderboard_user.dart';
import 'auth_repository.dart';

class LeaderboardRepository {
  final _supabase = sp.Supabase.instance.client;

  Future<List<LeaderboardUser>> getLeaderboard() async {
    try {
      // Get current user to determine 'isCurrentUser' flag
      final currentUser = await authRepository.getCurrentUser();
      final currentUserId = currentUser?.id;

      // Fetch top 50 users from leaderboard view
      final response = await _supabase
          .from('leaderboard')
          .select()
          .limit(50);
          
      final List<LeaderboardUser> rankings = (response as List).map((data) {
        return LeaderboardUser(
          id: data['id'] ?? '',
          name: data['full_name'] ?? data['username'] ?? 'Warga',
          score: data['points_balance'] ?? 0,
          rank: (data['rank'] ?? 0).toInt(),
          isCurrentUser: data['id'] == currentUserId,
        );
      }).toList();

      return rankings;
    } catch (e) {
      // Fallback ke mock data jika view leaderboard belum ada di database
      return [
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
      ];
    }
  }

  Future<bool> claimReward() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return true; // Simulate successful points claim/redemption
  }
}

final leaderboardRepository = LeaderboardRepository();
