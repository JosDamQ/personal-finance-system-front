import 'package:flutter/foundation.dart';
import '../../core/enums/app_enums.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  LoadingState _loadingState = LoadingState.initial;
  String? _errorMessage;
  bool _isAuthenticated = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  LoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _loadingState == LoadingState.loading;

  // Authentication methods
  Future<void> login(String email, String password) async {
    try {
      _setLoadingState(LoadingState.loading);

      final result = await _authService.login(email, password);

      if (result.isSuccess && result.user != null) {
        _currentUser = result.user;
        _isAuthenticated = true;
        _setLoadingState(LoadingState.loaded);
      } else {
        _setError(result.errorMessage ?? 'Login failed');
      }
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
    }
  }

  Future<void> register(String email, String password, String name) async {
    try {
      _setLoadingState(LoadingState.loading);

      final result = await _authService.register(email, password, name);

      if (result.isSuccess && result.user != null) {
        _currentUser = result.user;
        _isAuthenticated = true;
        _setLoadingState(LoadingState.loaded);
      } else {
        _setError(result.errorMessage ?? 'Registration failed');
      }
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      _setLoadingState(LoadingState.loading);

      await _authService.logout();

      _currentUser = null;
      _isAuthenticated = false;
      _setLoadingState(LoadingState.initial);
    } catch (e) {
      _setError('Logout failed: ${e.toString()}');
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      _setLoadingState(LoadingState.loading);

      final isAuth = await _authService.isAuthenticated();

      if (isAuth) {
        final user = await _authService.getStoredUser();
        if (user != null) {
          _currentUser = user;
          _isAuthenticated = true;
        } else {
          _isAuthenticated = false;
        }
      } else {
        _isAuthenticated = false;
      }

      _setLoadingState(LoadingState.loaded);
    } catch (e) {
      _setError('Auth check failed: ${e.toString()}');
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    try {
      _setLoadingState(LoadingState.loading);

      // TODO: Implement actual profile update logic with API call
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      _currentUser = updatedUser;
      _setLoadingState(LoadingState.loaded);
    } catch (e) {
      _setError('Profile update failed: ${e.toString()}');
    }
  }

  // Helper methods
  void _setLoadingState(LoadingState state) {
    _loadingState = state;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _loadingState = LoadingState.error;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_loadingState == LoadingState.error) {
      _loadingState = LoadingState.initial;
    }
    notifyListeners();
  }

  // Get AuthService instance for other services to use
  AuthService get authService => _authService;
}
