import 'package:flutter_test/flutter_test.dart';
import 'package:finance_app/data/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    test('should create UserModel from backend auth response', () {
      // Backend auth response format (minimal data)
      final backendResponse = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'email': 'test@example.com',
        'name': 'Test User',
      };

      final user = UserModel.fromJson(backendResponse);

      expect(user.id, equals('123e4567-e89b-12d3-a456-426614174000'));
      expect(user.email, equals('test@example.com'));
      expect(user.name, equals('Test User'));
      expect(user.defaultCurrency, equals('GTQ')); // Default value
      expect(user.theme, equals('light')); // Default value
      expect(user.phone, isNull);
      expect(user.oauthProvider, isNull);
      expect(user.oauthId, isNull);
    });

    test('should create UserModel from full user data', () {
      // Full user data format
      final fullUserData = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'email': 'test@example.com',
        'name': 'Test User',
        'phone': '+1234567890',
        'oauthProvider': null,
        'oauthId': null,
        'defaultCurrency': 'USD',
        'theme': 'dark',
        'createdAt': '2023-01-01T00:00:00.000Z',
        'updatedAt': '2023-01-01T00:00:00.000Z',
      };

      final user = UserModel.fromJson(fullUserData);

      expect(user.id, equals('123e4567-e89b-12d3-a456-426614174000'));
      expect(user.email, equals('test@example.com'));
      expect(user.name, equals('Test User'));
      expect(user.phone, equals('+1234567890'));
      expect(user.defaultCurrency, equals('USD'));
      expect(user.theme, equals('dark'));
    });

    test('should handle null name in backend response', () {
      final backendResponse = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'email': 'test@example.com',
        'name': null,
      };

      final user = UserModel.fromJson(backendResponse);

      expect(user.id, equals('123e4567-e89b-12d3-a456-426614174000'));
      expect(user.email, equals('test@example.com'));
      expect(user.name, isNull);
      expect(user.defaultCurrency, equals('GTQ'));
      expect(user.theme, equals('light'));
    });

    test('should serialize to JSON correctly', () {
      final user = UserModel(
        id: '123e4567-e89b-12d3-a456-426614174000',
        email: 'test@example.com',
        name: 'Test User',
        defaultCurrency: 'GTQ',
        theme: 'light',
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      final json = user.toJson();

      expect(json['id'], equals('123e4567-e89b-12d3-a456-426614174000'));
      expect(json['email'], equals('test@example.com'));
      expect(json['name'], equals('Test User'));
      expect(json['defaultCurrency'], equals('GTQ'));
      expect(json['theme'], equals('light'));
    });
  });
}
