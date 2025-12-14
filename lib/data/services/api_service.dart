import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import 'auth_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final AuthService _authService = AuthService();
  static const String _baseUrl = AppConstants.apiBaseUrl;
  static const Duration _timeout = AppConstants.apiTimeout;
  static const int _maxRetries = AppConstants.maxRetryAttempts;

  /// Make authenticated GET request
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    return await _makeRequest('GET', endpoint, headers: headers);
  }

  /// Make authenticated POST request
  Future<http.Response> post(
    String endpoint, {
    Map<String, String>? headers,
    String? body,
  }) async {
    return await _makeRequest('POST', endpoint, headers: headers, body: body);
  }

  /// Make authenticated PUT request
  Future<http.Response> put(
    String endpoint, {
    Map<String, String>? headers,
    String? body,
  }) async {
    return await _makeRequest('PUT', endpoint, headers: headers, body: body);
  }

  /// Make authenticated DELETE request
  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
    String? body,
  }) async {
    return await _makeRequest('DELETE', endpoint, headers: headers, body: body);
  }

  /// Make authenticated request with automatic token refresh and retry logic
  Future<http.Response> _makeRequest(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    String? body,
  }) async {
    final url = '$_baseUrl$endpoint';

    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        final authHeaders = await _authService.getAuthHeaders();
        final allHeaders = {
          'Content-Type': 'application/json',
          ...authHeaders,
          ...?headers,
        };

        http.Response response = await _executeRequest(
          method,
          url,
          allHeaders,
          body,
        ).timeout(_timeout);

        // If token expired, try to refresh and retry once
        if (response.statusCode == 401 && attempt == 0) {
          final refreshed = await _authService.refreshToken();
          if (refreshed) {
            continue; // Retry with new token
          } else {
            throw ApiException(
              statusCode: 401,
              message: 'Authentication failed',
              details: {'reason': 'token_refresh_failed'},
            );
          }
        }

        // If successful or client error (4xx), return response
        if (response.statusCode < 500) {
          return response;
        }

        // Server error (5xx) - retry if not last attempt
        if (attempt == _maxRetries - 1) {
          return response;
        }

        // Wait before retry with exponential backoff
        await Future.delayed(Duration(milliseconds: 1000 * (attempt + 1)));
      } on TimeoutException {
        if (attempt == _maxRetries - 1) {
          throw ApiException(
            statusCode: 408,
            message: 'Request timeout',
            details: {'timeout': _timeout.inSeconds},
          );
        }
        await Future.delayed(Duration(milliseconds: 1000 * (attempt + 1)));
      } on SocketException {
        if (attempt == _maxRetries - 1) {
          throw ApiException(
            statusCode: 0,
            message: 'No internet connection',
            details: {'reason': 'network_error'},
          );
        }
        await Future.delayed(Duration(milliseconds: 1000 * (attempt + 1)));
      } catch (e) {
        if (attempt == _maxRetries - 1) {
          throw ApiException(
            statusCode: 0,
            message: 'Request failed: ${e.toString()}',
            details: {'error': e.toString()},
          );
        }
        await Future.delayed(Duration(milliseconds: 1000 * (attempt + 1)));
      }
    }

    throw ApiException(
      statusCode: 0,
      message: 'Max retries exceeded',
      details: {'maxRetries': _maxRetries},
    );
  }

  /// Execute HTTP request based on method
  Future<http.Response> _executeRequest(
    String method,
    String url,
    Map<String, String> headers,
    String? body,
  ) async {
    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(Uri.parse(url), headers: headers);
      case 'POST':
        return await http.post(Uri.parse(url), headers: headers, body: body);
      case 'PUT':
        return await http.put(Uri.parse(url), headers: headers, body: body);
      case 'DELETE':
        return await http.delete(Uri.parse(url), headers: headers, body: body);
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }
  }

  /// Parse JSON response with error handling
  Map<String, dynamic> parseResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        statusCode: response.statusCode,
        message: error['error']['message'] ?? 'Request failed',
        details: error,
      );
    }
  }

  /// Parse JSON response and return data field
  T parseDataResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final data = parseResponse(response);
    return fromJson(data['data']);
  }

  /// Parse JSON response and return list of data
  List<T> parseListResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final data = parseResponse(response);
    final List<dynamic> items = data['data'];
    return items.map((item) => fromJson(item)).toList();
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? details;

  ApiException({required this.statusCode, required this.message, this.details});

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode)';
  }
}
