import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../../../shared/services/local_storage_service.dart';

class MoneyCrunchState {
  final List<Expense> expenses;
  final double budget;

  const MoneyCrunchState({required this.expenses, required this.budget});

  double get total => expenses.fold(0, (sum, e) => sum + e.amount);
  double get remaining => budget - total;
  double get percent => (total / budget).clamp(0, 1);
  bool get isOver => total > budget;

  MoneyCrunchState copyWith({List<Expense>? expenses, double? budget}) {
    return MoneyCrunchState(
      expenses: expenses ?? this.expenses,
      budget: budget ?? this.budget,
    );
  }
}

class MoneyCrunchNotifier extends StateNotifier<MoneyCrunchState> {
  MoneyCrunchNotifier() : super(_loadOrDemo());

  static MoneyCrunchState _loadOrDemo() {
    final savedExpenses =
        LocalStorageService.loadJsonList(LocalStorageService.kExpenses);
    final savedBudget =
        LocalStorageService.loadDouble(LocalStorageService.kBudget) ?? 5000.0;

    if (savedExpenses.isNotEmpty) {
      try {
        return MoneyCrunchState(
          expenses: savedExpenses.map(Expense.fromJson).toList(),
          budget: savedBudget,
        );
      } catch (_) {}
    }

    // First launch: demo data
    final demo = [
      Expense(amount: 234.50, description: 'Carrelage salon', category: ExpenseCategory.materiaux, date: DateTime.now().subtract(const Duration(days: 3))),
      Expense(amount: 89.99, description: 'Perceuse à percussion', category: ExpenseCategory.outillage, date: DateTime.now().subtract(const Duration(days: 5))),
      Expense(amount: 520.00, description: 'Plombier joint douche', category: ExpenseCategory.mainOeuvre, date: DateTime.now().subtract(const Duration(days: 7))),
      Expense(amount: 45.00, description: 'Livraison matériaux', category: ExpenseCategory.livraison, date: DateTime.now().subtract(const Duration(days: 2))),
    ];
    LocalStorageService.saveJsonList(
      LocalStorageService.kExpenses,
      demo.map((e) => e.toJson()).toList(),
    );
    LocalStorageService.saveDouble(LocalStorageService.kBudget, 5000.0);
    return MoneyCrunchState(expenses: demo, budget: 5000.0);
  }

  void _persist() {
    LocalStorageService.saveJsonList(
      LocalStorageService.kExpenses,
      state.expenses.map((e) => e.toJson()).toList(),
    );
    LocalStorageService.saveDouble(LocalStorageService.kBudget, state.budget);
  }

  void addExpense(Expense expense) {
    state = state.copyWith(expenses: [...state.expenses, expense]);
    _persist();
  }

  void removeExpense(String id) {
    state = state.copyWith(
        expenses: state.expenses.where((e) => e.id != id).toList());
    _persist();
  }

  void setBudget(double budget) {
    state = state.copyWith(budget: budget);
    _persist();
  }
}

final moneyCrunchProvider =
    StateNotifierProvider<MoneyCrunchNotifier, MoneyCrunchState>(
  (_) => MoneyCrunchNotifier(),
);
