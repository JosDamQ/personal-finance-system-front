import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import '../../core/enums/app_enums.dart';

part 'expense_model.g.dart';

@JsonSerializable()
class ExpenseModel extends Equatable {
  final String id;
  final String userId;
  final String categoryId;
  final String? creditCardId;
  final String? budgetPeriodId;
  final double amount;
  final Currency currency;
  final String description;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SyncStatus? syncStatus;
  final DateTime? lastSyncAt;

  const ExpenseModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    this.creditCardId,
    this.budgetPeriodId,
    required this.amount,
    required this.currency,
    required this.description,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus,
    this.lastSyncAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => _$ExpenseModelFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseModelToJson(this);

  ExpenseModel copyWith({
    String? id,
    String? userId,
    String? categoryId,
    String? creditCardId,
    String? budgetPeriodId,
    double? amount,
    Currency? currency,
    String? description,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
    DateTime? lastSyncAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      creditCardId: creditCardId ?? this.creditCardId,
      budgetPeriodId: budgetPeriodId ?? this.budgetPeriodId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        categoryId,
        creditCardId,
        budgetPeriodId,
        amount,
        currency,
        description,
        date,
        createdAt,
        updatedAt,
        syncStatus,
        lastSyncAt,
      ];
}