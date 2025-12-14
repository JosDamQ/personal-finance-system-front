import 'package:flutter/foundation.dart';
import '../../core/enums/app_enums.dart';
import '../../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
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
      
      // TODO: Implement actual login logic with API call
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      // Mock user for now
      _currentUser = UserModel(
        id: 'user-123',
        email: email,
        name: 'Test User',
        defaultCurrency: 'GTQ',
        theme: 'light',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      _isAuthenticated = true;
      _setLoadingState(LoadingState.loaded);
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
    }
  }

  Future<void> register(String email, String password, String name) async {
    try {
      _setLoadingState(LoadingState.loading);
      
      // TODO: Implement actual registration logic with API call
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      // Mock user for now
      _currentUser = UserModel(
        id: 'user-123',
        email: email,
        name: name,
        defaultCurrency: 'GTQ',
        theme: 'light',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      _isAuthenticated = true;
      _setLoadingState(LoadingState.loaded);
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      _setLoadingState(LoadingState.loading);
      
      // TODO: Implement actual logout logic (clear tokens, etc.)
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
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
      
      // TODO: Check if user has valid tokens stored locally
      await Future.delayed(const Duration(seconds: 1)); // Simulate check
      
      // For now, assume not authenticated
      _isAuthenticated = false;
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
}