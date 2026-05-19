import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shopping_item.dart';
import '../../../shared/services/local_storage_service.dart';
import '../../../shared/services/firestore_service.dart';
import '../../auth/providers/auth_provider.dart';

class ShopZapNotifier extends StateNotifier<List<ShoppingItem>> {
  final String? _uid;
  StreamSubscription<List<ShoppingItem>>? _sub;

  ShopZapNotifier(this._uid) : super(_loadLocal()) {
    if (_uid != null) _subscribeFirestore();
  }

  static List<ShoppingItem> _loadLocal() {
    final saved = LocalStorageService.loadJsonList(LocalStorageService.kShopItems);
    if (saved.isNotEmpty) {
      try { return saved.map(ShoppingItem.fromJson).toList(); } catch (_) {}
    }
    return [
      ShoppingItem(name: 'Ciment colle flex', store: BricoStore.leroyMerlin, quantity: '2 sacs'),
      ShoppingItem(name: 'Carrelage 60x60 grès cérame', store: BricoStore.leroyMerlin, quantity: '15 m²'),
      ShoppingItem(name: 'Peinture acrylique blanche mat', store: BricoStore.castorama, quantity: '5L'),
      ShoppingItem(name: 'Sous-couche universelle', store: BricoStore.castorama, quantity: '2.5L'),
      ShoppingItem(name: 'Chevilles Fischer 8mm x100', store: BricoStore.bricoDep, quantity: '1 boîte'),
      ShoppingItem(name: 'Vis inox 4x40mm', store: BricoStore.bricoDep, quantity: '200 pcs'),
    ];
  }

  void _saveLocal(List<ShoppingItem> items) {
    LocalStorageService.saveJsonList(
      LocalStorageService.kShopItems,
      items.map((i) => i.toJson()).toList(),
    );
  }

  Future<void> _subscribeFirestore() async {
    final hasData = await FirestoreService.hasAnyData(_uid!);
    if (!hasData) {
      await FirestoreService.migrateShopItems(_uid!, state);
    }
    _sub = FirestoreService.shopItemsStream(_uid!).listen((items) {
      state = items;
      _saveLocal(items);
    });
  }

  @override
  void dispose() { _sub?.cancel(); super.dispose(); }

  void addItem(ShoppingItem item) {
    if (_uid != null) {
      FirestoreService.setShopItem(_uid!, item);
    } else {
      state = [...state, item];
      _saveLocal(state);
    }
  }

  void removeItem(String id) {
    if (_uid != null) {
      FirestoreService.deleteShopItem(_uid!, id);
    } else {
      state = state.where((i) => i.id != id).toList();
      _saveLocal(state);
    }
  }

  void toggleItem(String id) {
    final updated = state.map((i) => i.id == id ? i.copyWith(checked: !i.checked) : i).toList();
    if (_uid != null) {
      final item = updated.firstWhere((i) => i.id == id);
      FirestoreService.setShopItem(_uid!, item);
    } else {
      state = updated;
      _saveLocal(state);
    }
  }

  void clearChecked() {
    final toDelete = state.where((i) => i.checked).toList();
    if (_uid != null) {
      for (final i in toDelete) FirestoreService.deleteShopItem(_uid!, i.id);
    } else {
      state = state.where((i) => !i.checked).toList();
      _saveLocal(state);
    }
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

final shopZapProvider = StateNotifierProvider<ShopZapNotifier, List<ShoppingItem>>((ref) {
  final user = ref.watch(currentUserProvider);
  return ShopZapNotifier(user?.uid);
});
