import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:finance_app/presentation/providers/auth_provider.dart';
import 'package:finance_app/presentation/screens/auth/login_screen.dart';
import 'package:finance_app/presentation/screens/auth/register_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  group('Authentication Integration Tests', () {
    setUp(() {
      // Mock secure storage for tests
      FlutterSecureStorage.setMockInitialValues({});
    });

    testWidgets('Login screen should display correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (context) => AuthProvider(),
            child: const LoginScreen(),
          ),
        ),
      );

      // Verify login screen elements
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(
        find.text('Sign in to continue managing your finances'),
        findsOneWidget,
      );
      expect(
        find.byType(TextFormField),
        findsNWidgets(2),
      ); // Email and password fields
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text("Don't have an account? "), findsOneWidget);
    });

    testWidgets('Register screen should display correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (context) => AuthProvider(),
            child: const RegisterScreen(),
          ),
        ),
      );

      // Verify register screen elements
      expect(find.text('Create Account'), findsOneWidget);
      expect(
        find.text('Sign up to start managing your finances'),
        findsOneWidget,
      );
      expect(
        find.byType(TextFormField),
        findsNWidgets(4),
      ); // Name, email, password, confirm password
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Already have an account? '), findsOneWidget);
    });

    testWidgets('Login form validation should work', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (context) => AuthProvider(),
            child: const LoginScreen(),
          ),
        ),
      );

      // Try to submit empty form
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Should show validation errors
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Register form validation should work', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (context) => AuthProvider(),
            child: const RegisterScreen(),
          ),
        ),
      );

      // Try to submit empty form
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      // Should show validation errors
      expect(find.text('Please enter your name'), findsOneWidget);
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter a password'), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);
    });

    testWidgets('Password visibility toggle should work', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (context) => AuthProvider(),
            child: const LoginScreen(),
          ),
        ),
      );

      // Find visibility toggle
      final visibilityToggle = find.byIcon(Icons.visibility);

      // Initially should show visibility icon (password is obscured)
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      // Tap visibility toggle
      await tester.tap(visibilityToggle);
      await tester.pump();

      // Should now show visibility_off icon (password is visible)
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('Email validation should work correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (context) => AuthProvider(),
            child: const LoginScreen(),
          ),
        ),
      );

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Should show email validation error
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('Password length validation should work', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (context) => AuthProvider(),
            child: const LoginScreen(),
          ),
        ),
      );

      // Enter valid email and short password
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), '123');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Should show password length validation error
      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });
  });
}
