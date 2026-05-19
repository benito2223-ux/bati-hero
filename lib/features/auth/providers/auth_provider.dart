import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Stream de l'état d'authentification Firebase.
final authStateProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

/// Utilisateur courant (nullable).
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

/// Service de connexion/déconnexion.
class AuthService {
  static Future<User?> signInWithGoogle() async {
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
