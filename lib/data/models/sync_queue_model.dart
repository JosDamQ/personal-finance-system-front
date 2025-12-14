import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import '../../core/enums/app_enums.dart';

part 'sync_queue_model.g.dart';

enum SyncQueueStatus {
  pending('PENDING'),
  processing('PROCESSING'),
  completed('COMPLETED'),
  failed('FAILED');

  const SyncQueueStatus(this.value);
  final String value;
}

@JsonSerializable()
class SyncQueueModel extends Equatable {
  final String id;
  final String userId;
  final SyncOperation operation;
  final EntityType entityType;
  final String entityId;
  final Map<String, dynamic> data;
  final int retryCount;
  final int maxRetries;
  final SyncQueueStatus status;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SyncQueueModel({
    required this.id,
    required this.userId,
    required this.operation,
    required this.entityType,
    required this.entityId,
    required this.data,
    required this.retryCount,
    required this.maxRetries,
    required this.status,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SyncQueueModel.fromJson(Map<String, dynamic> json) =>
      _$SyncQueueModelFromJson(json);
  Map<String, dynamic> toJson() => _$SyncQueueModelToJson(this);

  SyncQueueModel copyWith({
    String? id,
    String? userId,
    SyncOperation? operation,
    EntityType? entityType,
    String? entityId,
    Map<String, dynamic>? data,
    int? retryCount,
    int? maxRetries,
    SyncQueueStatus? status,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SyncQueueModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      operation: operation ?? this.operation,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      data: data ?? this.data,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    operation,
    entityType,
    entityId,
    data,
    retryCount,
    maxRetries,
    status,
    errorMessage,
    createdAt,
    updatedAt,
  ];
}
