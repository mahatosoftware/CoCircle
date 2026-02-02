import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/errors/failure.dart';
import 'package:cocircle/features/notifications/domain/notification_model.dart';
import 'package:cocircle/features/notifications/domain/notification_repository.dart';

part 'notification_repository_impl.g.dart';

@Riverpod(keepAlive: true)
NotificationRepository notificationRepository(Ref ref) {
  return NotificationRepositoryImpl(firestore: FirebaseFirestore.instance);
}

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepositoryImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _notifications => _firestore.collection('notifications');

  @override
  Future<Either<Failure, void>> sendNotification(NotificationModel notification) async {
    try {
      await _notifications.doc(notification.id).set(notification.toJson());
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _notifications
        .where('recipientUid', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((d) => NotificationModel.fromJson(d.data())).toList();
    });
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await _notifications.doc(notificationId).update({'isRead': true});
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead(String userId) async {
    try {
      final query = await _notifications
          .where('recipientUid', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      
      final batch = _firestore.batch();
      for (var doc in query.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
      
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String notificationId) async {
    try {
      await _notifications.doc(notificationId).delete();
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
