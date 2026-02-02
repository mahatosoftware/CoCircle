// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExpenseModel _$ExpenseModelFromJson(Map<String, dynamic> json) =>
    _ExpenseModel(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: const TimestampConverter().fromJson(json['date']),
      category: json['category'] as String,
      payerId: json['payerId'] as String,
      payers: (json['payers'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      splitDetails: (json['splitDetails'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      splitType: $enumDecode(_$SplitTypeEnumMap, json['splitType']),
      notes: json['notes'] as String?,
      isSupplemental: json['isSupplemental'] as bool? ?? false,
      createdBy: json['createdBy'] as String,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$ExpenseModelToJson(_ExpenseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tripId': instance.tripId,
      'title': instance.title,
      'amount': instance.amount,
      'date': const TimestampConverter().toJson(instance.date),
      'category': instance.category,
      'payerId': instance.payerId,
      'payers': instance.payers,
      'splitDetails': instance.splitDetails,
      'splitType': _$SplitTypeEnumMap[instance.splitType]!,
      'notes': instance.notes,
      'isSupplemental': instance.isSupplemental,
      'createdBy': instance.createdBy,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };

const _$SplitTypeEnumMap = {
  SplitType.equal: 'equal',
  SplitType.ratio: 'ratio',
  SplitType.percentage: 'percentage',
  SplitType.exact: 'exact',
};
