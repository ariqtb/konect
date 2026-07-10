import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'routes.dart';

class KonectApp extends StatelessWidget {
  const KonectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()..add(AuthCheckRequested())),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: AppConstants.loginRoute,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
