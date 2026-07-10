import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'routes.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/voting/voting_bloc.dart';
import 'presentation/blocs/forum/forum_bloc.dart';

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
        initialRoute: AppConstants.mainShellRoute,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
