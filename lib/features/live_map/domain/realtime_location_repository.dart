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
}
