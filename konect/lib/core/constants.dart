class AppConstants {
  // App Info
  static const String appName = 'KONECT';
  static const String appTagline = 'Koperasi Connect';

  // Routes
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String forumRoute = '/forum';
  static const String votingRoute = '/voting';
  static const String profileRoute = '/profile';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // API (placeholder)
  static const String baseUrl = 'https://api.konect.id';
  static const Duration apiTimeout = Duration(seconds: 30);
}
