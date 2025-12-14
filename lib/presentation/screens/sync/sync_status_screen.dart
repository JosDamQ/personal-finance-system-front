import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/enums/app_enums.dart';
import '../../providers/sync_provider.dart';

import 'conflict_resolution_screen.dart';

class SyncStatusScreen extends StatefulWidget {
  const SyncStatusScreen({super.key});

  @override
  State<SyncStatusScreen> createState() => _SyncStatusScreenState();
}

class _SyncStatusScreenState extends State<SyncStatusScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Status'),
        actions: [
          Consumer<SyncProvider>(
            builder: (context, syncProvider, child) {
              return IconButton(
                icon: syncProvider.isSyncing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
                onPressed: syncProvider.isSyncing ? null : () => _forceSync(),
              );
            },
          ),
        ],
      ),
      body: Consumer<SyncProvider>(
        builder: (context, syncProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildConnectionStatus(syncProvider),
                const SizedBox(height: 16),
                _buildSyncOverview(syncProvider),
                const SizedBox(height: 16),
                _buildSyncDetails(syncProvider),
                const SizedBox(height: 16),
                _buildActions(syncProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildConnectionStatus(SyncProvider syncProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              syncProvider.isOnline ? Icons.cloud_done : Icons.cloud_off,
              color: syncProvider.isOnline ? Colors.green : Colors.grey,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connection Status',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    syncProvider.isOnline ? 'Online' : 'Offline',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: syncProvider.isOnline ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncOverview(SyncProvider syncProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sync Overview',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatusIndicator(
                    'Synced',
                    syncProvider.syncStatus == SyncStatus.synced &&
                        !syncProvider.hasPendingItems &&
                        !syncProvider.hasIssues,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatusIndicator(
                    'Pending',
                    syncProvider.hasPendingItems,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatusIndicator(
                    'Issues',
                    syncProvider.hasIssues,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              syncProvider.syncMessage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String label, bool isActive, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? color : Colors.grey[300],
          ),
          child: Icon(
            isActive ? Icons.check : Icons.circle,
            color: isActive ? Colors.white : Colors.grey[600],
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? color : Colors.grey[600],
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildSyncDetails(SyncProvider syncProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sync Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Status',
              _getSyncStatusText(syncProvider.syncStatus),
            ),
            _buildDetailRow('Pending Items', '${syncProvider.pendingCount}'),
            _buildDetailRow('Failed Items', '${syncProvider.failedCount}'),
            _buildDetailRow('Conflicts', '${syncProvider.conflictCount}'),
            _buildDetailRow(
              'Currently Syncing',
              syncProvider.isSyncing ? 'Yes' : 'No',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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

  Widget _buildActions(SyncProvider syncProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Actions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: syncProvider.isSyncing ? null : _forceSync,
                icon: syncProvider.isSyncing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
                label: Text(
                  syncProvider.isSyncing ? 'Syncing...' : 'Force Sync',
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (syncProvider.failedCount > 0)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: syncProvider.isSyncing ? null : _retryFailed,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Failed Items'),
                ),
              ),
            const SizedBox(height: 8),
            if (syncProvider.conflictCount > 0)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _resolveConflicts,
                  icon: const Icon(Icons.merge_type),
                  label: const Text('Resolve Conflicts'),
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _clearSyncData,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Sync Data'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSyncStatusText(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.pending:
        return 'Pending';
      case SyncStatus.conflict:
        return 'Conflicts';
      case SyncStatus.error:
        return 'Error';
    }
  }

  Future<void> _forceSync() async {
    final syncProvider = Provider.of<SyncProvider>(context, listen: false);

    try {
      final result = await syncProvider.forceSync();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: result.success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _retryFailed() async {
    final syncProvider = Provider.of<SyncProvider>(context, listen: false);

    try {
      await syncProvider.retryFailedItems();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Retrying failed items...'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to retry: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resolveConflicts() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ConflictResolutionScreen()),
    );
  }

  Future<void> _clearSyncData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Sync Data'),
        content: const Text(
          'This will clear all pending sync operations. '
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final syncProvider = Provider.of<SyncProvider>(context, listen: false);

      try {
        await syncProvider.clearSyncData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sync data cleared'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to clear sync data: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
