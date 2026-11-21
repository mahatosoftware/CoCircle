import 'package:flutter_test/flutter_test.dart';
import 'package:cocircle/features/trips/domain/itinerary_item_model.dart';

void main() {
  group('ItineraryItemModel Unit Tests', () {
    final now = DateTime.now();

    test('defaults hasStartTime to true for backwards compatibility', () {
      final item = ItineraryItemModel(
        id: 'item-1',
        tripId: 'trip-1',
        title: 'Morning Yoga',
        type: 'activity',
        startTime: now,
        createdBy: 'user-1',
        createdAt: now,
      );

      expect(item.hasStartTime, isTrue);
      expect(item.endTime, isNull);
    });

    test('serializes and deserializes hasStartTime and optional endTime', () {
      final end = now.add(const Duration(hours: 2));
      final item = ItineraryItemModel(
        id: 'item-2',
        tripId: 'trip-1',
        title: 'Beach Volleyball',
        type: 'adventure',
        startTime: now,
        endTime: end,
        hasStartTime: true,
        createdBy: 'user-1',
        createdAt: now,
      );

      final json = item.toJson();
      expect(json['hasStartTime'], isTrue);
      expect(json['endTime'], isNotNull);

      final fromJson = ItineraryItemModel.fromJson(json);
      expect(fromJson.hasStartTime, isTrue);
      expect(fromJson.endTime, isNotNull);
      expect(fromJson.title, 'Beach Volleyball');
    });

    test('handles flexible time (hasStartTime: false, endTime: null)', () {
      final item = ItineraryItemModel(
        id: 'item-3',
        tripId: 'trip-1',
        title: 'Explore Old Town',
        type: 'sightseeing',
        startTime: now,
        hasStartTime: false,
        createdBy: 'user-1',
        createdAt: now,
      );

      final json = item.toJson();
      expect(json['hasStartTime'], isFalse);

      final fromJson = ItineraryItemModel.fromJson(json);
      expect(fromJson.hasStartTime, isFalse);
      expect(fromJson.endTime, isNull);
    });

    test('copyWith updates properties and clearEndTime works correctly', () {
      final end = now.add(const Duration(hours: 3));
      final original = ItineraryItemModel(
        id: 'item-4',
        tripId: 'trip-1',
        title: 'Dinner at Sunset',
        type: 'dining',
        startTime: now,
        endTime: end,
        hasStartTime: true,
        cost: 1500,
        createdBy: 'user-1',
        createdAt: now,
      );

      // Edit item: update title, category, cost and clear end time
      final updated = original.copyWith(
        title: 'Dinner at Seafood Place',
        category: 'dining',
        cost: 2200,
        clearEndTime: true,
      );

      expect(updated.title, 'Dinner at Seafood Place');
      expect(updated.cost, 2200);
      expect(updated.endTime, isNull);
      expect(updated.hasStartTime, isTrue);

      // Switch to flexible time
      final flexible = updated.copyWith(hasStartTime: false);
      expect(flexible.hasStartTime, isFalse);
    });
  });
}
