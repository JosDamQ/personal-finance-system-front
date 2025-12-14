import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/enums/app_enums.dart';
import 'offline_sync_service.dart';

/// Service to handle conflict resolution in the UI
class ConflictResolutionService {
  static final ConflictResolutionService _instance =
      ConflictResolutionService._internal();

  final OfflineSyncService _syncService = OfflineSyncService();

  ConflictResolutionService._internal();

  factory ConflictResolutionService() => _instance;

  /// Show conflict resolution dialog
  Future<ConflictResolution?> showConflictDialog({
    required BuildContext context,
    required ConflictItem conflict,
  }) async {
    return await showDialog<ConflictResolution>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConflictResolutionDialog(conflict: conflict),
    );
  }

  /// Resolve conflict with user choice
  Future<void> resolveConflict({
    required ConflictItem conflict,
    required ConflictResolution resolution,
    Map<String, dynamic>? mergedData,
  }) async {
    await _syncService.resolveConflict(
      conflictId: conflict.id,
      resolution: resolution,
      mergedData: mergedData,
    );
  }

  /// Get user-friendly conflict description
  String getConflictDescription(ConflictItem conflict) {
    final entityName = _getEntityDisplayName(conflict.entityType);
    final operationName = _getOperationDisplayName(conflict.operation);

    return 'Conflict in $operationName $entityName: ${conflict.conflictReason}';
  }

  /// Get differences between local and server data
  Map<String, ConflictDifference> getDataDifferences(ConflictItem conflict) {
    final differences = <String, ConflictDifference>{};
    final localData = conflict.localData;
    final serverData = conflict.serverData;

    // Get all unique keys from both datasets
    final allKeys = <String>{...localData.keys, ...serverData.keys};

    for (final key in allKeys) {
      final localValue = localData[key];
      final serverValue = serverData[key];

      if (localValue != serverValue) {
        differences[key] = ConflictDifference(
          field: key,
          localValue: localValue,
          serverValue: serverValue,
        );
      }
    }

    return differences;
  }

  String _getEntityDisplayName(EntityType entityType) {
    switch (entityType) {
      case EntityType.expense:
        return 'Expense';
      case EntityType.budget:
        return 'Budget';
      case EntityType.creditCard:
        return 'Credit Card';
      case EntityType.category:
        return 'Category';
      case EntityType.budgetPeriod:
        return 'Budget Period';
    }
  }

  String _getOperationDisplayName(SyncOperation operation) {
    switch (operation) {
      case SyncOperation.create:
        return 'creating';
      case SyncOperation.update:
        return 'updating';
      case SyncOperation.delete:
        return 'deleting';
    }
  }
}

/// Represents a difference between local and server data
class ConflictDifference {
  final String field;
  final dynamic localValue;
  final dynamic serverValue;

  ConflictDifference({
    required this.field,
    required this.localValue,
    required this.serverValue,
  });
}

/// Dialog widget for conflict resolution
class ConflictResolutionDialog extends StatefulWidget {
  final ConflictItem conflict;

  const ConflictResolutionDialog({super.key, required this.conflict});

  @override
  State<ConflictResolutionDialog> createState() =>
      _ConflictResolutionDialogState();
}

class _ConflictResolutionDialogState extends State<ConflictResolutionDialog> {
  final ConflictResolutionService _conflictService =
      ConflictResolutionService();

  @override
  Widget build(BuildContext context) {
    final differences = _conflictService.getDataDifferences(widget.conflict);

    return AlertDialog(
      title: const Text('Data Conflict Detected'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _conflictService.getConflictDescription(widget.conflict),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (differences.isNotEmpty) ...[
              Text(
                'Differences:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: differences.length,
                  itemBuilder: (context, index) {
                    final entry = differences.entries.elementAt(index);
                    final diff = entry.value;

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              diff.field,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Local:',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                      Text(
                                        '${diff.localValue}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Server:',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                      Text(
                                        '${diff.serverValue}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(ConflictResolution.useLocal),
          child: const Text('Use Local'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(ConflictResolution.useServer),
          child: const Text('Use Server'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(ConflictResolution.merge),
          child: const Text('Merge'),
        ),
      ],
    );
  }
}
