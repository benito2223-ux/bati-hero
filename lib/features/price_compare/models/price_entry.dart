import 'package:uuid/uuid.dart';

class StorePrice {
  final String storeName;
  final double price;
  final DateTime updatedAt;

  const StorePrice({
    required this.storeName,
    required this.price,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'storeName': storeName,
        'price': price,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory StorePrice.fromJson(Map<String, dynamic> json) => StorePrice(
        storeName: json['storeName'] as String,
        price: (json['price'] as num).toDouble(),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

class PriceEntry {
  final String id;
  final String productName;
  final String? ean;
  final List<StorePrice> prices;
  final DateTime createdAt;

  PriceEntry({
    String? id,
    required this.productName,
    this.ean,
    List<StorePrice>? prices,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        prices = prices ?? [],
        createdAt = createdAt ?? DateTime.now();

  double? get bestPrice =>
      prices.isEmpty ? null : prices.map((p) => p.price).reduce((a, b) => a < b ? a : b);

  String? get bestStore => prices.isEmpty
      ? null
      : prices.reduce((a, b) => a.price < b.price ? a : b).storeName;

  double? get worstPrice =>
      prices.isEmpty ? null : prices.map((p) => p.price).reduce((a, b) => a > b ? a : b);

  double? get savings =>
      (bestPrice != null && worstPrice != null) ? worstPrice! - bestPrice! : null;

  PriceEntry copyWith({
    String? productName,
    String? ean,
    List<StorePrice>? prices,
  }) =>
      PriceEntry(
        id: id,
        productName: productName ?? this.productName,
        ean: ean ?? this.ean,
        prices: prices ?? this.prices,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'productName': productName,
        'ean': ean,
        'prices': prices.map((p) => p.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory PriceEntry.fromJson(Map<String, dynamic> json) => PriceEntry(
        id: json['id'] as String,
        productName: json['productName'] as String,
        ean: json['ean'] as String?,
        prices: (json['prices'] as List<dynamic>)
            .map((p) => StorePrice.fromJson(p as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

/// Magasins disponibles pour la comparaison
class ComparatorStore {
  final String name;
  final String emoji;
  final int color;
  final String searchUrl;

  const ComparatorStore({
    required this.name,
    required this.emoji,
    required this.color,
    required this.searchUrl,
  });
}

const comparatorStores = [
  ComparatorStore(
    name: 'Leroy Merlin',
    emoji: '🟢',
    color: 0xFF78BE20,
    searchUrl: 'https://www.leroymerlin.fr/recherche?q=',
  ),
  ComparatorStore(
    name: 'Castorama',
    emoji: '🔵',
    color: 0xFF0066CC,
    searchUrl: 'https://www.castorama.fr/search?term=',
  ),
  ComparatorStore(
    name: 'Brico Dépôt',
    emoji: '🔴',
    color: 0xFFE30613,
    searchUrl: 'https://www.bricodepot.fr/fr/recherche?q=',
  ),
  ComparatorStore(
    name: 'Mr Bricolage',
    emoji: '🟠',
    color: 0xFFFF6600,
    searchUrl: 'https://www.mr-bricolage.fr/catalogsearch/result/?q=',
  ),
  ComparatorStore(
    name: 'Amazon',
    emoji: '📦',
    color: 0xFFFF9900,
    searchUrl: 'https://www.amazon.fr/s?k=',
  ),
];
