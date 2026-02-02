import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../domain/notification_model.dart';

abstract class NotificationRepository {
  Future<Either<Failure, void>> sendNotification(NotificationModel notification);
  Stream<List<NotificationModel>> getNotificationsStream(String userId);
  Future<Either<Failure, void>> markAsRead(String notificationId);
  Future<Either<Failure, void>> markAllAsRead(String userId);
  Future<Either<Failure, void>> deleteNotification(String notificationId);
}
