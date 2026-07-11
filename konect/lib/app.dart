import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'routes.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/voting/voting_bloc.dart';
import 'presentation/blocs/forum/forum_bloc.dart';
import 'presentation/blocs/cooperative/cooperative_bloc.dart';
import 'presentation/blocs/cooperative/cooperative_detail_bloc.dart';
import 'presentation/blocs/leaderboard/leaderboard_bloc.dart';
import 'presentation/blocs/discussion/discussion_room_bloc.dart';
import 'presentation/blocs/location/location_bloc.dart';
import 'data/services/location_service.dart';
import 'presentation/widgets/location_onboarding_sheet.dart';
import 'presentation/pages/splash_screen.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/forum/forum_page.dart';
import 'presentation/pages/voting/voting_page.dart';
import 'presentation/pages/main/main_page.dart';
import 'presentation/pages/cooperative/cooperative_page.dart';
import 'presentation/pages/leaderboard/leaderboard_page.dart';
import 'presentation/pages/cooperative_detail/cooperative_detail_page.dart';
import 'presentation/pages/voucher/voucher_page.dart';
import 'presentation/pages/profile/profile_page.dart';
import 'presentation/pages/room/room_discussion_page.dart';
import 'presentation/pages/room/create_room_page.dart';
import 'presentation/pages/reedem/redeem_history_page.dart';
import 'presentation/pages/reedem/redeem_voucher_page.dart';
import 'presentation/pages/article/article_detail_page.dart';
import 'presentation/pages/article/create_article_page.dart';

class KonectApp extends StatefulWidget {
  const KonectApp({super.key});

  @override
  State<KonectApp> createState() => _KonectAppState();
}

class _KonectAppState extends State<KonectApp> {
  // GlobalKey ke Navigator supaya BlocListener di root (yang konteksnya
  // di luar Navigator) tetap bisa show modal sheet. Tanpa ini, akan error
  // "Navigator operation requested with a context that does not include
  // a Navigator".
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _onboardingShownThisSession = false;

  @override
  Widget build(BuildContext context) {
    final app = MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()..add(AuthCheckRequested())),
        BlocProvider(create: (_) => ForumBloc()),
        BlocProvider(create: (_) => VotingBloc()),
        BlocProvider(create: (_) => CooperativeBloc()),
        BlocProvider(create: (_) => CooperativeDetailBloc()),
        BlocProvider(create: (_) => LeaderboardBloc()),
        BlocProvider(create: (_) => DiscussionRoomBloc()),
        BlocProvider(
          create: (_) => LocationBloc()..add(const LocationInitialized()),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        navigatorKey: _navigatorKey,
        // builder: BlocListener di sini berjalan di context YANG MEMILIKI
        // akses ke Navigator (via navigatorKey), bukan dari luar.
        builder: (context, child) {
          return BlocListener<LocationBloc, LocationState>(
            listenWhen: (prev, curr) =>
                prev.runtimeType != curr.runtimeType,
            listener: (context, state) async {
              // Hanya show onboarding sheet SEKALI per sesi (untuk hindari
              // loop kalau state bolak-balik).
              if (_onboardingShownThisSession) return;
              if (state is LocationPermissionDenied) {
                if (LocationOnboardingSheet.shouldShow(
                    permission: LocationPermissionStatus.denied,
                )) {
                  _onboardingShownThisSession = true;
                  // Tunggu initial route selesai render dulu.
                  await Future.delayed(const Duration(milliseconds: 800));
                  final navContext = _navigatorKey.currentContext;
                  if (navContext != null && navContext.mounted) {
                    await LocationOnboardingSheet.show(navContext);
                  }
                }
              }
            },
            child: child ?? const SizedBox.shrink(),
          );
        },
        initialRoute: AppConstants.splashRoute,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppConstants.splashRoute:
              return MaterialPageRoute(builder: (_) => const SplashScreen());
            case AppConstants.loginRoute:
              return MaterialPageRoute(builder: (_) => const MainPage());
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
            case AppConstants.articleDetailRoute:
              return MaterialPageRoute(builder: (_) => const ArticleDetailPage());
            case AppConstants.createArticleRoute:
              return MaterialPageRoute(builder: (_) => const CreateArticlePage());
            case AppConstants.voucherRoute:
              return MaterialPageRoute(builder: (_) => const VoucherPage());
            case AppConstants.profileRoute:
              return MaterialPageRoute(builder: (_) => const ProfilePage());
            case AppConstants.roomDiscussionRoute:
              return MaterialPageRoute(
                builder: (_) => const RoomDiscussionPage(),
                settings: settings,
              );
            case AppConstants.redeemRoute:
              return MaterialPageRoute(builder: (_) => const RedeemHistoryPage());
            case '/redeem-voucher':
              final voucherData = settings.arguments as Map<String, dynamic>? ?? {};
              return MaterialPageRoute(
                builder: (_) => RedeemVoucherPage(voucherData: voucherData),
              );
            case '/create-room':
              return MaterialPageRoute(builder: (_) => const CreateRoomPage());
            default:
              return MaterialPageRoute(
                builder: (_) => const MainPage(),
              );
          }
        },
      ),
    );
    return app;
  }
}
