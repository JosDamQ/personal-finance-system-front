import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import '../../core/enums/app_enums.dart';

part 'alert_model.g.dart';

@JsonSerializable()
class AlertModel extends Equatable {
  final String id;
  final String userId;
  final AlertType type;
  final String title;
  final String message;
  final bool isRead;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AlertModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) =>
      _$AlertModelFromJson(json);
  Map<String, dynamic> toJson() => _$AlertModelToJson(this);

  AlertModel copyWith({
    String? id,
    String? userId,
    AlertType? type,
    String? title,
    String? message,
    bool? isRead,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AlertModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    title,
    message,
    isRead,
    metadata,
    createdAt,
    updatedAt,
  ];
}
