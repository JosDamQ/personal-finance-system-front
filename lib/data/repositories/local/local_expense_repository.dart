import '../../../core/enums/app_enums.dart';
import '../../database/database_helper.dart';
import '../../models/expense_model.dart';
import '../interfaces/i_expense_repository.dart';

class LocalExpenseRepository implements IExpenseRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Future<ExpenseModel> create(ExpenseModel expense) async {
    final db = await _databaseHelper.database;

    final expenseMap = <String, dynamic>{
      'id': expense.id,
      'user_id': expense.userId,
      'category_id': expense.categoryId,
      'credit_card_id': expense.creditCardId,
      'budget_period_id': expense.budgetPeriodId,
      'amount': expense.amount,
      'currency': expense.currency.value,
      'description': expense.description,
      'date': expense.date.toIso8601String(),
      'sync_status': expense.syncStatus?.value ?? SyncStatus.pending.value,
      'last_sync_at': expense.lastSyncAt?.toIso8601String(),
      'created_at': expense.createdAt.toIso8601String(),
      'updated_at': expense.updatedAt.toIso8601String(),
    };

    await db.insert('expenses', expenseMap);
    return expense;
  }

  @override
  Future<ExpenseModel> update(String id, ExpenseModel expense) async {
    final db = await _databaseHelper.database;

    final expenseMap = <String, dynamic>{
      'id': expense.id,
      'user_id': expense.userId,
      'category_id': expense.categoryId,
      'credit_card_id': expense.creditCardId,
      'budget_period_id': expense.budgetPeriodId,
      'amount': expense.amount,
      'currency': expense.currency.value,
      'description': expense.description,
      'date': expense.date.toIso8601String(),
      'sync_status': expense.syncStatus?.value ?? SyncStatus.pending.value,
      'last_sync_at': expense.lastSyncAt?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    await db.update('expenses', expenseMap, where: 'id = ?', whereArgs: [id]);

    return expense.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> delete(String id) async {
    final db = await _databaseHelper.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<ExpenseModel?> findById(String id) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;
    return _mapToExpenseModel(results.first);
  }

  @override
  Future<List<ExpenseModel>> findByUser(String userId) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'expenses',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    return results.map(_mapToExpenseModel).toList();
  }

  @override
  Future<List<ExpenseModel>> findByCategory(String categoryId) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'expenses',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'date DESC',
    );

    return results.map(_mapToExpenseModel).toList();
  }

  @override
  Future<List<ExpenseModel>> findByCreditCard(String creditCardId) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'expenses',
      where: 'credit_card_id = ?',
      whereArgs: [creditCardId],
      orderBy: 'date DESC',
    );

    return results.map(_mapToExpenseModel).toList();
  }

  @override
  Future<List<ExpenseModel>> findByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'expenses',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date DESC',
    );

    return results.map(_mapToExpenseModel).toList();
  }

  @override
  Future<List<ExpenseModel>> findByBudgetPeriod(String budgetPeriodId) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'expenses',
      where: 'budget_period_id = ?',
      whereArgs: [budgetPeriodId],
      orderBy: 'date DESC',
    );

    return results.map(_mapToExpenseModel).toList();
  }

  @override
  Future<List<ExpenseModel>> findPendingSync() async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'expenses',
      where: 'sync_status = ?',
      whereArgs: [SyncStatus.pending.value],
      orderBy: 'created_at ASC',
    );

    return results.map(_mapToExpenseModel).toList();
  }

  @override
  Future<void> markAsSynced(String id) async {
    await updateSyncStatus(id, SyncStatus.synced);
  }

  @override
  Future<void> markAsConflict(String id) async {
    await updateSyncStatus(id, SyncStatus.conflict);
  }

  @override
  Future<void> updateSyncStatus(String id, SyncStatus status) async {
    final db = await _databaseHelper.database;
    await db.update(
      'expenses',
      {
        'sync_status': status.value,
        'last_sync_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<double> getTotalByCategory(String categoryId) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE category_id = ?',
      [categoryId],
    );

    return (result.first['total'] as double?) ?? 0.0;
  }

  @override
  Future<double> getTotalByCreditCard(String creditCardId) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE credit_card_id = ?',
      [creditCardId],
    );

    return (result.first['total'] as double?) ?? 0.0;
  }

  @override
  Future<double> getTotalByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE date >= ? AND date <= ?',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    return (result.first['total'] as double?) ?? 0.0;
  }

  @override
  Future<Map<String, double>> getTotalsByCategory(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _databaseHelper.database;
    final results = await db.rawQuery(
      '''
      SELECT c.name, SUM(e.amount) as total 
      FROM expenses e 
      JOIN categories c ON e.category_id = c.id 
      WHERE e.user_id = ? AND e.date >= ? AND e.date <= ?
      GROUP BY c.id, c.name
    ''',
      [userId, startDate.toIso8601String(), endDate.toIso8601String()],
    );

    final totals = <String, double>{};
    for (final result in results) {
      totals[result['name'] as String] = (result['total'] as double?) ?? 0.0;
    }

    return totals;
  }

  ExpenseModel _mapToExpenseModel(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      categoryId: map['category_id'] as String,
      creditCardId: map['credit_card_id'] as String?,
      budgetPeriodId: map['budget_period_id'] as String?,
      amount: map['amount'] as double,
      currency: Currency.values.firstWhere((e) => e.value == map['currency']),
      description: map['description'] as String,
      date: DateTime.parse(map['date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      syncStatus: map['sync_status'] != null
          ? SyncStatus.values.firstWhere((e) => e.value == map['sync_status'])
          : null,
      lastSyncAt: map['last_sync_at'] != null
          ? DateTime.parse(map['last_sync_at'] as String)
          : null,
    );
  }
}
