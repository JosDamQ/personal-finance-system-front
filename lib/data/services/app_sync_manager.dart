import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/sync_provider.dart';
import 'database_service.dart';

/// Manages app-level synchronization coordination
class AppSyncManager {
  static final AppSyncManager _instance = AppSyncManager._internal();

  AppSyncManager._internal();

  factory AppSyncManager() => _instance;

  /// Initialize sync for the app
  static Future<void> initialize(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final syncProvider = Provider.of<SyncProvider>(context, listen: false);

    // Listen to auth state changes
    authProvider.addListener(() {
      _handleAuthStateChange(authProvider, syncProvider);
    });

    // If user is already authenticated, initialize sync
    if (authProvider.isAuthenticated && authProvider.currentUser != null) {
      await _initializeSyncForUser(authProvider.currentUser!.id, syncProvider);
    }
  }

  /// Handle authentication state changes
  static void _handleAuthStateChange(
    AuthProvider authProvider,
    SyncProvider syncProvider,
  ) {
    if (authProvider.isAuthenticated && authProvider.currentUser != null) {
      // User logged in - initialize sync
      _initializeSyncForUser(authProvider.currentUser!.id, syncProvider);
    } else {
      // User logged out - cleanup sync
      _cleanupSync(syncProvider);
    }
  }

  /// Initialize sync for a specific user
  static Future<void> _initializeSyncForUser(
    String userId,
    SyncProvider syncProvider,
  ) async {
    try {
      // Initialize database defaults for user
      final databaseService = DatabaseService();
      await databaseService.initializeUserDefaults(userId);

      // Initialize sync provider
      await syncProvider.initialize(userId);
    } catch (e) {
      debugPrint('Failed to initialize sync for user $userId: $e');
    }
  }

  /// Cleanup sync when user logs out
  static void _cleanupSync(SyncProvider syncProvider) {
    // The sync provider will handle cleanup in its dispose method
    // We don't need to do anything special here
  }
}

/// Widget that initializes sync management
class SyncManagerWidget extends StatefulWidget {
  final Widget child;

  const SyncManagerWidget({super.key, required this.child});

  @override
  State<SyncManagerWidget> createState() => _SyncManagerWidgetState();
}

class _SyncManagerWidgetState extends State<SyncManagerWidget> {
  @override
  void initState() {
    super.initState();

    // Initialize sync manager after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppSyncManager.initialize(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
