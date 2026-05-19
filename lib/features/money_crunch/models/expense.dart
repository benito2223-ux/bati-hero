import 'package:uuid/uuid.dart';

enum ExpenseCategory {
  materiaux('Matériaux', '🧱'),
  outillage('Outillage', '🔧'),
  mainOeuvre('Main d\'œuvre', '👷'),
  livraison('Livraison', '🚚'),
  divers('Divers', '📦');

  final String label;
  final String emoji;
  const ExpenseCategory(this.label, this.emoji);
}

class Expense {
  final String id;
  final double amount;
  final String description;
  final DateTime date;
  final ExpenseCategory category;
  final String? receiptImagePath;

  Expense({
    String? id,
    required this.amount,
    required this.description,
    DateTime? date,
    required this.category,
    this.receiptImagePath,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();

  Expense copyWith({
    double? amount,
    String? description,
    DateTime? date,
    ExpenseCategory? category,
    String? receiptImagePath,
  }) {
    return Expense(
      id: id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      category: category ?? this.category,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'description': description,
        'date': date.toIso8601String(),
        'category': category.name,
        'receiptImagePath': receiptImagePath,
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        description: json['description'] as String,
        date: DateTime.parse(json['date'] as String),
        category: ExpenseCategory.values.byName(json['category'] as String),
        receiptImagePath: json['receiptImagePath'] as String?,
      );
}
