import 'package:uuid/uuid.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';
import '../models/credit_card_model.dart';
import '../../core/enums/app_enums.dart';
import 'database_service.dart';
import 'offline_sync_service.dart';

/// High-level service for expense management
/// Handles both local storage and sync queue operations
class ExpenseService {
  static final ExpenseService _instance = ExpenseService._internal();

  final DatabaseService _databaseService = DatabaseService();
  final OfflineSyncService _syncService = OfflineSyncService();
  final Uuid _uuid = const Uuid();

  ExpenseService._internal();

  factory ExpenseService() => _instance;

  /// Create a new expense
  Future<ExpenseModel> createExpense({
    required String userId,
    required String categoryId,
    String? creditCardId,
    String? budgetPeriodId,
    required double amount,
    required Currency currency,
    required String description,
    DateTime? date,
  }) async {
    final expense = ExpenseModel(
      id: _uuid.v4(),
      userId: userId,
      categoryId: categoryId,
      creditCardId: creditCardId,
      budgetPeriodId: budgetPeriodId,
      amount: amount,
      currency: currency,
      description: description,
      date: date ?? DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );

    // Save locally
    final savedExpense = await _databaseService.expenses.create(expense);

    // Queue for sync
    await _syncService.queueOperation(
      userId: userId,
      operation: SyncOperation.create,
      entityType: EntityType.expense,
      entityId: expense.id,
      data: expense.toJson(),
    );

    // Update credit card balance if applicable
    if (creditCardId != null) {
      await _updateCreditCardBalance(creditCardId, amount, currency);
    }

    // Try to sync immediately if online
    await _syncService.syncIfOnline(userId);

    return savedExpense;
  }

  /// Update an existing expense
  Future<ExpenseModel> updateExpense(
    String expenseId, {
    String? categoryId,
    String? creditCardId,
    String? budgetPeriodId,
    double? amount,
    Currency? currency,
    String? description,
    DateTime? date,
  }) async {
    final existingExpense = await _databaseService.expenses.findById(expenseId);
    if (existingExpense == null) {
      throw Exception('Expense not found');
    }

    final updatedExpense = existingExpense.copyWith(
      categoryId: categoryId ?? existingExpense.categoryId,
      creditCardId: creditCardId ?? existingExpense.creditCardId,
      budgetPeriodId: budgetPeriodId ?? existingExpense.budgetPeriodId,
      amount: amount ?? existingExpense.amount,
      currency: currency ?? existingExpense.currency,
      description: description ?? existingExpense.description,
      date: date ?? existingExpense.date,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );

    // Save locally
    final savedExpense = await _databaseService.expenses.update(
      expenseId,
      updatedExpense,
    );

    // Queue for sync
    await _syncService.queueOperation(
      userId: existingExpense.userId,
      operation: SyncOperation.update,
      entityType: EntityType.expense,
      entityId: expenseId,
      data: updatedExpense.toJson(),
    );

    // Update credit card balances if changed
    if (amount != null ||
        currency != null ||
        creditCardId != existingExpense.creditCardId) {
      // Revert old balance
      if (existingExpense.creditCardId != null) {
        await _updateCreditCardBalance(
          existingExpense.creditCardId!,
          -existingExpense.amount,
          existingExpense.currency,
        );
      }

      // Apply new balance
      if (updatedExpense.creditCardId != null) {
        await _updateCreditCardBalance(
          updatedExpense.creditCardId!,
          updatedExpense.amount,
          updatedExpense.currency,
        );
      }
    }

    // Try to sync immediately if online
    await _syncService.syncIfOnline(existingExpense.userId);

    return savedExpense;
  }

  /// Delete an expense
  Future<void> deleteExpense(String expenseId) async {
    final expense = await _databaseService.expenses.findById(expenseId);
    if (expense == null) {
      throw Exception('Expense not found');
    }

    // Revert credit card balance
    if (expense.creditCardId != null) {
      await _updateCreditCardBalance(
        expense.creditCardId!,
        -expense.amount,
        expense.currency,
      );
    }

    // Delete locally
    await _databaseService.expenses.delete(expenseId);

    // Queue for sync
    await _syncService.queueOperation(
      userId: expense.userId,
      operation: SyncOperation.delete,
      entityType: EntityType.expense,
      entityId: expenseId,
      data: expense.toJson(),
    );

    // Try to sync immediately if online
    await _syncService.syncIfOnline(expense.userId);
  }

  /// Get expenses for a user with optional filters
  Future<List<ExpenseModel>> getExpenses({
    required String userId,
    String? categoryId,
    String? creditCardId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (categoryId != null) {
      return await _databaseService.expenses.findByCategory(categoryId);
    } else if (creditCardId != null) {
      return await _databaseService.expenses.findByCreditCard(creditCardId);
    } else if (startDate != null && endDate != null) {
      return await _databaseService.expenses.findByDateRange(
        startDate,
        endDate,
      );
    } else {
      return await _databaseService.expenses.findByUser(userId);
    }
  }

  /// Get expense totals by category for a date range
  Future<Map<String, double>> getExpenseTotalsByCategory({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _databaseService.expenses.getTotalsByCategory(
      userId,
      startDate,
      endDate,
    );
  }

  /// Get expense total for a specific credit card
  Future<double> getCreditCardTotal(String creditCardId) async {
    return await _databaseService.expenses.getTotalByCreditCard(creditCardId);
  }

  /// Update credit card balance based on expense
  Future<void> _updateCreditCardBalance(
    String creditCardId,
    double amount,
    Currency currency,
  ) async {
    final creditCard = await _databaseService.creditCards.findById(
      creditCardId,
    );
    if (creditCard == null) return;

    double newBalanceGTQ = creditCard.currentBalanceGTQ;
    double newBalanceUSD = creditCard.currentBalanceUSD;

    if (currency == Currency.gtq) {
      newBalanceGTQ += amount;
    } else {
      newBalanceUSD += amount;
    }

    await _databaseService.creditCards.updateBalance(
      creditCardId,
      newBalanceGTQ,
      newBalanceUSD,
    );

    // Queue the credit card update for sync
    final updatedCreditCard = creditCard.copyWith(
      currentBalanceGTQ: newBalanceGTQ,
      currentBalanceUSD: newBalanceUSD,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );

    await _syncService.queueOperation(
      userId: creditCard.userId,
      operation: SyncOperation.update,
      entityType: EntityType.creditCard,
      entityId: creditCardId,
      data: updatedCreditCard.toJson(),
    );
  }

  /// Get expenses with category and credit card details
  Future<List<ExpenseWithDetails>> getExpensesWithDetails({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final expenses = startDate != null && endDate != null
        ? await _databaseService.expenses.findByDateRange(startDate, endDate)
        : await _databaseService.expenses.findByUser(userId);

    final expensesWithDetails = <ExpenseWithDetails>[];

    for (final expense in expenses) {
      final category = await _databaseService.categories.findById(
        expense.categoryId,
      );
      final creditCard = expense.creditCardId != null
          ? await _databaseService.creditCards.findById(expense.creditCardId!)
          : null;

      expensesWithDetails.add(
        ExpenseWithDetails(
          expense: expense,
          category: category,
          creditCard: creditCard,
        ),
      );
    }

    return expensesWithDetails;
  }
}

/// Expense with related category and credit card details
class ExpenseWithDetails {
  final ExpenseModel expense;
  final CategoryModel? category;
  final CreditCardModel? creditCard;

  ExpenseWithDetails({required this.expense, this.category, this.creditCard});
}
