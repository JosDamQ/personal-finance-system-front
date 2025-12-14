import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_app/presentation/screens/categories/category_list_screen.dart';
import 'package:finance_app/presentation/screens/categories/category_form_screen.dart';

void main() {
  group('Category Screens Tests', () {
    testWidgets('CategoryListScreen should build without errors', (
      WidgetTester tester,
    ) async {
      // Build the CategoryListScreen widget
      await tester.pumpWidget(MaterialApp(home: const CategoryListScreen()));

      // Verify that the screen builds without errors
      expect(find.byType(CategoryListScreen), findsOneWidget);
      expect(find.text('Categories'), findsOneWidget);
    });

    testWidgets(
      'CategoryFormScreen should build without errors for new category',
      (WidgetTester tester) async {
        // Build the CategoryFormScreen widget for new category
        await tester.pumpWidget(MaterialApp(home: const CategoryFormScreen()));

        // Verify that the screen builds without errors
        expect(find.byType(CategoryFormScreen), findsOneWidget);
        expect(find.text('Add Category'), findsOneWidget);
      },
    );

    testWidgets('CategoryFormScreen should build without errors for editing', (
      WidgetTester tester,
    ) async {
      // Build the CategoryFormScreen widget for editing
      await tester.pumpWidget(
        MaterialApp(home: const CategoryFormScreen(categoryId: 'test-id')),
      );

      // Verify that the screen builds without errors
      expect(find.byType(CategoryFormScreen), findsOneWidget);
      expect(find.text('Edit Category'), findsOneWidget);
    });

    testWidgets('CategoryFormScreen form elements should be present', (
      WidgetTester tester,
    ) async {
      // Build the CategoryFormScreen widget
      await tester.pumpWidget(MaterialApp(home: const CategoryFormScreen()));

      // Verify form elements are present
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Color'), findsOneWidget);
      expect(find.text('Icon'), findsOneWidget);
      expect(find.text('Create Category'), findsOneWidget);
    });

    testWidgets('CategoryFormScreen should have color selection', (
      WidgetTester tester,
    ) async {
      // Build the CategoryFormScreen widget
      await tester.pumpWidget(MaterialApp(home: const CategoryFormScreen()));

      // Verify color selection is present
      expect(find.text('Color'), findsOneWidget);

      // Should have multiple color options (containers for color selection)
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('CategoryFormScreen should have icon selection', (
      WidgetTester tester,
    ) async {
      // Build the CategoryFormScreen widget
      await tester.pumpWidget(MaterialApp(home: const CategoryFormScreen()));

      // Verify icon selection is present
      expect(find.text('Icon'), findsOneWidget);

      // Should have a grid view for icon selection
      expect(find.byType(GridView), findsOneWidget);
    });
  });
}
