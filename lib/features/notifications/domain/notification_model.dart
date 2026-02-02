import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

enum NotificationType {
  expenseAdded,
  expenseUpdated,
  expenseDeleted,
  circleJoinRequest,
}

@freezed
abstract class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required String id,
    required String title,
    required String body,
    required NotificationType type,
    required String targetPath,
    required DateTime timestamp,
    @Default(false) bool isRead,
    required String recipientUid,
    required String senderUid,
    String? senderName,
    String? tripId,
    String? expenseId,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);
}
