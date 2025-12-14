import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/budgets/budget_list_screen.dart';
import '../../presentation/screens/budgets/budget_form_screen.dart';
import '../../presentation/screens/expenses/expense_list_screen.dart';
import '../../presentation/screens/expenses/expense_form_screen.dart';
import '../../presentation/screens/credit_cards/credit_card_list_screen.dart';
import '../../presentation/screens/credit_cards/credit_card_form_screen.dart';
import '../../presentation/screens/categories/category_list_screen.dart';
import '../../presentation/screens/categories/category_form_screen.dart';
import '../../presentation/screens/alerts/alert_list_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/reports/report_screen.dart';
import '../../presentation/screens/history/history_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String budgets = '/budgets';
  static const String budgetForm = '/budgets/form';
  static const String expenses = '/expenses';
  static const String expenseForm = '/expenses/form';
  static const String creditCards = '/credit-cards';
  static const String creditCardForm = '/credit-cards/form';
  static const String categories = '/categories';
  static const String categoryForm = '/categories/form';
  static const String alerts = '/alerts';
  static const String settings = '/settings';
  static const String reports = '/reports';
  static const String history = '/history';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      // Splash Screen
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication Routes
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main App Routes
      GoRoute(
        path: dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),

      // Budget Routes
      GoRoute(
        path: budgets,
        name: 'budgets',
        builder: (context, state) => const BudgetListScreen(),
      ),
      GoRoute(
        path: budgetForm,
        name: 'budgetForm',
        builder: (context, state) {
          final budgetId = state.uri.queryParameters['id'];
          return BudgetFormScreen(budgetId: budgetId);
        },
      ),

      // Expense Routes
      GoRoute(
        path: expenses,
        name: 'expenses',
        builder: (context, state) => const ExpenseListScreen(),
      ),
      GoRoute(
        path: expenseForm,
        name: 'expenseForm',
        builder: (context, state) {
          final expenseId = state.uri.queryParameters['id'];
          return ExpenseFormScreen(expenseId: expenseId);
        },
      ),

      // Credit Card Routes
      GoRoute(
        path: creditCards,
        name: 'creditCards',
        builder: (context, state) => const CreditCardListScreen(),
      ),
      GoRoute(
        path: creditCardForm,
        name: 'creditCardForm',
        builder: (context, state) {
          final cardId = state.uri.queryParameters['id'];
          return CreditCardFormScreen(cardId: cardId);
        },
      ),

      // Category Routes
      GoRoute(
        path: categories,
        name: 'categories',
        builder: (context, state) => const CategoryListScreen(),
      ),
      GoRoute(
        path: categoryForm,
        name: 'categoryForm',
        builder: (context, state) {
          final categoryId = state.uri.queryParameters['id'];
          return CategoryFormScreen(categoryId: categoryId);
        },
      ),

      // Other Routes
      GoRoute(
        path: alerts,
        name: 'alerts',
        builder: (context, state) => const AlertListScreen(),
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: reports,
        name: 'reports',
        builder: (context, state) => const ReportScreen(),
      ),
      GoRoute(
        path: history,
        name: 'history',
        builder: (context, state) => const HistoryScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(dashboard),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
}