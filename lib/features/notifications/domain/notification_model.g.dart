// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    _NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      targetPath: json['targetPath'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      recipientUid: json['recipientUid'] as String,
      senderUid: json['senderUid'] as String,
      senderName: json['senderName'] as String?,
      tripId: json['tripId'] as String?,
      expenseId: json['expenseId'] as String?,
    );

Map<String, dynamic> _$NotificationModelToJson(_NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'targetPath': instance.targetPath,
      'timestamp': instance.timestamp.toIso8601String(),
      'isRead': instance.isRead,
      'recipientUid': instance.recipientUid,
      'senderUid': instance.senderUid,
      'senderName': instance.senderName,
      'tripId': instance.tripId,
      'expenseId': instance.expenseId,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.expenseAdded: 'expenseAdded',
  NotificationType.expenseUpdated: 'expenseUpdated',
  NotificationType.expenseDeleted: 'expenseDeleted',
  NotificationType.circleJoinRequest: 'circleJoinRequest',
  NotificationType.pollCreated: 'pollCreated',
  NotificationType.pollOptionAdded: 'pollOptionAdded',
  NotificationType.pollUpdated: 'pollUpdated',
};
