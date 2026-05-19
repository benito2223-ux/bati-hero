import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/projects/models/project.dart';
import '../../features/shop_zap/models/shopping_item.dart';
import '../../features/money_crunch/models/expense.dart';
import '../../features/price_compare/models/price_entry.dart';

/// Centralise toutes les opérations Firestore.
/// Structure : /users/{uid}/{collection}/{docId}
class FirestoreService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> _col(String uid, String name) =>
      _db.collection('users').doc(uid).collection(name);

  static DocumentReference<Map<String, dynamic>> _settings(String uid) =>
      _db.collection('users').doc(uid).collection('meta').doc('settings');

  // ── Projects ───────────────────────────────────────────────────────────────

  static Stream<List<Project>> projectsStream(String uid) =>
      _col(uid, 'projects')
          .orderBy('createdAt')
          .snapshots()
          .map((s) => s.docs.map((d) => Project.fromJson(d.data())).toList());

  static Future<void> setProject(String uid, Project p) =>
      _col(uid, 'projects').doc(p.id).set(p.toJson());

  static Future<void> deleteProject(String uid, String id) =>
      _col(uid, 'projects').doc(id).delete();

  static Future<void> migrateProjects(String uid, List<Project> projects) async {
    final batch = _db.batch();
    for (final p in projects) {
      batch.set(_col(uid, 'projects').doc(p.id), p.toJson());
    }
    await batch.commit();
  }

  // ── Shop Items ─────────────────────────────────────────────────────────────

  static Stream<List<ShoppingItem>> shopItemsStream(String uid) =>
      _col(uid, 'shopItems')
          .snapshots()
          .map((s) => s.docs.map((d) => ShoppingItem.fromJson(d.data())).toList());

  static Future<void> setShopItem(String uid, ShoppingItem item) =>
      _col(uid, 'shopItems').doc(item.id).set(item.toJson());

  static Future<void> deleteShopItem(String uid, String id) =>
      _col(uid, 'shopItems').doc(id).delete();

  static Future<void> migrateShopItems(String uid, List<ShoppingItem> items) async {
    final batch = _db.batch();
    for (final i in items) {
      batch.set(_col(uid, 'shopItems').doc(i.id), i.toJson());
    }
    await batch.commit();
  }

  // ── Expenses ───────────────────────────────────────────────────────────────

  static Stream<List<Expense>> expensesStream(String uid) =>
      _col(uid, 'expenses')
          .orderBy('date', descending: true)
          .snapshots()
          .map((s) => s.docs.map((d) => Expense.fromJson(d.data())).toList());

  static Future<void> setExpense(String uid, Expense e) =>
      _col(uid, 'expenses').doc(e.id).set(e.toJson());

  static Future<void> deleteExpense(String uid, String id) =>
      _col(uid, 'expenses').doc(id).delete();

  static Future<void> migrateExpenses(String uid, List<Expense> expenses) async {
    final batch = _db.batch();
    for (final e in expenses) {
      batch.set(_col(uid, 'expenses').doc(e.id), e.toJson());
    }
    await batch.commit();
  }

  // ── Budget ─────────────────────────────────────────────────────────────────

  static Stream<double> budgetStream(String uid) =>
      _settings(uid).snapshots().map((s) =>
          s.exists ? ((s.data()?['budget'] as num?)?.toDouble() ?? 5000.0) : 5000.0);

  static Future<void> setBudget(String uid, double budget) =>
      _settings(uid).set({'budget': budget}, SetOptions(merge: true));

  // ── Price Entries ──────────────────────────────────────────────────────────

  static Stream<List<PriceEntry>> priceEntriesStream(String uid) =>
      _col(uid, 'priceEntries')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((s) => s.docs.map((d) => PriceEntry.fromJson(d.data())).toList());

  static Future<void> setPriceEntry(String uid, PriceEntry e) =>
      _col(uid, 'priceEntries').doc(e.id).set(e.toJson());

  static Future<void> deletePriceEntry(String uid, String id) =>
      _col(uid, 'priceEntries').doc(id).delete();

  // ── Migration locale → Firestore au premier login ──────────────────────────

  static Future<bool> hasAnyData(String uid) async {
    final snap = await _col(uid, 'projects').limit(1).get();
    return snap.docs.isNotEmpty;
  }
}
