class AppConstants {
  // App Info
  static const String appName = 'KONECT';
  static const String appTagline = 'Koperasi Connect';

  // Routes
  static const String mainShellRoute = '/';
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String koperasiRoute = '/koperasi';
  static const String cooperativeRoute = '/cooperative';
  static const String leaderboardRoute = '/leaderboard';
  static const String cooperativeDetailRoute = '/cooperative-detail';
  static const String voucherRoute = '/voucher';
  static const String profileRoute = '/profile';
  static const String forumRoute = '/forum';
  static const String votingRoute = '/voting';
  static const String articleDetailRoute = '/article-detail';
  static const String createArticleRoute = '/create-article';
  static const String redeemRoute = '/redeem';
  static const String roomDiscussionRoute = '/room-discussion';
  static const String createRoomRoute = '/create-room';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // API (placeholder)
  static const String baseUrl = 'https://api.konect.id';
  static const Duration apiTimeout = Duration(seconds: 30);
}
