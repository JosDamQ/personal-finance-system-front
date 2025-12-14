import '../../../core/enums/app_enums.dart';
import '../../database/database_helper.dart';
import '../../models/budget_model.dart';
import '../interfaces/i_budget_repository.dart';

class LocalBudgetRepository implements IBudgetRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Future<BudgetModel> create(BudgetModel budget) async {
    final db = await _databaseHelper.database;

    final budgetMap = <String, dynamic>{
      'id': budget.id,
      'user_id': budget.userId,
      'month': budget.month,
      'year': budget.year,
      'payment_frequency': budget.paymentFrequency.value,
      'total_income': budget.totalIncome,
      'sync_status': budget.syncStatus?.value ?? SyncStatus.pending.value,
      'last_sync_at': budget.lastSyncAt?.toIso8601String(),
      'created_at': budget.createdAt.toIso8601String(),
      'updated_at': budget.updatedAt.toIso8601String(),
    };

    await db.insert('budgets', budgetMap);

    // Insert budget periods
    for (final period in budget.periods) {
      final periodMap = <String, dynamic>{
        'id': period.id,
        'budget_id': period.budgetId,
        'period_number': period.periodNumber,
        'income': period.income,
        'created_at': period.createdAt.toIso8601String(),
        'updated_at': period.updatedAt.toIso8601String(),
      };
      await db.insert('budget_periods', periodMap);
    }

    return budget;
  }

  @override
  Future<BudgetModel> update(String id, BudgetModel budget) async {
    final db = await _databaseHelper.database;

    final budgetMap = <String, dynamic>{
      'id': budget.id,
      'user_id': budget.userId,
      'month': budget.month,
      'year': budget.year,
      'payment_frequency': budget.paymentFrequency.value,
      'total_income': budget.totalIncome,
      'sync_status': budget.syncStatus?.value ?? SyncStatus.pending.value,
      'last_sync_at': budget.lastSyncAt?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    await db.update('budgets', budgetMap, where: 'id = ?', whereArgs: [id]);

    // Delete existing periods and insert new ones
    await db.delete('budget_periods', where: 'budget_id = ?', whereArgs: [id]);
    for (final period in budget.periods) {
      final periodMap = <String, dynamic>{
        'id': period.id,
        'budget_id': period.budgetId,
        'period_number': period.periodNumber,
        'income': period.income,
        'created_at': period.createdAt.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      await db.insert('budget_periods', periodMap);
    }

    return budget.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> delete(String id) async {
    final db = await _databaseHelper.database;
    // Budget periods will be deleted automatically due to CASCADE
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<BudgetModel?> findById(String id) async {
    final db = await _databaseHelper.database;
    final results = await db.query('budgets', where: 'id = ?', whereArgs: [id]);

    if (results.isEmpty) return null;
    return await _mapToBudgetModel(results.first);
  }

  @override
  Future<List<BudgetModel>> findByUser(String userId) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'budgets',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'year DESC, month DESC',
    );

    final budgets = <BudgetModel>[];
    for (final result in results) {
      budgets.add(await _mapToBudgetModel(result));
    }
    return budgets;
  }

  @override
  Future<BudgetModel?> findByUserAndPeriod(
    String userId,
    int month,
    int year,
  ) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'budgets',
      where: 'user_id = ? AND month = ? AND year = ?',
      whereArgs: [userId, month, year],
    );

    if (results.isEmpty) return null;
    return await _mapToBudgetModel(results.first);
  }

  @override
  Future<List<BudgetModel>> findByYear(String userId, int year) async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'budgets',
      where: 'user_id = ? AND year = ?',
      whereArgs: [userId, year],
      orderBy: 'month ASC',
    );

    final budgets = <BudgetModel>[];
    for (final result in results) {
      budgets.add(await _mapToBudgetModel(result));
    }
    return budgets;
  }

  @override
  Future<List<BudgetModel>> findPendingSync() async {
    final db = await _databaseHelper.database;
    final results = await db.query(
      'budgets',
      where: 'sync_status = ?',
      whereArgs: [SyncStatus.pending.value],
      orderBy: 'created_at ASC',
    );

    final budgets = <BudgetModel>[];
    for (final result in results) {
      budgets.add(await _mapToBudgetModel(result));
    }
    return budgets;
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
      'budgets',
      {
        'sync_status': status.value,
        'last_sync_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<BudgetModel> _mapToBudgetModel(Map<String, dynamic> map) async {
    // Get budget periods
    final db = await _databaseHelper.database;
    final periodResults = await db.query(
      'budget_periods',
      where: 'budget_id = ?',
      whereArgs: [map['id']],
      orderBy: 'period_number ASC',
    );

    final periods = periodResults
        .map(
          (periodMap) => BudgetPeriodModel(
            id: periodMap['id'] as String,
            budgetId: periodMap['budget_id'] as String,
            periodNumber: periodMap['period_number'] as int,
            income: periodMap['income'] as double,
            createdAt: DateTime.parse(periodMap['created_at'] as String),
            updatedAt: DateTime.parse(periodMap['updated_at'] as String),
          ),
        )
        .toList();

    return BudgetModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      month: map['month'] as int,
      year: map['year'] as int,
      paymentFrequency: PaymentFrequency.values.firstWhere(
        (e) => e.value == map['payment_frequency'],
      ),
      totalIncome: map['total_income'] as double,
      periods: periods,
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
