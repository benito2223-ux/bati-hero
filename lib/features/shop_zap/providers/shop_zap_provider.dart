import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shopping_item.dart';
import '../../../shared/services/local_storage_service.dart';

class ShopZapNotifier extends StateNotifier<List<ShoppingItem>> {
  ShopZapNotifier() : super(_loadOrDemo());

  static List<ShoppingItem> _loadOrDemo() {
    final saved = LocalStorageService.loadJsonList(LocalStorageService.kShopItems);
    if (saved.isNotEmpty) {
      try {
        return saved.map(ShoppingItem.fromJson).toList();
      } catch (_) {}
    }
    // First launch: demo items
    final demo = [
      ShoppingItem(name: 'Ciment colle flex', store: BricoStore.leroyMerlin, quantity: '2 sacs'),
      ShoppingItem(name: 'Carrelage 60x60 grès cérame', store: BricoStore.leroyMerlin, quantity: '15 m²'),
      ShoppingItem(name: 'Peinture acrylique blanche mat', store: BricoStore.castorama, quantity: '5L'),
      ShoppingItem(name: 'Sous-couche universelle', store: BricoStore.castorama, quantity: '2.5L'),
      ShoppingItem(name: 'Chevilles Fischer 8mm x100', store: BricoStore.bricoDep, quantity: '1 boîte'),
      ShoppingItem(name: 'Vis inox 4x40mm', store: BricoStore.bricoDep, quantity: '200 pcs'),
    ];
    LocalStorageService.saveJsonList(
      LocalStorageService.kShopItems,
      demo.map((i) => i.toJson()).toList(),
    );
    return demo;
  }

  void _persist() {
    LocalStorageService.saveJsonList(
      LocalStorageService.kShopItems,
      state.map((i) => i.toJson()).toList(),
    );
  }

  void addItem(ShoppingItem item) {
    state = [...state, item];
    _persist();
  }

  void removeItem(String id) {
    state = state.where((i) => i.id != id).toList();
    _persist();
  }

  void toggleItem(String id) {
    state = state.map((i) => i.id == id ? i.copyWith(checked: !i.checked) : i).toList();
    _persist();
  }

  void clearChecked() {
    state = state.where((i) => !i.checked).toList();
    _persist();
  }

  Map<BricoStore, List<ShoppingItem>> get byStore {
    final map = <BricoStore, List<ShoppingItem>>{};
    for (final store in BricoStore.values) {
      final items = state.where((i) => i.store == store).toList();
      if (items.isNotEmpty) map[store] = items;
    }
    return map;
  }

  int get total => state.length;
  int get checked => state.where((i) => i.checked).length;
}

final shopZapProvider =
    StateNotifierProvider<ShopZapNotifier, List<ShoppingItem>>(
  (_) => ShopZapNotifier(),
);
