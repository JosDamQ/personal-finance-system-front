abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, {this.code});
  
  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;
  
  const ValidationException(super.message, {super.code, this.fieldErrors});
}

class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code});
}

class SyncException extends AppException {
  const SyncException(super.message, {super.code});
}

class ServerException extends AppException {
  final int? statusCode;
  
  const ServerException(super.message, {super.code, this.statusCode});
}

class CacheException extends AppException {
  const CacheException(super.message, {super.code});
}

class UnknownException extends AppException {
  const UnknownException(super.message, {super.code});
}