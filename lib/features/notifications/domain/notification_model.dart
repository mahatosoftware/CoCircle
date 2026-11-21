import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/timestamp_converter.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

enum NotificationType {
  expenseAdded,
  expenseUpdated,
  expenseDeleted,
  expenseSplitChanged,
  circleJoinRequest,
  pollCreated,
  pollOptionAdded,
  pollUpdated,
}

class NotificationTypeConverter implements JsonConverter<NotificationType, dynamic> {
  const NotificationTypeConverter();

  @override
  NotificationType fromJson(dynamic json) {
    if (json == null) return NotificationType.expenseAdded;
    final str = json.toString();
    switch (str) {
      case 'expense_created':
      case 'expenseAdded':
        return NotificationType.expenseAdded;
      case 'expense_updated':
      case 'expenseUpdated':
        return NotificationType.expenseUpdated;
      case 'expense_deleted':
      case 'expenseDeleted':
        return NotificationType.expenseDeleted;
      case 'expense_split_changed':
      case 'expenseSplitChanged':
        return NotificationType.expenseSplitChanged;
      case 'circleJoinRequest':
        return NotificationType.circleJoinRequest;
      case 'pollCreated':
        return NotificationType.pollCreated;
      case 'pollOptionAdded':
        return NotificationType.pollOptionAdded;
      case 'pollUpdated':
        return NotificationType.pollUpdated;
      default:
        return NotificationType.expenseAdded;
    }
  }

  @override
  dynamic toJson(NotificationType type) {
    switch (type) {
      case NotificationType.expenseAdded:
        return 'expense_created';
      case NotificationType.expenseUpdated:
        return 'expense_updated';
      case NotificationType.expenseDeleted:
        return 'expense_deleted';
      case NotificationType.expenseSplitChanged:
        return 'expense_split_changed';
      default:
        return type.name;
    }
  }
}

@freezed
abstract class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required String id,
    required String title,
    required String body,
    @NotificationTypeConverter() required NotificationType type,
    required String targetPath,
    @TimestampConverter() required DateTime timestamp,
    @Default(false) bool isRead,
    required String recipientUid,
    required String senderUid,
    String? senderName,
    String? tripId,
    String? expenseId,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);
}
