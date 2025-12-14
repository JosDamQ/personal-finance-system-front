import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:finance_app/data/services/database_service.dart';
import 'package:finance_app/data/models/user_model.dart';
import 'package:finance_app/data/models/category_model.dart';
import 'package:finance_app/core/enums/app_enums.dart';

void main() {
  // Initialize FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Database Tests', () {
    late DatabaseService databaseService;

    setUp(() async {
      databaseService = DatabaseService();
      await databaseService.initialize();
      await databaseService.clearAllData();
      await databaseService.initialize();
    });

    tearDown(() async {
      await databaseService.clearAllData();
      await databaseService.close();
    });

    test('should create and retrieve user', () async {
      // Arrange
      final user = UserModel(
        id: 'test-user-1',
        email: 'test@example.com',
        name: 'Test User',
        defaultCurrency: 'GTQ',
        theme: 'light',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      await databaseService.users.create(user);
      final retrievedUser = await databaseService.users.findById('test-user-1');

      // Assert
      expect(retrievedUser, isNotNull);
      expect(retrievedUser!.email, equals('test@example.com'));
      expect(retrievedUser.name, equals('Test User'));
    });

    test('should create and retrieve category', () async {
      // Arrange
      final category = CategoryModel(
        id: 'test-category-1',
        userId: 'test-user-1',
        name: 'Test Category',
        color: '#FF0000',
        icon: '🧪',
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
      );

      // Act
      await databaseService.categories.create(category);
      final retrievedCategory = await databaseService.categories.findById(
        'test-category-1',
      );

      // Assert
      expect(retrievedCategory, isNotNull);
      expect(retrievedCategory!.name, equals('Test Category'));
      expect(retrievedCategory.color, equals('#FF0000'));
      expect(retrievedCategory.syncStatus, equals(SyncStatus.pending));
    });

    test('should initialize default categories for user', () async {
      // Arrange
      const userId = 'test-user-1';

      // Act
      await databaseService.initializeUserDefaults(userId);
      final categories = await databaseService.categories.findByUser(userId);

      // Assert
      expect(categories.length, equals(6));
      expect(categories.any((c) => c.name == 'Alimentación'), isTrue);
      expect(categories.any((c) => c.name == 'Transporte'), isTrue);
      expect(categories.any((c) => c.isDefault), isTrue);
    });

    test('should get database statistics', () async {
      // Arrange
      const userId = 'test-user-1';
      await databaseService.initializeUserDefaults(userId);

      // Act
      final stats = await databaseService.getDatabaseStats();

      // Assert
      expect(stats['categories'], equals(6));
      expect(stats['users'], equals(0));
      expect(stats['expenses'], equals(0));
    });

    test('should handle sync status updates', () async {
      // Arrange
      final category = CategoryModel(
        id: 'test-category-1',
        userId: 'test-user-1',
        name: 'Test Category',
        color: '#FF0000',
        icon: '🧪',
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
      );

      await databaseService.categories.create(category);

      // Act
      await databaseService.categories.markAsSynced('test-category-1');
      final updatedCategory = await databaseService.categories.findById(
        'test-category-1',
      );

      // Assert
      expect(updatedCategory!.syncStatus, equals(SyncStatus.synced));
      expect(updatedCategory.lastSyncAt, isNotNull);
    });
  });
}
