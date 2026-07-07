import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Stream brut de l'état d'authentification Firebase.
/// Si Firebase n'a pas pu s'initialiser (échec réseau, config web, etc.),
/// on émet `null` (non connecté) au lieu de faire planter l'app.
/// Exposé en dehors de Riverpod pour servir de `refreshListenable` stable au router
/// (voir GoRouterRefreshStream dans app_router.dart).
Stream<User?> authChangesStream() {
  if (Firebase.apps.isEmpty) return Stream.value(null);
  try {
    return FirebaseAuth.instance.authStateChanges();
  } catch (_) {
    return Stream.value(null);
  }
}

final authStateProvider = StreamProvider<User?>((ref) => authChangesStream());

/// Utilisateur courant (nullable).
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

/// Service de connexion/déconnexion.
class AuthService {
  static Future<User?> signInWithGoogle() async {
    if (Firebase.apps.isEmpty) {
      throw Exception('Firebase indisponible — réessaie plus tard');
    }
    try {
      if (kIsWeb) {
        // Web : popup Firebase natif
        final provider = GoogleAuthProvider();
        provider.setCustomParameters({'prompt': 'select_account'});
        final result = await FirebaseAuth.instance.signInWithPopup(provider);
        return result.user;
      } else {
        // Mobile : google_sign_in → Firebase credential
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return null;
        final auth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: auth.accessToken,
          idToken: auth.idToken,
        );
        final result = await FirebaseAuth.instance.signInWithCredential(credential);
        return result.user;
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> signOut() async {
    if (!kIsWeb) await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }
}
