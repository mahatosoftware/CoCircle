import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cocircle/features/auth/data/auth_repository_impl.dart';
import 'package:cocircle/features/notifications/data/notification_repository_impl.dart';
import 'package:cocircle/features/notifications/domain/notification_model.dart';

part 'notification_controller.g.dart';

@Riverpod(keepAlive: true)
class NotificationController extends _$NotificationController {
  @override
  FutureOr<void> build() {
    // Initial state
  }

  Future<void> markAsRead(String notificationId) async {
    await ref.read(notificationRepositoryProvider).markAsRead(notificationId);
  }

  Future<void> markAllAsRead() async {
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user != null) {
      await ref.read(notificationRepositoryProvider).markAllAsRead(user.uid);
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    await ref.read(notificationRepositoryProvider).deleteNotification(notificationId);
  }
}

@riverpod
Stream<List<NotificationModel>> userNotifications(Ref ref) {
  final userAsync = ref.watch(authStateChangesProvider);
  return userAsync.when(
    data: (user) {
      if (user == null) return const Stream.empty();
      return ref.watch(notificationRepositoryProvider).getNotificationsStream(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
}

@riverpod
int unreadNotificationCount(Ref ref) {
  final notificationsAsync = ref.watch(userNotificationsProvider);
  return notificationsAsync.when(
    data: (notifications) => notifications.where((n) => !n.isRead).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}
