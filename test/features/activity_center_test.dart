import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cocircle/features/activity_center/domain/action_item_model.dart';
import 'package:cocircle/features/activity_center/domain/trip_readiness_model.dart';

void main() {
  group('Unified Activity Center Tests', () {
    test('ActionItemModel sorts and exposes correct urgency color & label', () {
      final urgentItem = ActionItemModel(
        id: '1',
        type: ActionItemType.settlement,
        title: 'Pay ₹500 to Alex',
        subtitle: 'Pending settlement',
        urgency: ActionItemUrgency.urgent,
        timestamp: DateTime(2026, 11, 20, 10, 0),
        actionRoute: '/trip/1?tab=3',
        actionLabel: 'Settle Up',
        icon: Icons.payments,
        iconColor: Colors.green,
      );

      final normalItem = ActionItemModel(
        id: '2',
        type: ActionItemType.task,
        title: 'Buy sunblock',
        subtitle: 'Packing checklist',
        urgency: ActionItemUrgency.normal,
        timestamp: DateTime(2026, 11, 20, 9, 0),
        actionRoute: '/trip/1?tab=1',
        actionLabel: 'Claim',
        icon: Icons.backpack,
        iconColor: Colors.blue,
      );

      expect(urgentItem.urgencyLabel, equals('Urgent'));
      expect(urgentItem.urgencyColor, equals(const Color(0xFFEF4444)));

      expect(normalItem.urgencyLabel, equals('To Do'));
      expect(normalItem.urgencyColor, equals(const Color(0xFF3B82F6)));

      final items = [normalItem, urgentItem];
      items.sort((a, b) => a.urgency.index.compareTo(b.urgency.index));

      expect(items.first.id, equals('1')); // urgent comes first
    });

    test('TripReadinessModel computes score color and status badges appropriately', () {
      const readyModel = TripReadinessModel(
        tripId: 'trip_1',
        tripName: 'Goa Holiday',
        overallScore: 88,
        categories: [
          ReadinessCategory(
            title: 'Stays',
            completed: 2,
            total: 2,
            score: 1.0,
            icon: Icons.hotel,
            statusText: '2 booked',
          ),
        ],
        criticalBlockers: [],
        recommendedActions: ['Confirm convoy vehicle'],
      );

      expect(readyModel.overallScore, equals(88));
      expect(readyModel.scoreBadgeLabel, equals('Ready to Travel! 🚀'));
      expect(readyModel.scoreColor, equals(const Color(0xFF10B981)));
      expect(readyModel.categories.first.isReady, isTrue);

      const unreadyModel = TripReadinessModel(
        tripId: 'trip_2',
        tripName: 'Coorg Adventure',
        overallScore: 35,
        categories: [
          ReadinessCategory(
            title: 'Stays',
            completed: 0,
            total: 1,
            score: 0.0,
            icon: Icons.hotel,
            statusText: 'Not booked',
          ),
        ],
        criticalBlockers: ['No stay booked for upcoming 3-day trip'],
        recommendedActions: ['Book accommodation'],
      );

      expect(unreadyModel.overallScore, equals(35));
      expect(unreadyModel.scoreBadgeLabel, equals('Action Needed ⚠️'));
      expect(unreadyModel.scoreColor, equals(const Color(0xFFEF4444)));
      expect(unreadyModel.criticalBlockers.length, equals(1));
    });
  });
}
