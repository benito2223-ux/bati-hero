import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'shared/services/local_storage_service.dart';

Future<void> _initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Persistance locale
  await LocalStorageService.init();

  // Firebase — init avec gestion d'erreur
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Sur le web, l'auto-détection du canal long-polling de Firestore peut
    // rester bloquée en boucle (503 permanent) derrière certains proxys/réseaux.
    // On force le long-polling explicitement : c'est le fix officiel FlutterFire.
    if (kIsWeb) {
      FirebaseFirestore.instance.settings = const Settings(
        webExperimentalForceLongPolling: true,
        webExperimentalAutoDetectLongPolling: false,
      );
    }
  } catch (e) {
    debugPrint('Firebase init error: $e');
    // Continue même si Firebase échoue (fallback auth local)
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
}

void main() {
  runZonedGuarded(() async {
    await _initializeApp();
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint('FlutterError: ${details.exceptionAsString()}');
    };
    runApp(const ProviderScope(child: BatiHeroApp()));
  }, (error, stack) {
    debugPrint('Uncaught zone error: $error\n$stack');
  });
}
