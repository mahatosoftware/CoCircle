import 'package:flutter_test/flutter_test.dart';
import 'package:cocircle/features/live_map/domain/member_location_model.dart';
import 'package:cocircle/features/live_map/presentation/widgets/member_bottom_sheet.dart';
import 'package:cocircle/features/tracking/application/tracking_notifier.dart';

void main() {
  group('Shared Live Map Domain & Convoy Tests', () {
    test('MemberLocationModel parses json correctly with sharingStatus and emergency', () {
      final json = {
        'userId': 'usr_1',
        'name': 'Rahul Sharma',
        'latitude': 12.9716,
        'longitude': 77.5946,
        'speed': 15.5,
        'heading': 90.0,
        'accuracy': 5.0,
        'battery': 85,
        'online': true,
        'lastUpdated': '2026-11-20T12:00:00.000Z',
        'vehicleId': 'car_1',
        'vehicleName': "Rahul's SUV",
        'sharingStatus': 'sharing',
        'isEmergency': false,
      };

      final model = MemberLocationModel.fromJson(json);

      expect(model.userId, 'usr_1');
      expect(model.name, 'Rahul Sharma');
      expect(model.latitude, 12.9716);
      expect(model.longitude, 77.5946);
      expect(model.speed, 15.5);
      expect(model.battery, 85);
      expect(model.online, isTrue);
      expect(model.vehicleId, 'car_1');
      expect(model.vehicleName, "Rahul's SUV");
      expect(model.sharingStatus, 'sharing');
      expect(model.isEmergency, isFalse);
    });

    test('MemberLocationModel defaults to sharing status and no emergency', () {
      final model = MemberLocationModel(
        userId: 'usr_2',
        name: 'Amit Patel',
        latitude: 12.3375,
        longitude: 75.8069,
        lastUpdated: DateTime.now(),
      );

      expect(model.sharingStatus, 'sharing');
      expect(model.isEmergency, isFalse);
      expect(model.online, isFalse);
      expect(model.speed, 0.0);
    });

    test('VehicleConfig correctly matches vehicle IDs and fallbacks to walking', () {
      final car1 = VehicleConfig.getById('car_1');
      expect(car1.name, 'Car 1');

      final bike = VehicleConfig.getById('bike');
      expect(bike.name, 'Motorcycle / Bike');

      final unknown = VehicleConfig.getById('spaceship');
      expect(unknown.name, 'Walking / On Foot');
    });

    test('TrackingState copyWith handles sharingStatus and expiry correctly', () {
      final initial = TrackingState();
      expect(initial.isTracking, isFalse);
      expect(initial.sharingStatus, 'offline');
      expect(initial.sharingExpiry, isNull);

      final expiryTime = DateTime.now().add(const Duration(hours: 4));
      final updated = initial.copyWith(
        isTracking: true,
        tripId: 'trip_101',
        sharingStatus: 'sharing',
        sharingExpiry: expiryTime,
      );

      expect(updated.isTracking, isTrue);
      expect(updated.tripId, 'trip_101');
      expect(updated.sharingStatus, 'sharing');
      expect(updated.sharingExpiry, expiryTime);

      final paused = updated.copyWith(sharingStatus: 'paused');
      expect(paused.sharingStatus, 'paused');
      expect(paused.isTracking, isTrue);
    });
  });
}
