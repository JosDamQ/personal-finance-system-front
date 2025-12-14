import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to handle network connectivity detection
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  bool _isOnline = false;
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  ConnectivityService._internal();

  factory ConnectivityService() => _instance;

  /// Stream to listen for connectivity changes
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Current connectivity status
  bool get isOnline => _isOnline;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    await _checkInitialConnectivity();
    _startConnectivityMonitoring();
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
  }

  /// Check initial connectivity status
  Future<void> _checkInitialConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    _updateConnectivityStatus(connectivityResult);
  }

  /// Start monitoring connectivity changes
  void _startConnectivityMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectivityStatus,
    );
  }

  /// Update connectivity status
  void _updateConnectivityStatus(ConnectivityResult result) {
    final wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;

    // Only emit if status changed
    if (wasOnline != _isOnline) {
      _connectivityController.add(_isOnline);
    }
  }

  /// Check connectivity status once
  Future<bool> checkConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Get detailed connectivity information
  Future<ConnectivityInfo> getConnectivityInfo() async {
    final result = await _connectivity.checkConnectivity();

    return ConnectivityInfo(
      isConnected: result != ConnectivityResult.none,
      connectionTypes: [result],
      hasWifi: result == ConnectivityResult.wifi,
      hasMobile: result == ConnectivityResult.mobile,
      hasEthernet: result == ConnectivityResult.ethernet,
    );
  }
}

/// Detailed connectivity information
class ConnectivityInfo {
  final bool isConnected;
  final List<ConnectivityResult> connectionTypes;
  final bool hasWifi;
  final bool hasMobile;
  final bool hasEthernet;

  ConnectivityInfo({
    required this.isConnected,
    required this.connectionTypes,
    required this.hasWifi,
    required this.hasMobile,
    required this.hasEthernet,
  });

  @override
  String toString() {
    if (!isConnected) return 'No connection';

    final types = <String>[];
    if (hasWifi) types.add('WiFi');
    if (hasMobile) types.add('Mobile');
    if (hasEthernet) types.add('Ethernet');

    return 'Connected via ${types.join(', ')}';
  }
}
