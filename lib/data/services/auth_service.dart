import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  // API endpoints
  static const String _baseUrl = AppConstants.apiBaseUrl;
  static const String _loginEndpoint = '$_baseUrl/auth/login';
  static const String _registerEndpoint = '$_baseUrl/auth/register';
  static const String _refreshEndpoint = '$_baseUrl/auth/refresh';
  static const String _logoutEndpoint = '$_baseUrl/auth/logout';

  /// Login with email and password
  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = responseData['data'];

        // Store tokens securely
        await _storage.write(key: _accessTokenKey, value: data['accessToken']);
        await _storage.write(
          key: _refreshTokenKey,
          value: data['refreshToken'],
        );

        // Create and store user model
        final user = UserModel.fromJson(data['user']);
        await _storage.write(
          key: _userDataKey,
          value: jsonEncode(user.toJson()),
        );

        return AuthResult.success(user);
      } else {
        final error = jsonDecode(response.body);
        return AuthResult.failure(error['error']['message'] ?? 'Login failed');
      }
    } catch (e) {
      return AuthResult.failure('Network error: ${e.toString()}');
    }
  }

  /// Register new user
  Future<AuthResult> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(_registerEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'name': name}),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final data = responseData['data'];

        // Store tokens securely
        await _storage.write(key: _accessTokenKey, value: data['accessToken']);
        await _storage.write(
          key: _refreshTokenKey,
          value: data['refreshToken'],
        );

        // Create and store user model
        final user = UserModel.fromJson(data['user']);
        await _storage.write(
          key: _userDataKey,
          value: jsonEncode(user.toJson()),
        );

        return AuthResult.success(user);
      } else {
        final error = jsonDecode(response.body);
        return AuthResult.failure(
          error['error']['message'] ?? 'Registration failed',
        );
      }
    } catch (e) {
      return AuthResult.failure('Network error: ${e.toString()}');
    }
  }

  /// Refresh access token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse(_refreshEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = responseData['data'];
        await _storage.write(key: _accessTokenKey, value: data['accessToken']);
        return true;
      } else {
        // Refresh token is invalid, clear all tokens
        await clearTokens();
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken != null) {
        // Call logout endpoint to invalidate refresh token on server
        await http.post(
          Uri.parse(_logoutEndpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${await getAccessToken()}',
          },
          body: jsonEncode({'refreshToken': refreshToken}),
        );
      }
    } catch (e) {
      // Even if logout fails on server, clear local tokens
    } finally {
      await clearTokens();
    }
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Get stored refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Get stored user data
  Future<UserModel?> getStoredUser() async {
    try {
      final userData = await _storage.read(key: _userDataKey);
      if (userData != null) {
        final userJson = jsonDecode(userData);
        return UserModel.fromJson(userJson);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if user is authenticated (has valid tokens)
  Future<bool> isAuthenticated() async {
    final accessToken = await getAccessToken();
    final refreshTokenValue = await getRefreshToken();

    if (accessToken == null || refreshTokenValue == null) {
      return false;
    }

    // Try to refresh token to verify it's still valid
    return await refreshToken();
  }

  /// Clear all stored tokens and user data
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userDataKey);
  }

  /// Get authorization header for API requests
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getAccessToken();
    if (token != null) {
      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
    }
    return {'Content-Type': 'application/json'};
  }

  /// Make authenticated HTTP request with automatic token refresh
  Future<http.Response> authenticatedRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    String? body,
  }) async {
    final authHeaders = await getAuthHeaders();
    final allHeaders = {...authHeaders, ...?headers};

    http.Response response;

    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(Uri.parse(url), headers: allHeaders);
        break;
      case 'POST':
        response = await http.post(
          Uri.parse(url),
          headers: allHeaders,
          body: body,
        );
        break;
      case 'PUT':
        response = await http.put(
          Uri.parse(url),
          headers: allHeaders,
          body: body,
        );
        break;
      case 'DELETE':
        response = await http.delete(Uri.parse(url), headers: allHeaders);
        break;
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }

    // If token expired, try to refresh and retry once
    if (response.statusCode == 401) {
      final refreshed = await refreshToken();
      if (refreshed) {
        final newAuthHeaders = await getAuthHeaders();
        final newAllHeaders = {...newAuthHeaders, ...?headers};

        switch (method.toUpperCase()) {
          case 'GET':
            response = await http.get(Uri.parse(url), headers: newAllHeaders);
            break;
          case 'POST':
            response = await http.post(
              Uri.parse(url),
              headers: newAllHeaders,
              body: body,
            );
            break;
          case 'PUT':
            response = await http.put(
              Uri.parse(url),
              headers: newAllHeaders,
              body: body,
            );
            break;
          case 'DELETE':
            response = await http.delete(
              Uri.parse(url),
              headers: newAllHeaders,
            );
            break;
        }
      }
    }

    return response;
  }
}

/// Result class for authentication operations
class AuthResult {
  final bool isSuccess;
  final UserModel? user;
  final String? errorMessage;

  AuthResult._({required this.isSuccess, this.user, this.errorMessage});

  factory AuthResult.success(UserModel user) {
    return AuthResult._(isSuccess: true, user: user);
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(isSuccess: false, errorMessage: message);
  }
}
