import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/expense_provider.dart';
import 'presentation/providers/sync_provider.dart';
import 'data/repositories/local/local_expense_repository.dart';
import 'data/services/database_service.dart';
import 'data/services/app_sync_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  final databaseService = DatabaseService();
  await databaseService.initialize();

  runApp(const PersonalFinanceApp());
}

class PersonalFinanceApp extends StatelessWidget {
  const PersonalFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(create: (context) => AuthProvider()),

        // Sync Provider
        ChangeNotifierProvider(create: (context) => SyncProvider()),

        // Expense Provider
        ChangeNotifierProvider(
          create: (context) => ExpenseProvider(LocalExpenseRepository()),
        ),

        // TODO: Add other providers as needed
        // - BudgetProvider
        // - CreditCardProvider
        // - CategoryProvider
        // - AlertProvider
      ],
      child: SyncManagerWidget(
        child: MaterialApp.router(
          title: 'Finance App',
          debugShowCheckedModeBanner: false,

          // Theme Configuration
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,

          // Router Configuration
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
