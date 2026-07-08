import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../../../shared/services/local_storage_service.dart';
import '../../../shared/services/firestore_service.dart';
import '../../auth/providers/auth_provider.dart';

class MoneyCrunchState {
  final List<Expense> expenses;
  final double budget;

  const MoneyCrunchState({required this.expenses, required this.budget});

  double get total => expenses.fold(0, (s, e) => s + e.amount);
  double get remaining => budget - total;
  double get percent => (total / budget).clamp(0, 1);
  bool get isOver => total > budget;

  MoneyCrunchState copyWith({List<Expense>? expenses, double? budget}) =>
      MoneyCrunchState(
        expenses: expenses ?? this.expenses,
        budget: budget ?? this.budget,
      );
}

class MoneyCrunchNotifier extends StateNotifier<MoneyCrunchState> {
  final String? _uid;
  StreamSubscription<List<Expense>>? _expSub;
  StreamSubscription<double>? _budgetSub;

  MoneyCrunchNotifier(this._uid) : super(_loadLocal()) {
    if (_uid != null) _subscribeFirestore();
  }

  static MoneyCrunchState _loadLocal() {
    final savedExpenses = LocalStorageService.loadJsonList(LocalStorageService.kExpenses);
    final savedBudget = LocalStorageService.loadDouble(LocalStorageService.kBudget) ?? 5000.0;
    if (savedExpenses.isNotEmpty) {
      try {
        return MoneyCrunchState(
          expenses: savedExpenses.map(Expense.fromJson).toList(),
          budget: savedBudget,
        );
      } catch (_) {}
    }
    final demo = [
      Expense(amount: 234.50, description: 'Carrelage salon', category: ExpenseCategory.materiaux, date: DateTime.now().subtract(const Duration(days: 3))),
      Expense(amount: 89.99, description: 'Perceuse à percussion', category: ExpenseCategory.outillage, date: DateTime.now().subtract(const Duration(days: 5))),
      Expense(amount: 520.00, description: 'Plombier joint douche', category: ExpenseCategory.mainOeuvre, date: DateTime.now().subtract(const Duration(days: 7))),
      Expense(amount: 45.00, description: 'Livraison matériaux', category: ExpenseCategory.livraison, date: DateTime.now().subtract(const Duration(days: 2))),
    ];
    return MoneyCrunchState(expenses: demo, budget: savedBudget);
  }

  Future<void> _subscribeFirestore() async {
    final hasData = await FirestoreService.hasAnyData(_uid!);
    if (!hasData) {
      await FirestoreService.migrateExpenses(_uid!, state.expenses);
      await FirestoreService.setBudget(_uid!, state.budget);
    }
    _expSub = FirestoreService.expensesStream(_uid!).listen((expenses) {
      state = state.copyWith(expenses: expenses);
      LocalStorageService.saveJsonList(
        LocalStorageService.kExpenses,
        expenses.map((e) => e.toJson()).toList(),
      );
    });
    _budgetSub = FirestoreService.budgetStream(_uid!).listen((budget) {
      state = state.copyWith(budget: budget);
      LocalStorageService.saveDouble(LocalStorageService.kBudget, budget);
    });
  }

  @override
  void dispose() { _expSub?.cancel(); _budgetSub?.cancel(); super.dispose(); }

  void addExpense(Expense expense) {
    state = state.copyWith(expenses: [...state.expenses, expense]);
    _persistLocal();
    if (_uid != null) FirestoreService.setExpense(_uid!, expense);
  }

  void removeExpense(String id) {
    state = state.copyWith(expenses: state.expenses.where((e) => e.id != id).toList());
    _persistLocal();
    if (_uid != null) FirestoreService.deleteExpense(_uid!, id);
  }

  void setBudget(double budget) {
    state = state.copyWith(budget: budget);
    LocalStorageService.saveDouble(LocalStorageService.kBudget, budget);
    if (_uid != null) FirestoreService.setBudget(_uid!, budget);
  }

  void _persistLocal() {
    LocalStorageService.saveJsonList(
      LocalStorageService.kExpenses,
      state.expenses.map((e) => e.toJson()).toList(),
    );
    LocalStorageService.saveDouble(LocalStorageService.kBudget, state.budget);
  }
}

final moneyCrunchProvider = StateNotifierProvider<MoneyCrunchNotifier, MoneyCrunchState>((ref) {
  final user = ref.watch(currentUserProvider);
  return MoneyCrunchNotifier(user?.uid);
});
