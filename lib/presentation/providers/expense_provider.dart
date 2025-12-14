import 'package:flutter/foundation.dart';
import '../../core/enums/app_enums.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/interfaces/i_expense_repository.dart';

class ExpenseProvider extends ChangeNotifier {
  final IExpenseRepository _expenseRepository;

  ExpenseProvider(this._expenseRepository);

  List<ExpenseModel> _expenses = [];
  LoadingState _loadingState = LoadingState.initial;
  String? _errorMessage;

  // Getters
  List<ExpenseModel> get expenses => _expenses;
  LoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _loadingState == LoadingState.loading;

  // CRUD operations
  Future<void> loadExpenses(String userId) async {
    try {
      _setLoadingState(LoadingState.loading);
      _expenses = await _expenseRepository.findByUser(userId);
      _setLoadingState(LoadingState.loaded);
    } catch (e) {
      _setError('Failed to load expenses: ${e.toString()}');
    }
  }

  Future<void> createExpense(ExpenseModel expense) async {
    try {
      _setLoadingState(LoadingState.loading);
      final createdExpense = await _expenseRepository.create(expense);
      _expenses.insert(0, createdExpense);
      _setLoadingState(LoadingState.loaded);
    } catch (e) {
      _setError('Failed to create expense: ${e.toString()}');
    }
  }

  Future<void> updateExpense(String id, ExpenseModel expense) async {
    try {
      _setLoadingState(LoadingState.loading);
      final updatedExpense = await _expenseRepository.update(id, expense);
      
      final index = _expenses.indexWhere((e) => e.id == id);
      if (index != -1) {
        _expenses[index] = updatedExpense;
      }
      
      _setLoadingState(LoadingState.loaded);
    } catch (e) {
      _setError('Failed to update expense: ${e.toString()}');
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      _setLoadingState(LoadingState.loading);
      await _expenseRepository.delete(id);
      _expenses.removeWhere((e) => e.id == id);
      _setLoadingState(LoadingState.loaded);
    } catch (e) {
      _setError('Failed to delete expense: ${e.toString()}');
    }
  }

  // Filtering operations
  Future<void> loadExpensesByCategory(String categoryId) async {
    try {
      _setLoadingState(LoadingState.loading);
      _expenses = await _expenseRepository.findByCategory(categoryId);
      _setLoadingState(LoadingState.loaded);
    } catch (e) {
      _setError('Failed to load expenses by category: ${e.toString()}');
    }
  }

  Future<void> loadExpensesByCreditCard(String creditCardId) async {
    try {
      _setLoadingState(LoadingState.loading);
      _expenses = await _expenseRepository.findByCreditCard(creditCardId);
      _setLoadingState(LoadingState.loaded);
    } catch (e) {
      _setError('Failed to load expenses by credit card: ${e.toString()}');
    }
  }

  Future<void> loadExpensesByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      _setLoadingState(LoadingState.loading);
      _expenses = await _expenseRepository.findByDateRange(startDate, endDate);
      _setLoadingState(LoadingState.loaded);
    } catch (e) {
      _setError('Failed to load expenses by date range: ${e.toString()}');
    }
  }

  // Aggregation operations
  Future<double> getTotalByCategory(String categoryId) async {
    try {
      return await _expenseRepository.getTotalByCategory(categoryId);
    } catch (e) {
      _setError('Failed to get total by category: ${e.toString()}');
      return 0.0;
    }
  }

  Future<double> getTotalByCreditCard(String creditCardId) async {
    try {
      return await _expenseRepository.getTotalByCreditCard(creditCardId);
    } catch (e) {
      _setError('Failed to get total by credit card: ${e.toString()}');
      return 0.0;
    }
  }

  Future<Map<String, double>> getTotalsByCategory(String userId, DateTime startDate, DateTime endDate) async {
    try {
      return await _expenseRepository.getTotalsByCategory(userId, startDate, endDate);
    } catch (e) {
      _setError('Failed to get totals by category: ${e.toString()}');
      return {};
    }
  }

  // Sync operations
  Future<void> syncPendingExpenses() async {
    try {
      final pendingExpenses = await _expenseRepository.findPendingSync();
      
      for (final expense in pendingExpenses) {
        // TODO: Implement actual sync logic with API
        // For now, just mark as synced
        await _expenseRepository.markAsSynced(expense.id);
      }
      
      // Reload expenses to reflect sync status changes
      if (_expenses.isNotEmpty) {
        final userId = _expenses.first.userId;
        await loadExpenses(userId);
      }
    } catch (e) {
      _setError('Failed to sync expenses: ${e.toString()}');
    }
  }

  // Helper methods
  void _setLoadingState(LoadingState state) {
    _loadingState = state;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _loadingState = LoadingState.error;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_loadingState == LoadingState.error) {
      _loadingState = LoadingState.initial;
    }
    notifyListeners();
  }

  // Local filtering (for UI performance)
  List<ExpenseModel> getExpensesByCategory(String categoryId) {
    return _expenses.where((e) => e.categoryId == categoryId).toList();
  }

  List<ExpenseModel> getExpensesByCreditCard(String creditCardId) {
    return _expenses.where((e) => e.creditCardId == creditCardId).toList();
  }

  List<ExpenseModel> getExpensesInDateRange(DateTime startDate, DateTime endDate) {
    return _expenses.where((e) => 
      e.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
      e.date.isBefore(endDate.add(const Duration(days: 1)))
    ).toList();
  }
}