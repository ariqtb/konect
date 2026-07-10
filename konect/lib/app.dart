import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/forum/forum_bloc.dart';
import 'presentation/blocs/voting/voting_bloc.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/forum/forum_page.dart';
import 'presentation/pages/voting/voting_page.dart';

class KonectApp extends StatelessWidget {
  const KonectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()..add(AuthCheckRequested())),
        BlocProvider(create: (_) => ForumBloc()),
        BlocProvider(create: (_) => VotingBloc()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: AppConstants.loginRoute,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppConstants.loginRoute:
              return MaterialPageRoute(builder: (_) => const LoginPage());
            case AppConstants.forumRoute:
              return MaterialPageRoute(builder: (_) => const ForumPage());
            case AppConstants.votingRoute:
              return MaterialPageRoute(builder: (_) => const VotingPage());
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
