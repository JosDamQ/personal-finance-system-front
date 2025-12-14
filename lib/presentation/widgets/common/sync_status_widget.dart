import 'package:flutter/material.dart';
import '../../../core/enums/app_enums.dart';
import '../../../data/services/offline_sync_service.dart';

/// Simple sync status widget for individual items
class SyncStatusWidget extends StatelessWidget {
  final SyncStatus status;
  final bool showText;

  const SyncStatusWidget({
    super.key,
    required this.status,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(), size: 12, color: _getStatusColor()),
          if (showText) ...[
            const SizedBox(width: 4),
            Text(
              _getStatusText(),
              style: TextStyle(
                color: _getStatusColor(),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (status) {
      case SyncStatus.synced:
        return Icons.cloud_done;
      case SyncStatus.pending:
        return Icons.cloud_queue;
      case SyncStatus.conflict:
        return Icons.sync_problem;
      case SyncStatus.error:
        return Icons.error_outline;
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case SyncStatus.synced:
        return Colors.green;
      case SyncStatus.pending:
        return Colors.orange;
      case SyncStatus.conflict:
        return Colors.red;
      case SyncStatus.error:
        return Colors.red;
    }
  }

  String _getStatusText() {
    switch (status) {
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.pending:
        return 'Pending';
      case SyncStatus.conflict:
        return 'Conflict';
      case SyncStatus.error:
        return 'Error';
    }
  }
}

/// Advanced sync status widget for overall sync management
class AdvancedSyncStatusWidget extends StatefulWidget {
  final String userId;
  final bool showDetails;
  final VoidCallback? onTap;

  const AdvancedSyncStatusWidget({
    super.key,
    required this.userId,
    this.showDetails = false,
    this.onTap,
  });

  @override
  State<AdvancedSyncStatusWidget> createState() =>
      _AdvancedSyncStatusWidgetState();
}

class _AdvancedSyncStatusWidgetState extends State<AdvancedSyncStatusWidget> {
  final OfflineSyncService _syncService = OfflineSyncService();
  SyncInfo? _syncInfo;

  @override
  void initState() {
    super.initState();
    _loadSyncInfo();

    // Listen to sync status updates
    _syncService.syncStatusStream.listen((_) {
      if (mounted) {
        _loadSyncInfo();
      }
    });

    // Listen to connectivity changes
    _syncService.connectivityStream.listen((_) {
      if (mounted) {
        _loadSyncInfo();
      }
    });
  }

  Future<void> _loadSyncInfo() async {
    final syncInfo = await _syncService.getSyncInfo(widget.userId);
    if (mounted) {
      setState(() {
        _syncInfo = syncInfo;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_syncInfo == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getStatusColor().withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getStatusColor().withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusIcon(),
            const SizedBox(width: 6),
            if (widget.showDetails) ...[
              Text(
                _getStatusText(),
                style: TextStyle(
                  color: _getStatusColor(),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else ...[
              Icon(_getStatusIcon(), size: 16, color: _getStatusColor()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (_syncInfo!.isSyncing) {
      return SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
        ),
      );
    }

    return Icon(_getStatusIcon(), size: 12, color: _getStatusColor());
  }

  IconData _getStatusIcon() {
    if (!_syncInfo!.isOnline) {
      return Icons.cloud_off;
    }

    if (_syncInfo!.isSyncing) {
      return Icons.sync;
    }

    if (_syncInfo!.failedCount > 0) {
      return Icons.sync_problem;
    }

    if (_syncInfo!.pendingCount > 0) {
      return Icons.cloud_queue;
    }

    return Icons.cloud_done;
  }

  Color _getStatusColor() {
    if (!_syncInfo!.isOnline) {
      return Colors.grey;
    }

    if (_syncInfo!.isSyncing) {
      return Colors.blue;
    }

    if (_syncInfo!.failedCount > 0) {
      return Colors.red;
    }

    if (_syncInfo!.pendingCount > 0) {
      return Colors.orange;
    }

    return Colors.green;
  }

  String _getStatusText() {
    if (!_syncInfo!.isOnline) {
      return 'Offline';
    }

    if (_syncInfo!.isSyncing) {
      return 'Syncing...';
    }

    if (_syncInfo!.failedCount > 0) {
      return 'Sync failed (${_syncInfo!.failedCount})';
    }

    if (_syncInfo!.pendingCount > 0) {
      return 'Pending (${_syncInfo!.pendingCount})';
    }

    return 'Synced';
  }
}

/// Detailed sync status widget for settings or debug screens
class DetailedSyncStatusWidget extends StatefulWidget {
  final String userId;

  const DetailedSyncStatusWidget({super.key, required this.userId});

  @override
  State<DetailedSyncStatusWidget> createState() =>
      _DetailedSyncStatusWidgetState();
}

class _DetailedSyncStatusWidgetState extends State<DetailedSyncStatusWidget> {
  final OfflineSyncService _syncService = OfflineSyncService();
  SyncInfo? _syncInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSyncInfo();

    // Listen to sync status updates
    _syncService.syncStatusStream.listen((_) {
      if (mounted) {
        _loadSyncInfo();
      }
    });
  }

  Future<void> _loadSyncInfo() async {
    final syncInfo = await _syncService.getSyncInfo(widget.userId);
    if (mounted) {
      setState(() {
        _syncInfo = syncInfo;
      });
    }
  }

  Future<void> _forceSync() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _syncService.forceSync(widget.userId);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _retryFailed() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _syncService.retryFailedItems(widget.userId);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_syncInfo == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _syncInfo!.isOnline ? Icons.cloud_done : Icons.cloud_off,
                  color: _syncInfo!.isOnline ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sync Status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusRow(
              'Connection',
              _syncInfo!.isOnline ? 'Online' : 'Offline',
            ),
            _buildStatusRow('Syncing', _syncInfo!.isSyncing ? 'Yes' : 'No'),
            _buildStatusRow('Pending Items', '${_syncInfo!.pendingCount}'),
            _buildStatusRow('Failed Items', '${_syncInfo!.failedCount}'),
            if (_syncInfo!.lastSyncAttempt != null)
              _buildStatusRow(
                'Last Sync',
                _formatDateTime(_syncInfo!.lastSyncAttempt!),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _forceSync,
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Force Sync'),
                ),
                const SizedBox(width: 8),
                if (_syncInfo!.failedCount > 0)
                  ElevatedButton(
                    onPressed: _isLoading ? null : _retryFailed,
                    child: const Text('Retry Failed'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
