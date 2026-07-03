import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
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
  } catch (e) {
    debugPrint('Firebase init error: $e');
    // Continue même si Firebase échoue (fallback auth local)
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
}

void main() async {
  await _initializeApp();
  runApp(const ProviderScope(child: BatiHeroApp()));
}
