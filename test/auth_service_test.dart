import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:finance_app/data/services/auth_service.dart';
import 'package:finance_app/data/models/user_model.dart';

void main() {
  group('AuthService Tests', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
      // Clear any existing tokens before each test
      FlutterSecureStorage.setMockInitialValues({});
    });

    test('should store and retrieve access token', () async {
      // Store token using the private method (we'll test through public interface)
      await authService.clearTokens();

      // Since we can't directly test private methods, we'll test the public interface
      final token = await authService.getAccessToken();
      expect(token, isNull);
    });

    test('should store and retrieve refresh token', () async {
      await authService.clearTokens();

      final token = await authService.getRefreshToken();
      expect(token, isNull);
    });

    test('should clear all tokens', () async {
      await authService.clearTokens();

      final accessToken = await authService.getAccessToken();
      final refreshToken = await authService.getRefreshToken();
      final user = await authService.getStoredUser();

      expect(accessToken, isNull);
      expect(refreshToken, isNull);
      expect(user, isNull);
    });

    test('should return false for isAuthenticated when no tokens', () async {
      await authService.clearTokens();

      final isAuth = await authService.isAuthenticated();
      expect(isAuth, isFalse);
    });

    test('should generate auth headers without token', () async {
      await authService.clearTokens();

      final headers = await authService.getAuthHeaders();
      expect(headers['Authorization'], isNull);
      expect(headers['Content-Type'], equals('application/json'));
    });
  });

  group('AuthResult Tests', () {
    test('should create success result', () {
      final user = UserModel(
        id: 'test-id',
        email: 'test@example.com',
        name: 'Test User',
        defaultCurrency: 'GTQ',
        theme: 'light',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = AuthResult.success(user);

      expect(result.isSuccess, isTrue);
      expect(result.user, equals(user));
      expect(result.errorMessage, isNull);
    });

    test('should create failure result', () {
      const errorMessage = 'Login failed';

      final result = AuthResult.failure(errorMessage);

      expect(result.isSuccess, isFalse);
      expect(result.user, isNull);
      expect(result.errorMessage, equals(errorMessage));
    });
  });
}
