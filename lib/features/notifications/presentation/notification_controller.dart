import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cocircle/features/auth/data/auth_repository_impl.dart';
import 'package:cocircle/features/notifications/data/notification_repository_impl.dart';
import 'package:cocircle/features/notifications/domain/notification_model.dart';
import 'package:cocircle/features/notifications/domain/notification_preferences_model.dart';

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

  Future<void> toggleMuteCircle(String circleId) async {
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await docRef.get();
    final prefs = doc.data()?['notificationPreferences'] as Map<String, dynamic>? ?? {};
    final mutedCircles = List<String>.from(prefs['mutedCircles'] ?? []);

    if (mutedCircles.contains(circleId)) {
      mutedCircles.remove(circleId);
    } else {
      mutedCircles.add(circleId);
    }

    await docRef.set({
      'notificationPreferences': {
        ...prefs,
        'mutedCircles': mutedCircles,
      }
    }, SetOptions(merge: true));
  }

  Future<void> toggleMuteTrip(String tripId) async {
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await docRef.get();
    final prefs = doc.data()?['notificationPreferences'] as Map<String, dynamic>? ?? {};
    final mutedTrips = List<String>.from(prefs['mutedTrips'] ?? []);

    if (mutedTrips.contains(tripId)) {
      mutedTrips.remove(tripId);
    } else {
      mutedTrips.add(tripId);
    }

    await docRef.set({
      'notificationPreferences': {
        ...prefs,
        'mutedTrips': mutedTrips,
      }
    }, SetOptions(merge: true));
  }

  Future<void> setExpensesEnabled(bool enabled) async {
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await docRef.get();
    final prefs = doc.data()?['notificationPreferences'] as Map<String, dynamic>? ?? {};

    await docRef.set({
      'notificationPreferences': {
        ...prefs,
        'expensesEnabled': enabled,
      }
    }, SetOptions(merge: true));
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

@riverpod
Stream<NotificationPreferencesModel> userNotificationPreferences(Ref ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return const Stream.empty();
  return FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots().map((doc) {
    if (!doc.exists || doc.data()?['notificationPreferences'] == null) {
      return const NotificationPreferencesModel();
    }
    return NotificationPreferencesModel.fromJson(
      Map<String, dynamic>.from(doc.data()!['notificationPreferences']),
    );
  });
}
