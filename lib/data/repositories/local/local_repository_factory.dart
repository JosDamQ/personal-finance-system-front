import '../interfaces/i_alert_repository.dart';
import '../interfaces/i_budget_repository.dart';
import '../interfaces/i_category_repository.dart';
import '../interfaces/i_credit_card_repository.dart';
import '../interfaces/i_expense_repository.dart';
import '../interfaces/i_sync_queue_repository.dart';
import '../interfaces/i_user_repository.dart';
import 'local_alert_repository.dart';
import 'local_budget_repository.dart';
import 'local_category_repository.dart';
import 'local_credit_card_repository.dart';
import 'local_expense_repository.dart';
import 'local_sync_queue_repository.dart';
import 'local_user_repository.dart';

/// Factory class to provide access to all local repositories
/// This follows the singleton pattern to ensure consistent database access
class LocalRepositoryFactory {
  static final LocalRepositoryFactory _instance =
      LocalRepositoryFactory._internal();

  // Repository instances
  late final IUserRepository _userRepository;
  late final IBudgetRepository _budgetRepository;
  late final ICreditCardRepository _creditCardRepository;
  late final ICategoryRepository _categoryRepository;
  late final IExpenseRepository _expenseRepository;
  late final IAlertRepository _alertRepository;
  late final ISyncQueueRepository _syncQueueRepository;

  LocalRepositoryFactory._internal() {
    _userRepository = LocalUserRepository();
    _budgetRepository = LocalBudgetRepository();
    _creditCardRepository = LocalCreditCardRepository();
    _categoryRepository = LocalCategoryRepository();
    _expenseRepository = LocalExpenseRepository();
    _alertRepository = LocalAlertRepository();
    _syncQueueRepository = LocalSyncQueueRepository();
  }

  factory LocalRepositoryFactory() => _instance;

  // Repository getters
  IUserRepository get userRepository => _userRepository;
  IBudgetRepository get budgetRepository => _budgetRepository;
  ICreditCardRepository get creditCardRepository => _creditCardRepository;
  ICategoryRepository get categoryRepository => _categoryRepository;
  IExpenseRepository get expenseRepository => _expenseRepository;
  IAlertRepository get alertRepository => _alertRepository;
  ISyncQueueRepository get syncQueueRepository => _syncQueueRepository;
}
