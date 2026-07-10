import 'package:flutter/material.dart';
import '../presentation/pages/article/article_detail_page.dart';
import '../presentation/pages/article/create_article_page.dart';
import '../presentation/pages/reedem/redeem_voucher_page.dart';
import '../presentation/pages/room/room_discussion_page.dart';
import '../core/constants.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.articleDetailRoute:
        return MaterialPageRoute(builder: (_) => const ArticleDetailPage());
      case AppConstants.createArticleRoute:
        return MaterialPageRoute(builder: (_) => const CreateArticlePage());
      case AppConstants.redeemRoute:
        return MaterialPageRoute(builder: (_) => const RedeemVoucherPage());
      case AppConstants.roomDiscussionRoute:
        return MaterialPageRoute(builder: (_) => const RoomDiscussionPage());
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
