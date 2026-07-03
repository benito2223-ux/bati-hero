import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/shop_zap/screens/shop_zap_screen.dart';
import '../features/money_crunch/screens/money_crunch_screen.dart';
import '../features/chrono_planning/screens/chrono_planning_screen.dart';
import '../features/hero_feed/screens/hero_feed_screen.dart';
import '../features/projects/screens/project_list_screen.dart';
import '../features/price_compare/screens/price_compare_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      // Pendant le chargement auth, rester sur splash
      if (authState.isLoading) return '/splash';

      // Firebase error = fallback au local (pas d'auth, va direct à accueil)
      if (authState.hasError) return '/';

      final isLoggedIn = authState.valueOrNull != null;
      final path = state.uri.path;

      // Pas connecté → login (sauf splash)
      if (!isLoggedIn && path != '/splash' && path != '/login') return '/login';

      // Connecté sur login → accueil
      if (isLoggedIn && path == '/login') return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
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
          StatefulShellBranch(routes: [
            GoRoute(path: '/price-hunter', builder: (_, __) => const PriceCompareScreen()),
          ]),
        ],
      ),
    ],
  );
});
