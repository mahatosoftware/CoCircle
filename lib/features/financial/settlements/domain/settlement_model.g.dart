// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settlement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SettlementModel _$SettlementModelFromJson(Map<String, dynamic> json) =>
    _SettlementModel(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      version: (json['version'] as num).toInt(),
      timestamp: const TimestampConverter().fromJson(json['timestamp']),
      balances: (json['balances'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      transactions: (json['transactions'] as List<dynamic>)
          .map((e) => SettlementTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      expenseIdsIncluded: (json['expenseIdsIncluded'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdBy: json['createdBy'] as String,
    );

Map<String, dynamic> _$SettlementModelToJson(_SettlementModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tripId': instance.tripId,
      'version': instance.version,
      'timestamp': const TimestampConverter().toJson(instance.timestamp),
      'balances': instance.balances,
      'transactions': instance.transactions.map((e) => e.toJson()).toList(),
      'expenseIdsIncluded': instance.expenseIdsIncluded,
      'createdBy': instance.createdBy,
    };

_SettlementTransaction _$SettlementTransactionFromJson(
  Map<String, dynamic> json,
) => _SettlementTransaction(
  fromUid: json['fromUid'] as String,
  toUid: json['toUid'] as String,
  amount: (json['amount'] as num).toDouble(),
  payerConfirmed: json['payerConfirmed'] as bool? ?? false,
  receiverConfirmed: json['receiverConfirmed'] as bool? ?? false,
  isCompleted: json['isCompleted'] as bool? ?? false,
  completedAt: const TimestampConverter().fromJson(json['completedAt']),
);

Map<String, dynamic> _$SettlementTransactionToJson(
  _SettlementTransaction instance,
) => <String, dynamic>{
  'fromUid': instance.fromUid,
  'toUid': instance.toUid,
  'amount': instance.amount,
  'payerConfirmed': instance.payerConfirmed,
  'receiverConfirmed': instance.receiverConfirmed,
  'isCompleted': instance.isCompleted,
  'completedAt': _$JsonConverterToJson<dynamic, DateTime>(
    instance.completedAt,
    const TimestampConverter().toJson,
  ),
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
