import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'routes.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/voting/voting_bloc.dart';
import 'presentation/blocs/cooperative/cooperative_bloc.dart';
import 'presentation/blocs/cooperative/cooperative_detail_bloc.dart';
import 'presentation/blocs/leaderboard/leaderboard_bloc.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/forum/forum_page.dart';
import 'presentation/pages/voting/voting_page.dart';
import 'presentation/pages/main/main_page.dart';
import 'presentation/pages/cooperative/cooperative_page.dart';
import 'presentation/pages/leaderboard/leaderboard_page.dart';
import 'presentation/pages/cooperative_detail/cooperative_detail_page.dart';

class KonectApp extends StatelessWidget {
  const KonectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()..add(AuthCheckRequested())),
        BlocProvider(create: (_) => ForumBloc()),
        BlocProvider(create: (_) => VotingBloc()),
        BlocProvider(create: (_) => CooperativeBloc()),
        BlocProvider(create: (_) => CooperativeDetailBloc()),
        BlocProvider(create: (_) => LeaderboardBloc()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: AppConstants.homeRoute,
        onGenerateRoute: (settings) {
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
                builder: (_) => const LoginPage(),
              );
          }
        },
      ),
    );
  }
}
