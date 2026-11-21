import 'member_location_model.dart';

abstract class RealtimeLocationRepository {
  Stream<List<MemberLocationModel>> streamMemberLocations(String tripId);
  Stream<Map<String, Map<String, dynamic>>> streamPresence(String tripId);
  Stream<Map<String, Map<String, dynamic>>> streamDestinations(String tripId);
  Future<void> setDestination({
    required String tripId,
    required String destinationId,
    required String name,
    required double latitude,
    required double longitude,
    String? address,
    int? order,
  });
  Future<void> removeDestination(String tripId, String destinationId);
  Stream<Map<String, Map<String, dynamic>>> streamRoutes(String tripId);
  Future<void> updateRoute({
    required String tripId,
    required String userId,
    required String encodedPolyline,
    required double distance,
    required double duration,
  });
  Stream<List<Map<String, dynamic>>> streamNotifications(String tripId);
  Future<void> postNotification({
    required String tripId,
    required String title,
    required String body,
  });

  // Meeting Points & Arrival Tracking
  Stream<Map<String, Map<String, dynamic>>> streamMeetingPoints(String tripId);
  Future<void> setMeetingPoint({
    required String tripId,
    required String meetingPointId,
    required String name,
    required double latitude,
    required double longitude,
    required String createdBy,
    String? note,
  });
  Future<void> removeMeetingPoint(String tripId, String meetingPointId);
  Future<void> checkInAtMeetingPoint({
    required String tripId,
    required String meetingPointId,
    required String userId,
    required String userName,
  });

  // Multiple Vehicle Coordination
  Stream<Map<String, Map<String, dynamic>>> streamVehicles(String tripId);
  Future<void> setVehicle({
    required String tripId,
    required String vehicleId,
    required String name,
    required String type,
    String? driverId,
    String? driverName,
    String? colorHex,
  });
  Future<void> assignMemberToVehicle({
    required String tripId,
    required String vehicleId,
    required String userId,
    required String userName,
    String? vehicleName,
  });

  // Emergency Assistance (SOS)
  Stream<Map<String, Map<String, dynamic>>> streamSOSAlerts(String tripId);
  Future<void> triggerSOS({
    required String tripId,
    required String userId,
    required String userName,
    required double latitude,
    required double longitude,
    int? battery,
  });
  Future<void> clearSOS({
    required String tripId,
    required String userId,
  });
}
