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
      type: const NotificationTypeConverter().fromJson(json['type']),
      targetPath: json['targetPath'] as String,
      timestamp: const TimestampConverter().fromJson(json['timestamp']),
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
      'type': const NotificationTypeConverter().toJson(instance.type),
      'targetPath': instance.targetPath,
      'timestamp': const TimestampConverter().toJson(instance.timestamp),
      'isRead': instance.isRead,
      'recipientUid': instance.recipientUid,
      'senderUid': instance.senderUid,
      'senderName': instance.senderName,
      'tripId': instance.tripId,
      'expenseId': instance.expenseId,
    };
