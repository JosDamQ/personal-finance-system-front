import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:finance_app/data/services/database_service.dart';
import 'package:finance_app/data/services/expense_service.dart';
import 'package:finance_app/data/models/user_model.dart';
import 'package:finance_app/data/models/category_model.dart';
import 'package:finance_app/data/models/credit_card_model.dart';
import 'package:finance_app/core/enums/app_enums.dart';

void main() {
  // Initialize FFI for testing
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Mock connectivity plugin
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dev.fluttercommunity.plus/connectivity'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'check') {
              return 'none'; // Always return no connectivity for tests
            }
            return null;
          },
        );
  });

  group('Expense Service Tests', () {
    late DatabaseService databaseService;
    late ExpenseService expenseService;
    late String userId;
    late String categoryId;
    late String creditCardId;

    setUp(() async {
      databaseService = DatabaseService();
      expenseService = ExpenseService();

      await databaseService.initialize();
      await databaseService.clearAllData();
      await databaseService.initialize();

      // Create test user
      userId = 'test-user-1';
      final user = UserModel(
        id: userId,
        email: 'test@example.com',
        name: 'Test User',
        defaultCurrency: 'GTQ',
        theme: 'light',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await databaseService.users.create(user);

      // Create test category
      categoryId = 'test-category-1';
      final category = CategoryModel(
        id: categoryId,
        userId: userId,
        name: 'Test Category',
        color: '#FF0000',
        icon: '🧪',
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.synced,
      );
      await databaseService.categories.create(category);

      // Create test credit card
      creditCardId = 'test-card-1';
      final creditCard = CreditCardModel(
        id: creditCardId,
        userId: userId,
        name: 'Test Card',
        bank: 'Test Bank',
        limitGTQ: 10000.0,
        limitUSD: 1000.0,
        currentBalanceGTQ: 0.0,
        currentBalanceUSD: 0.0,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.synced,
      );
      await databaseService.creditCards.create(creditCard);
    });

    tearDown(() async {
      await databaseService.clearAllData();
      await databaseService.close();
    });

    test('should create expense and update credit card balance', () async {
      // Act
      final expense = await expenseService.createExpense(
        userId: userId,
        categoryId: categoryId,
        creditCardId: creditCardId,
        amount: 100.0,
        currency: Currency.gtq,
        description: 'Test expense',
      );

      // Assert
      expect(expense.amount, equals(100.0));
      expect(expense.description, equals('Test expense'));
      expect(expense.syncStatus, equals(SyncStatus.pending));

      // Check credit card balance was updated
      final updatedCard = await databaseService.creditCards.findById(
        creditCardId,
      );
      expect(updatedCard!.currentBalanceGTQ, equals(100.0));
      expect(updatedCard.currentBalanceUSD, equals(0.0));

      // Check sync queue has the operation
      final syncItems = await databaseService.syncQueue.findPendingItems(
        userId,
      );
      expect(
        syncItems.length,
        equals(2),
      ); // expense + credit card balance update
    });

    test('should update expense and adjust credit card balance', () async {
      // Arrange
      final expense = await expenseService.createExpense(
        userId: userId,
        categoryId: categoryId,
        creditCardId: creditCardId,
        amount: 100.0,
        currency: Currency.gtq,
        description: 'Original expense',
      );

      // Act
      await expenseService.updateExpense(
        expense.id,
        amount: 150.0,
        description: 'Updated expense',
      );

      // Assert
      final updatedExpense = await databaseService.expenses.findById(
        expense.id,
      );
      expect(updatedExpense!.amount, equals(150.0));
      expect(updatedExpense.description, equals('Updated expense'));

      // Check credit card balance was adjusted
      final updatedCard = await databaseService.creditCards.findById(
        creditCardId,
      );
      expect(updatedCard!.currentBalanceGTQ, equals(150.0));
    });

    test('should delete expense and revert credit card balance', () async {
      // Arrange
      final expense = await expenseService.createExpense(
        userId: userId,
        categoryId: categoryId,
        creditCardId: creditCardId,
        amount: 100.0,
        currency: Currency.gtq,
        description: 'Test expense',
      );

      // Act
      await expenseService.deleteExpense(expense.id);

      // Assert
      final deletedExpense = await databaseService.expenses.findById(
        expense.id,
      );
      expect(deletedExpense, isNull);

      // Check credit card balance was reverted
      final updatedCard = await databaseService.creditCards.findById(
        creditCardId,
      );
      expect(updatedCard!.currentBalanceGTQ, equals(0.0));
    });

    test('should get expenses with details', () async {
      // Arrange
      await expenseService.createExpense(
        userId: userId,
        categoryId: categoryId,
        creditCardId: creditCardId,
        amount: 100.0,
        currency: Currency.gtq,
        description: 'Test expense 1',
      );

      await expenseService.createExpense(
        userId: userId,
        categoryId: categoryId,
        amount: 50.0,
        currency: Currency.usd,
        description: 'Test expense 2',
      );

      // Act
      final expensesWithDetails = await expenseService.getExpensesWithDetails(
        userId: userId,
      );

      // Assert
      expect(expensesWithDetails.length, equals(2));
      expect(expensesWithDetails[0].category?.name, equals('Test Category'));
      expect(
        expensesWithDetails[0].creditCard,
        isNull,
      ); // Second expense (newest) has no credit card
      expect(expensesWithDetails[1].category?.name, equals('Test Category'));
      expect(
        expensesWithDetails[1].creditCard?.name,
        equals('Test Card'),
      ); // First expense (older) has credit card
    });

    test('should get expense totals by category', () async {
      // Arrange
      await expenseService.createExpense(
        userId: userId,
        categoryId: categoryId,
        amount: 100.0,
        currency: Currency.gtq,
        description: 'Test expense 1',
      );

      await expenseService.createExpense(
        userId: userId,
        categoryId: categoryId,
        amount: 50.0,
        currency: Currency.gtq,
        description: 'Test expense 2',
      );

      // Act
      final totals = await expenseService.getExpenseTotalsByCategory(
        userId: userId,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 1)),
      );

      // Assert
      expect(totals['Test Category'], equals(150.0));
    });

    test('should handle expenses without credit card', () async {
      // Act
      final expense = await expenseService.createExpense(
        userId: userId,
        categoryId: categoryId,
        amount: 100.0,
        currency: Currency.gtq,
        description: 'Cash expense',
      );

      // Assert
      expect(expense.creditCardId, isNull);

      // Credit card balance should remain unchanged
      final card = await databaseService.creditCards.findById(creditCardId);
      expect(card!.currentBalanceGTQ, equals(0.0));
    });
  });
}
