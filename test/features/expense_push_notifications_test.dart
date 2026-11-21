import 'package:flutter_test/flutter_test.dart';
import 'package:cocircle/features/notifications/domain/notification_model.dart';
import 'package:cocircle/features/notifications/domain/notification_preferences_model.dart';

void main() {
  group('Real-Time Expense Notifications - Client Test Suite', () {
    test('1. NotificationModel deserializes Cloud Function expense_created payload with personal share', () {
      final json = {
        'id': 'notif_create_123',
        'title': 'New expense added',
        'body': 'Debasish added ₹2,500 for "Dinner" in Goa Weekend Trip. Your share: ₹625.00',
        'type': 'expense_created',
        'targetPath': '/trip/trip_goa/expense/exp_dinner',
        'timestamp': '2026-11-21T16:00:00.000Z',
        'isRead': false,
        'recipientUid': 'user_rahul',
        'senderUid': 'user_debasish',
        'senderName': 'Debasish',
        'tripId': 'trip_goa',
        'expenseId': 'exp_dinner',
      };

      final model = NotificationModel.fromJson(json);

      expect(model.id, equals('notif_create_123'));
      expect(model.title, equals('New expense added'));
      expect(model.body, contains('Your share: ₹625.00'));
      expect(model.type, equals(NotificationType.expenseAdded));
      expect(model.targetPath, equals('/trip/trip_goa/expense/exp_dinner'));
      expect(model.isRead, isFalse);
      expect(model.recipientUid, equals('user_rahul'));
      expect(model.senderName, equals('Debasish'));
    });

    test('2. NotificationModel serializes and deserializes expense_split_changed and expense_deleted', () {
      final splitNotifJson = {
        'id': 'notif_split_1',
        'title': 'Expense split changed',
        'body': 'Debasish changed the split for "Dinner" in Goa Weekend Trip. Your share: ₹750.00',
        'type': 'expense_split_changed',
        'targetPath': '/trip/trip_goa/expense/exp_dinner',
        'timestamp': '2026-11-21T16:05:00.000Z',
        'isRead': true,
        'recipientUid': 'user_rahul',
        'senderUid': 'user_debasish',
      };

      final splitModel = NotificationModel.fromJson(splitNotifJson);
      expect(splitModel.type, equals(NotificationType.expenseSplitChanged));
      expect(splitModel.toJson()['type'], equals('expense_split_changed'));

      final delNotifJson = {
        'id': 'notif_del_1',
        'title': 'Expense deleted',
        'body': 'Debasish removed "Dinner" (₹2,500) from Goa Weekend Trip.',
        'type': 'expense_deleted',
        'targetPath': '/trip/trip_goa?tab=5',
        'timestamp': '2026-11-21T16:10:00.000Z',
        'isRead': false,
        'recipientUid': 'user_rahul',
        'senderUid': 'user_debasish',
      };

      final delModel = NotificationModel.fromJson(delNotifJson);
      expect(delModel.type, equals(NotificationType.expenseDeleted));
      expect(delModel.targetPath, equals('/trip/trip_goa?tab=5'));
    });

    test('3. NotificationPreferencesModel checks muted trips, circles, and global flags', () {
      const prefs = NotificationPreferencesModel(
        expensesEnabled: true,
        mutedTrips: ['trip_muted_1'],
        mutedCircles: ['circle_muted_1'],
      );

      expect(prefs.isTripMuted('trip_muted_1'), isTrue);
      expect(prefs.isTripMuted('trip_active_2'), isFalse);

      expect(prefs.isCircleMuted('circle_muted_1'), isTrue);
      expect(prefs.isCircleMuted('circle_active_2'), isFalse);

      final json = prefs.toJson();
      expect(json['mutedTrips'], contains('trip_muted_1'));
      expect(json['mutedCircles'], contains('circle_muted_1'));

      final parsed = NotificationPreferencesModel.fromJson(json);
      expect(parsed.expensesEnabled, isTrue);
      expect(parsed.mutedTrips, equals(['trip_muted_1']));
      expect(parsed.mutedCircles, equals(['circle_muted_1']));
    });
  });
}
