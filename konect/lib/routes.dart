import 'package:flutter/material.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/forum/forum_page.dart';
import '../presentation/pages/voting/voting_page.dart';
import '../presentation/pages/main/main_page.dart';
import '../presentation/pages/cooperative/cooperative_page.dart';
import '../presentation/pages/leaderboard/leaderboard_page.dart';
import '../presentation/pages/cooperative_detail/cooperative_detail_page.dart';
import '../core/constants.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AppConstants.homeRoute:
        return MaterialPageRoute(builder: (_) => const MainPage());
      case AppConstants.forumRoute:
        return MaterialPageRoute(builder: (_) => const ForumPage());
      case AppConstants.votingRoute:
        return MaterialPageRoute(builder: (_) => const VotingPage());
      case AppConstants.cooperativeRoute:
        return MaterialPageRoute(builder: (_) => const CooperativePage());
      case AppConstants.leaderboardRoute:
        return MaterialPageRoute(builder: (_) => const LeaderboardPage());
      case AppConstants.cooperativeDetailRoute:
        final coopId = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => CooperativeDetailPage(coopId: coopId),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

// Simple Navigator helper
class AppNavigator {
  static void push(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  static void pushReplacement(BuildContext context, String route) {
    Navigator.pushReplacementNamed(context, route);
  }

  static void pop(BuildContext context) {
    Navigator.pop(context);
  }
}
