import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/price_entry.dart';
import '../../../shared/services/local_storage_service.dart';
import '../../../shared/services/firestore_service.dart';
import '../../auth/providers/auth_provider.dart';

class PriceCompareNotifier extends StateNotifier<List<PriceEntry>> {
  final String? _uid;
  StreamSubscription<List<PriceEntry>>? _sub;

  PriceCompareNotifier(this._uid) : super(_loadLocal()) {
    if (_uid != null) _subscribeFirestore();
  }

  static List<PriceEntry> _loadLocal() {
    final saved = LocalStorageService.loadJsonList(LocalStorageService.kPriceEntries);
    if (saved.isNotEmpty) {
      try { return saved.map(PriceEntry.fromJson).toList(); } catch (_) {}
    }
    return [];
  }

  void _saveLocal(List<PriceEntry> entries) {
    LocalStorageService.saveJsonList(
      LocalStorageService.kPriceEntries,
      entries.map((e) => e.toJson()).toList(),
    );
  }

  Future<void> _subscribeFirestore() async {
    _sub = FirestoreService.priceEntriesStream(_uid!).listen((entries) {
      state = entries;
      _saveLocal(entries);
    });
  }

  @override
  void dispose() { _sub?.cancel(); super.dispose(); }

  void addEntry(PriceEntry entry) {
    if (_uid != null) {
      FirestoreService.setPriceEntry(_uid!, entry);
    } else {
      state = [entry, ...state];
      _saveLocal(state);
    }
  }

  void updateEntry(PriceEntry updated) {
    if (_uid != null) {
      FirestoreService.setPriceEntry(_uid!, updated);
    } else {
      state = state.map((e) => e.id == updated.id ? updated : e).toList();
      _saveLocal(state);
    }
  }

  void removeEntry(String id) {
    if (_uid != null) {
      FirestoreService.deletePriceEntry(_uid!, id);
    } else {
      state = state.where((e) => e.id != id).toList();
      _saveLocal(state);
    }
  }

  void setStorePrice(String entryId, String storeName, double price) {
    final updated = state.map((e) {
      if (e.id != entryId) return e;
      final prices = e.prices.where((p) => p.storeName != storeName).toList()
        ..add(StorePrice(storeName: storeName, price: price, updatedAt: DateTime.now()));
      return e.copyWith(prices: prices);
    }).toList();

    if (_uid != null) {
      final entry = updated.firstWhere((e) => e.id == entryId);
      FirestoreService.setPriceEntry(_uid!, entry);
    } else {
      state = updated;
      _saveLocal(state);
    }
  }
}

final priceCompareProvider = StateNotifierProvider<PriceCompareNotifier, List<PriceEntry>>((ref) {
  final user = ref.watch(currentUserProvider);
  return PriceCompareNotifier(user?.uid);
});
