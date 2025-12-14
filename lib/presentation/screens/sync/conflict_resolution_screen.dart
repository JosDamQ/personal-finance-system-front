import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/enums/app_enums.dart';
import '../../../data/services/offline_sync_service.dart';
import '../../../data/services/conflict_resolution_service.dart';
import '../../providers/sync_provider.dart';

class ConflictResolutionScreen extends StatefulWidget {
  const ConflictResolutionScreen({super.key});

  @override
  State<ConflictResolutionScreen> createState() =>
      _ConflictResolutionScreenState();
}

class _ConflictResolutionScreenState extends State<ConflictResolutionScreen> {
  final ConflictResolutionService _conflictService =
      ConflictResolutionService();
  List<ConflictItem> _conflicts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConflicts();
  }

  Future<void> _loadConflicts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // final syncProvider = Provider.of<SyncProvider>(context, listen: false);
      // Note: This would need to be implemented in the sync service
      // For now, we'll show an empty list
      _conflicts = [];
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load conflicts: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resolveConflict(ConflictItem conflict) async {
    final resolution = await _conflictService.showConflictDialog(
      context: context,
      conflict: conflict,
    );

    if (resolution != null) {
      try {
        final syncProvider = Provider.of<SyncProvider>(context, listen: false);
        await syncProvider.resolveConflict(
          conflictId: conflict.id,
          resolution: resolution,
        );

        // Reload conflicts
        await _loadConflicts();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conflict resolved successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to resolve conflict: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resolve Conflicts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConflicts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _conflicts.isEmpty
          ? _buildEmptyState()
          : _buildConflictsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: Colors.green[300]),
          const SizedBox(height: 16),
          Text(
            'No Conflicts',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'All your data is synchronized without conflicts.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConflictsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _conflicts.length,
      itemBuilder: (context, index) {
        final conflict = _conflicts[index];
        return _buildConflictCard(conflict);
      },
    );
  }

  Widget _buildConflictCard(ConflictItem conflict) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getEntityIcon(conflict.entityType), color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _conflictService.getConflictDescription(conflict),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Reason: ${conflict.conflictReason}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _showConflictDetails(conflict),
                  child: const Text('View Details'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _resolveConflict(conflict),
                  child: const Text('Resolve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getEntityIcon(EntityType entityType) {
    switch (entityType) {
      case EntityType.expense:
        return Icons.receipt;
      case EntityType.budget:
        return Icons.account_balance_wallet;
      case EntityType.creditCard:
        return Icons.credit_card;
      case EntityType.category:
        return Icons.category;
      case EntityType.budgetPeriod:
        return Icons.date_range;
    }
  }

  void _showConflictDetails(ConflictItem conflict) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conflict Details'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Entity: ${conflict.entityType.value}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'Operation: ${conflict.operation.value}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'ID: ${conflict.entityId}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Local Data:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                conflict.localData.toString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Server Data:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                conflict.serverData.toString(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
