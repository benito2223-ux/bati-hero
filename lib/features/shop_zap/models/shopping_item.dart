import 'package:uuid/uuid.dart';

enum BricoStore {
  libre('Liste libre', '📝'),
  leroyMerlin('Leroy Merlin', '🟢'),
  castorama('Castorama', '🔵'),
  bricoDep('Brico Dépôt', '🔴'),
  autres('Autres', '⚡');

  final String label;
  final String emoji;
  const BricoStore(this.label, this.emoji);
}

class ShoppingItem {
  final String id;
  final String name;
  final BricoStore store;
  final String quantity;
  final bool checked;

  ShoppingItem({
    String? id,
    required this.name,
    required this.store,
    this.quantity = '1',
    this.checked = false,
  }) : id = id ?? const Uuid().v4();

  ShoppingItem copyWith({
    String? name,
    BricoStore? store,
    String? quantity,
    bool? checked,
  }) {
    return ShoppingItem(
      id: id,
      name: name ?? this.name,
      store: store ?? this.store,
      quantity: quantity ?? this.quantity,
      checked: checked ?? this.checked,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'store': store.name,
        'quantity': quantity,
        'checked': checked,
      };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
        id: json['id'] as String,
        name: json['name'] as String,
        store: BricoStore.values.byName(json['store'] as String),
        quantity: json['quantity'] as String? ?? '1',
        checked: json['checked'] as bool? ?? false,
      );
}
