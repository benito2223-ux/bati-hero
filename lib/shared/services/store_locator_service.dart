import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class BricoStore {
  final String name;
  final Color color;
  final String emoji;

  const BricoStore({required this.name, required this.color, required this.emoji});
}

class StoreLocatorService {
  static const stores = [
    BricoStore(name: 'Leroy Merlin', color: Color(0xFF78BE20), emoji: '🟢'),
    BricoStore(name: 'Castorama', color: Color(0xFF0066CC), emoji: '🔵'),
    BricoStore(name: 'Brico Dépôt', color: Color(0xFFE30613), emoji: '🔴'),
    BricoStore(name: 'Mr Bricolage', color: Color(0xFFFF6600), emoji: '🟠'),
    BricoStore(name: 'Bricomarché', color: Color(0xFF009900), emoji: '🟩'),
  ];

  static Future<Position?> getCurrentPosition() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final req = await Geolocator.requestPermission();
        if (req == LocationPermission.denied ||
            req == LocationPermission.deniedForever) return null;
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> openMaps(String storeName, Position? pos) async {
    final Uri url;
    if (pos != null) {
      url = Uri.parse(
        'https://www.google.com/maps/search/${Uri.encodeComponent(storeName)}/@${pos.latitude},${pos.longitude},13z',
      );
    } else {
      url = Uri.parse(
        'https://www.google.com/maps/search/${Uri.encodeComponent(storeName)}',
      );
    }
    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
