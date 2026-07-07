import 'dart:async';
import 'package:flutter/foundation.dart';
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

/// Transforme un Stream en Listenable pour piloter go_router.refresh()
/// sans jamais recréer l'objet GoRouter lui-même (ce qui détruirait
/// l'arbre de navigation en cours, ex: le splash screen en pleine animation).
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// GoRouter créé UNE SEULE FOIS pour toute la durée de vie de l'app.
/// L'état d'auth est lu via `ref.read` (jamais `.watch`) dans `redirect`
/// pour ne pas recréer ce Provider — seul `refreshListenable` déclenche
/// une réévaluation de `redirect` quand l'auth change.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authChangesStream()),
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);

      // Pendant le chargement auth, rester sur splash
      if (authState.isLoading) return null;

      final isLoggedIn = authState.valueOrNull != null;
      final path = state.uri.path;

      // Pas connecté → login (sauf splash)
      if (!isLoggedIn && path != '/splash' && path != '/login') return '/login';

      // Connecté sur login ou splash → accueil
      if (isLoggedIn && (path == '/login' || path == '/splash')) return '/';

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
