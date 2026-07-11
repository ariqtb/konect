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

      // Fetch from RPC get_leaderboard (from 006_frontend_views.sql)
      final response = await _supabase.rpc(
        'get_leaderboard',
        params: {'p_user_id': currentUserId},
      );
          
      final List<LeaderboardUser> rankings = (response as List).map((data) {
        return LeaderboardUser(
          id: data['id'] ?? '',
          name: data['name'] ?? data['username'] ?? 'Warga',
          score: data['score'] ?? 0,
          rank: (data['rank'] ?? 0).toInt(),
          isCurrentUser: data['is_current_user'] ?? false,
        );
      }).toList();

      return rankings;
    } catch (e) {
      // Fallback: query users table directly if RPC fails
      try {
        final currentUser = await authRepository.getCurrentUser();
        final currentUserId = currentUser?.id;
        
        final rows = await _supabase
            .from('users')
            .select('id, full_name, username, points_balance')
            .eq('is_active', true)
            .order('points_balance', ascending: false)
            .limit(20);
        
        int rank = 0;
        return (rows as List).map((data) {
          rank++;
          return LeaderboardUser(
            id: data['id'] ?? '',
            name: data['full_name'] ?? data['username'] ?? 'Warga',
            score: data['points_balance'] ?? 0,
            rank: rank,
            isCurrentUser: data['id'] == currentUserId,
          );
        }).toList();
      } catch (_) {
        // Ultimate fallback if even direct query fails
        return [];
      }
    }
  }

  Future<bool> claimReward() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return true; // Simulate successful points claim/redemption
  }
}

final leaderboardRepository = LeaderboardRepository();
