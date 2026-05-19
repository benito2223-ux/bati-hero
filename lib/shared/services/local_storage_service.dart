import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around SharedPreferences for typed JSON read/write.
class LocalStorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _p {
    assert(_prefs != null, 'Call LocalStorageService.init() first');
    return _prefs!;
  }

  // ── Generic helpers ───────────────────────────────────────────────────────

  static Future<void> saveJsonList(String key, List<Map<String, dynamic>> list) async {
    await _p.setString(key, jsonEncode(list));
  }

  static List<Map<String, dynamic>> loadJsonList(String key) {
    final raw = _p.getString(key);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveJson(String key, Map<String, dynamic> map) async {
    await _p.setString(key, jsonEncode(map));
  }

  static Map<String, dynamic>? loadJson(String key) {
    final raw = _p.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveString(String key, String value) async {
    await _p.setString(key, value);
  }

  static String? loadString(String key) => _p.getString(key);

  static Future<void> saveDouble(String key, double value) async {
    await _p.setDouble(key, value);
  }

  static double? loadDouble(String key) => _p.getDouble(key);

  static Future<void> remove(String key) async {
    await _p.remove(key);
  }

  // ── Keys ──────────────────────────────────────────────────────────────────
  static const kProjects = 'bh_projects';
  static const kCurrentProjectId = 'bh_current_project_id';
  static const kShopItems = 'bh_shop_items';
  static const kExpenses = 'bh_expenses';
  static const kBudget = 'bh_budget';
}
