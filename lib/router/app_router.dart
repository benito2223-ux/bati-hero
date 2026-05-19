import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import '../features/shop_zap/screens/shop_zap_screen.dart';
import '../features/money_crunch/screens/money_crunch_screen.dart';
import '../features/chrono_planning/screens/chrono_planning_screen.dart';
import '../features/hero_feed/screens/hero_feed_screen.dart';
import '../features/projects/screens/project_list_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (_, __) => const ProjectListScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (_, __, shell) => MainScaffold(navigationShell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/shop-zap', builder: (_, __) => const ShopZapScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/money-crunch', builder: (_, __) => const MoneyCrunchScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/chrono', builder: (_, __) => const ChronoPlanningScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/hero-feed', builder: (_, __) => const HeroFeedScreen()),
        ]),
      ],
    ),
  ],
);
