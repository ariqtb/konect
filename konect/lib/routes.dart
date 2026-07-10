import 'package:flutter/material.dart';
import '../presentation/pages/article/article_detail_page.dart';
import '../presentation/pages/article/create_article_page.dart';
import '../presentation/pages/reedem/redeem_voucher_page.dart';
import '../presentation/pages/room/room_discussion_page.dart';
import '../presentation/pages/main_shell_page.dart';
import '../presentation/pages/leaderboard/leaderboard_page.dart';
import '../presentation/pages/koperasi/detail_koperasi_page.dart';
import '../presentation/pages/room/create_room_page.dart';
import '../core/constants.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.mainShellRoute:
        return MaterialPageRoute(builder: (_) => const MainShellPage());
      case AppConstants.articleDetailRoute:
        return MaterialPageRoute(builder: (_) => const ArticleDetailPage());
      case AppConstants.createArticleRoute:
        return MaterialPageRoute(builder: (_) => const CreateArticlePage());
      case AppConstants.redeemRoute:
        return MaterialPageRoute(builder: (_) => const RedeemVoucherPage());
      case AppConstants.roomDiscussionRoute:
        return MaterialPageRoute(
          builder: (_) => const RoomDiscussionPage(),
          settings: settings,
        );
      case '/leaderboard':
        return MaterialPageRoute(builder: (_) => const LeaderboardPage());
      case '/detail-koperasi':
        return MaterialPageRoute(builder: (_) => const DetailKoperasiPage());
      case '/create-room':
        return MaterialPageRoute(builder: (_) => const CreateRoomPage());
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
