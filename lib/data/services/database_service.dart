import '../database/database_helper.dart';
import '../repositories/local/local_repository_factory.dart';
import '../repositories/interfaces/i_alert_repository.dart';
import '../repositories/interfaces/i_budget_repository.dart';
import '../repositories/interfaces/i_category_repository.dart';
import '../repositories/interfaces/i_credit_card_repository.dart';
import '../repositories/interfaces/i_expense_repository.dart';
import '../repositories/interfaces/i_sync_queue_repository.dart';
import '../repositories/interfaces/i_user_repository.dart';
import '../models/category_model.dart';
import '../../core/enums/app_enums.dart';

/// High-level service for database operations
/// Provides a clean interface to access all repositories and database utilities
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final LocalRepositoryFactory _repositoryFactory = LocalRepositoryFactory();

  DatabaseService._internal();

  factory DatabaseService() => _instance;

  // Repository access
  IUserRepository get users => _repositoryFactory.userRepository;
  IBudgetRepository get budgets => _repositoryFactory.budgetRepository;
  ICreditCardRepository get creditCards =>
      _repositoryFactory.creditCardRepository;
  ICategoryRepository get categories => _repositoryFactory.categoryRepository;
  IExpenseRepository get expenses => _repositoryFactory.expenseRepository;
  IAlertRepository get alerts => _repositoryFactory.alertRepository;
  ISyncQueueRepository get syncQueue => _repositoryFactory.syncQueueRepository;

  // Database utilities
  Future<void> initialize() async {
    await _databaseHelper.database;
  }

  Future<void> close() async {
    await _databaseHelper.closeDatabase();
  }

  Future<void> clearAllData() async {
    await _databaseHelper.deleteDatabase();
  }

  /// Initialize database with default categories for a user
  Future<void> initializeUserDefaults(String userId) async {
    // Check if default categories already exist
    final existingCategories = await categories.findByUser(userId);
    if (existingCategories.isNotEmpty) {
      return; // Already initialized
    }

    // Create default categories
    final defaultCategories = _getDefaultCategories(userId);
    for (final category in defaultCategories) {
      await categories.create(category);
    }
  }

  List<CategoryModel> _getDefaultCategories(String userId) {
    final now = DateTime.now();
    return [
      CategoryModel(
        id: 'default_food_$userId',
        userId: userId,
        name: 'Alimentación',
        color: '#FF6B6B',
        icon: '🍽️',
        isDefault: false,
        createdAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.pending,
      ),
      CategoryModel(
        id: 'default_transport_$userId',
        userId: userId,
        name: 'Transporte',
        color: '#4ECDC4',
        icon: '🚗',
        isDefault: false,
        createdAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.pending,
      ),
      CategoryModel(
        id: 'default_entertainment_$userId',
        userId: userId,
        name: 'Entretenimiento',
        color: '#45B7D1',
        icon: '🎬',
        isDefault: false,
        createdAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.pending,
      ),
      CategoryModel(
        id: 'default_shopping_$userId',
        userId: userId,
        name: 'Compras',
        color: '#F7DC6F',
        icon: '🛍️',
        isDefault: false,
        createdAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.pending,
      ),
      CategoryModel(
        id: 'default_health_$userId',
        userId: userId,
        name: 'Salud',
        color: '#BB8FCE',
        icon: '🏥',
        isDefault: false,
        createdAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.pending,
      ),
      CategoryModel(
        id: 'default_other_$userId',
        userId: userId,
        name: 'Otros',
        color: '#95A5A6',
        icon: '💰',
        isDefault: true,
        createdAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.pending,
      ),
    ];
  }

  /// Get database statistics for debugging
  Future<Map<String, int>> getDatabaseStats() async {
    final db = await _databaseHelper.database;

    final stats = <String, int>{};

    // Count records in each table
    final tables = [
      'users',
      'budgets',
      'budget_periods',
      'credit_cards',
      'categories',
      'expenses',
      'alerts',
      'sync_queue',
    ];

    for (final table in tables) {
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table');
      stats[table] = (result.first['count'] as int?) ?? 0;
    }

    return stats;
  }

  /// Clear sync queue for a specific user
  Future<void> clearUserSyncQueue(String userId) async {
    await syncQueue.clearAllItems(userId);
  }

  /// Get pending sync items count for a user
  Future<int> getPendingSyncCount(String userId) async {
    final pendingItems = await syncQueue.findPendingItems(userId);
    return pendingItems.length;
  }
}
