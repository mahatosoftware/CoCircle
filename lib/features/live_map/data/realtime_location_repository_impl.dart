import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cocircle/core/config/firebase_providers.dart';
import '../domain/member_location_model.dart';
import '../domain/realtime_location_repository.dart';

part 'realtime_location_repository_impl.g.dart';

@Riverpod(keepAlive: true)
RealtimeLocationRepository realtimeLocationRepository(Ref ref) {
  final db = ref.watch(firebaseDatabaseProvider);
  return RealtimeLocationRepositoryImpl(db);
}

class RealtimeLocationRepositoryImpl implements RealtimeLocationRepository {
  final FirebaseDatabase _db;

  RealtimeLocationRepositoryImpl(this._db);
  @override
  Stream<List<MemberLocationModel>> streamMemberLocations(String tripId) {
    return _db
        .ref('trip_locations/$tripId/members')
        .onValue
        .map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) return [];

      final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      final List<MemberLocationModel> list = [];

      data.forEach((key, val) {
        if (val is Map) {
          try {
            final map = Map<String, dynamic>.from(val);
            
            // Map RTDB timestamp to ISO string for parser
            final int timestamp = map['lastUpdated'] as int? ?? DateTime.now().millisecondsSinceEpoch;
            final isoString = DateTime.fromMillisecondsSinceEpoch(timestamp).toIso8601String();

            map['lastUpdated'] = isoString;
            map['userId'] = key as String;

            // Safely parse double values
            if (map['latitude'] != null) map['latitude'] = (map['latitude'] as num).toDouble();
            if (map['longitude'] != null) map['longitude'] = (map['longitude'] as num).toDouble();
            if (map['heading'] != null) map['heading'] = (map['heading'] as num).toDouble();
            if (map['speed'] != null) map['speed'] = (map['speed'] as num).toDouble();
            if (map['accuracy'] != null) map['accuracy'] = (map['accuracy'] as num).toDouble();

            list.add(MemberLocationModel.fromJson(map));
          } catch (e, stack) {
            // Log parse errors for debugging
            debugPrint("Error parsing member location: $e");
            debugPrint("Stack trace: $stack");
          }
        }
      });
      return list;
    });
  }

  @override
  Stream<Map<String, Map<String, dynamic>>> streamPresence(String tripId) {
    return _db
        .ref('trip_presence/$tripId')
        .onValue
        .map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) return {};

      final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      final Map<String, Map<String, dynamic>> map = {};

      data.forEach((key, val) {
        if (val is Map) {
          map[key as String] = Map<String, dynamic>.from(val);
        }
      });
      return map;
    });
  }

  @override
  Stream<Map<String, Map<String, dynamic>>> streamDestinations(String tripId) {
    return _db
        .ref('trip_destinations/$tripId')
        .onValue
        .map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) return {};

      final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      final Map<String, Map<String, dynamic>> map = {};

      data.forEach((key, val) {
        if (val is Map) {
          map[key as String] = Map<String, dynamic>.from(val);
        }
      });
      return map;
    });
  }

  @override
  Future<void> setDestination({
    required String tripId,
    required String destinationId,
    required String name,
    required double latitude,
    required double longitude,
  }) async {
    await _db.ref('trip_destinations/$tripId/$destinationId').set({
      'id': destinationId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  @override
  Future<void> removeDestination(String tripId, String destinationId) async {
    await _db.ref('trip_destinations/$tripId/$destinationId').remove();
  }

  @override
  Stream<Map<String, Map<String, dynamic>>> streamRoutes(String tripId) {
    return _db
        .ref('trip_routes/$tripId')
        .onValue
        .map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) return {};

      final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      final Map<String, Map<String, dynamic>> map = {};

      data.forEach((key, val) {
        if (val is Map) {
          map[key as String] = Map<String, dynamic>.from(val);
        }
      });
      return map;
    });
  }

  @override
  Future<void> updateRoute({
    required String tripId,
    required String userId,
    required String encodedPolyline,
    required double distance,
    required double duration,
  }) async {
    await _db.ref('trip_routes/$tripId/$userId').set({
      'encodedPolyline': encodedPolyline,
      'distance': distance,
      'duration': duration,
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> streamNotifications(String tripId) {
    return _db
        .ref('trip_notifications/$tripId')
        .onValue
        .map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) return [];

      final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      final List<Map<String, dynamic>> list = [];

      data.forEach((key, val) {
        if (val is Map) {
          list.add(Map<String, dynamic>.from(val));
        }
      });

      // Sort by timestamp descending
      list.sort((a, b) {
        final tA = a['timestamp'] as int? ?? 0;
        final tB = b['timestamp'] as int? ?? 0;
        return tB.compareTo(tA);
      });

      return list;
    });
  }

  @override
  Future<void> postNotification({
    required String tripId,
    required String title,
    required String body,
  }) async {
    final notificationRef = _db.ref('trip_notifications/$tripId').push();
    await notificationRef.set({
      'id': notificationRef.key,
      'title': title,
      'body': body,
      'timestamp': ServerValue.timestamp,
    });
  }
}
