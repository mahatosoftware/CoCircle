import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/utils/timestamp_converter.dart';

part 'settlement_model.freezed.dart';
part 'settlement_model.g.dart';

@freezed
abstract class SettlementModel with _$SettlementModel {
  @JsonSerializable(explicitToJson: true)
  const factory SettlementModel({
    required String id,
    required String tripId,
    required int version,
    @TimestampConverter() required DateTime timestamp,
    required Map<String, double> balances, // uid -> net balance
    required List<SettlementTransaction> transactions, // suggested transfers
    required List<String> expenseIdsIncluded, // Immutability
    required String createdBy,
  }) = _SettlementModel;

  factory SettlementModel.fromJson(Map<String, dynamic> json) => _$SettlementModelFromJson(json);
}

@freezed
abstract class SettlementTransaction with _$SettlementTransaction {
  @JsonSerializable(explicitToJson: true)
  const factory SettlementTransaction({
    required String fromUid,
    required String toUid,
    required double amount,
    @Default(false) bool payerConfirmed,
    @Default(false) bool receiverConfirmed,
    @Default(false) bool isCompleted,
    @TimestampConverter() DateTime? completedAt,
  }) = _SettlementTransaction;

  factory SettlementTransaction.fromJson(Map<String, dynamic> json) => _$SettlementTransactionFromJson(json);
}
