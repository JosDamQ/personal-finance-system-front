class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://localhost:3000/api/v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Database Configuration
  static const String databaseName = 'personal_finance.db';
  static const int databaseVersion = 1;
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String themeKey = 'theme_preference';
  static const String currencyKey = 'default_currency';
  
  // Sync Configuration
  static const Duration syncInterval = Duration(minutes: 5);
  static const int maxRetryAttempts = 3;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // Validation
  static const int maxDescriptionLength = 255;
  static const double maxAmount = 999999999.99;
  static const double minAmount = 0.01;
}