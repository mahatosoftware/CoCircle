// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuditLogModel _$AuditLogModelFromJson(Map<String, dynamic> json) =>
    _AuditLogModel(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      expenseId: json['expenseId'] as String,
      userId: json['userId'] as String,
      action: $enumDecode(_$AuditActionEnumMap, json['action']),
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      timestamp: const TimestampConverter().fromJson(json['timestamp']),
      changes: json['changes'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$AuditLogModelToJson(_AuditLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tripId': instance.tripId,
      'expenseId': instance.expenseId,
      'userId': instance.userId,
      'action': _$AuditActionEnumMap[instance.action]!,
      'title': instance.title,
      'amount': instance.amount,
      'timestamp': const TimestampConverter().toJson(instance.timestamp),
      'changes': instance.changes,
    };

const _$AuditActionEnumMap = {
  AuditAction.create: 'create',
  AuditAction.update: 'update',
  AuditAction.delete: 'delete',
};
