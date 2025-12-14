import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import '../../core/enums/app_enums.dart';

part 'credit_card_model.g.dart';

@JsonSerializable()
class CreditCardModel extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String bank;
  final double limitGTQ;
  final double limitUSD;
  final double currentBalanceGTQ;
  final double currentBalanceUSD;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SyncStatus? syncStatus;
  final DateTime? lastSyncAt;

  const CreditCardModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.bank,
    required this.limitGTQ,
    required this.limitUSD,
    required this.currentBalanceGTQ,
    required this.currentBalanceUSD,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus,
    this.lastSyncAt,
  });

  factory CreditCardModel.fromJson(Map<String, dynamic> json) => _$CreditCardModelFromJson(json);
  Map<String, dynamic> toJson() => _$CreditCardModelToJson(this);

  // Calculated properties
  double get availableGTQ => limitGTQ - currentBalanceGTQ;
  double get availableUSD => limitUSD - currentBalanceUSD;
  double get usagePercentageGTQ => limitGTQ > 0 ? (currentBalanceGTQ / limitGTQ) * 100 : 0;
  double get usagePercentageUSD => limitUSD > 0 ? (currentBalanceUSD / limitUSD) * 100 : 0;

  CreditCardModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? bank,
    double? limitGTQ,
    double? limitUSD,
    double? currentBalanceGTQ,
    double? currentBalanceUSD,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
    DateTime? lastSyncAt,
  }) {
    return CreditCardModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      bank: bank ?? this.bank,
      limitGTQ: limitGTQ ?? this.limitGTQ,
      limitUSD: limitUSD ?? this.limitUSD,
      currentBalanceGTQ: currentBalanceGTQ ?? this.currentBalanceGTQ,
      currentBalanceUSD: currentBalanceUSD ?? this.currentBalanceUSD,
      isActive: isActive ?? this.isActive,
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
        name,
        bank,
        limitGTQ,
        limitUSD,
        currentBalanceGTQ,
        currentBalanceUSD,
        isActive,
        createdAt,
        updatedAt,
        syncStatus,
        lastSyncAt,
      ];
}