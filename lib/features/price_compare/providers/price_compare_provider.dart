import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/price_entry.dart';
import '../../../shared/services/local_storage_service.dart';

class PriceCompareNotifier extends StateNotifier<List<PriceEntry>> {
  PriceCompareNotifier() : super(_load());

  static List<PriceEntry> _load() {
    final saved = LocalStorageService.loadJsonList(LocalStorageService.kPriceEntries);
    if (saved.isNotEmpty) {
      try {
        return saved.map(PriceEntry.fromJson).toList();
      } catch (_) {}
    }
    return [];
  }

  void _persist() {
    LocalStorageService.saveJsonList(
      LocalStorageService.kPriceEntries,
      state.map((e) => e.toJson()).toList(),
    );
  }

  void addEntry(PriceEntry entry) {
    state = [entry, ...state];
    _persist();
  }

  void updateEntry(PriceEntry updated) {
    state = state.map((e) => e.id == updated.id ? updated : e).toList();
    _persist();
  }

  void removeEntry(String id) {
    state = state.where((e) => e.id != id).toList();
    _persist();
  }

  /// Ajoute ou met à jour le prix d'un magasin pour un produit donné
  void setStorePrice(String entryId, String storeName, double price) {
    state = state.map((e) {
      if (e.id != entryId) return e;
      final prices = e.prices.where((p) => p.storeName != storeName).toList();
      prices.add(StorePrice(
        storeName: storeName,
        price: price,
        updatedAt: DateTime.now(),
      ));
      return e.copyWith(prices: prices);
    }).toList();
    _persist();
  }
}

final priceCompareProvider =
    StateNotifierProvider<PriceCompareNotifier, List<PriceEntry>>(
  (_) => PriceCompareNotifier(),
);
