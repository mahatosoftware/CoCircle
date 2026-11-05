import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:collection/collection.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cocircle/core/config/firebase_providers.dart';
import '../../auth/data/auth_repository_impl.dart';
import '../../navigation/data/navigation_repository_impl.dart';
import '../../navigation/domain/navigation_route_model.dart';
import '../data/realtime_location_repository_impl.dart';
import '../domain/member_location_model.dart';

part 'live_map_controller.g.dart';

class LiveMapState {
  final List<MemberLocationModel> members;
  final Map<String, Map<String, dynamic>> presence; 
  final Map<String, Map<String, dynamic>> destinations; 
  final Map<String, Map<String, dynamic>> routes; 
  final List<Map<String, dynamic>> notifications;
  final String? selectedMemberId;
  final String? activeDestinationId;
  final bool followMe;
  final double mapRotation;
  final String? navigationTargetId; 
  final NavigationRouteModel? navigationRoute;
  final bool isNavigating;
  final bool isLoadingRoute;

  LiveMapState({
    this.members = const [],
    this.presence = const {},
    this.destinations = const {},
    this.routes = const {},
    this.notifications = const [],
    this.selectedMemberId,
    this.activeDestinationId,
    this.followMe = false,
    this.mapRotation = 0.0,
    this.navigationTargetId,
    this.navigationRoute,
    this.isNavigating = false,
    this.isLoadingRoute = false,
  });

  LiveMapState copyWith({
    List<MemberLocationModel>? members,
    Map<String, Map<String, dynamic>>? presence,
    Map<String, Map<String, dynamic>>? destinations,
    Map<String, Map<String, dynamic>>? routes,
    List<Map<String, dynamic>>? notifications,
    String? selectedMemberId,
    String? activeDestinationId,
    bool? followMe,
    double? mapRotation,
    String? navigationTargetId,
    NavigationRouteModel? navigationRoute,
    bool? isNavigating,
    bool? isLoadingRoute,
  }) {
    return LiveMapState(
      members: members ?? this.members,
      presence: presence ?? this.presence,
      destinations: destinations ?? this.destinations,
      routes: routes ?? this.routes,
      notifications: notifications ?? this.notifications,
      selectedMemberId: selectedMemberId ?? this.selectedMemberId,
      activeDestinationId: activeDestinationId ?? this.activeDestinationId,
      followMe: followMe ?? this.followMe,
      mapRotation: mapRotation ?? this.mapRotation,
      navigationTargetId: navigationTargetId ?? this.navigationTargetId,
      navigationRoute: navigationRoute ?? this.navigationRoute,
      isNavigating: isNavigating ?? this.isNavigating,
      isLoadingRoute: isLoadingRoute ?? this.isLoadingRoute,
    );
  }
}

@riverpod
class LiveMapController extends _$LiveMapController {
  bool _hasArrived = false;
  LatLng? _lastQueryLatLng;
  DateTime? _lastQueryTime;

  @override
  LiveMapState build(String tripId) {
    final locationRepo = ref.watch(realtimeLocationRepositoryProvider);

    final subLocations = locationRepo.streamMemberLocations(tripId).listen((list) {
      state = state.copyWith(members: list);
      _checkArrivalAndRoute(list);
    });

    final subPresence = locationRepo.streamPresence(tripId).listen((pres) {
      state = state.copyWith(presence: pres);
    });

    final subDestinations = locationRepo.streamDestinations(tripId).listen((dests) {
      state = state.copyWith(destinations: dests);
      if (state.activeDestinationId == null && dests.isNotEmpty) {
        state = state.copyWith(activeDestinationId: dests.keys.first);
      }
    });

    final subRoutes = locationRepo.streamRoutes(tripId).listen((rts) {
      state = state.copyWith(routes: rts);
    });

    final subNotifications = locationRepo.streamNotifications(tripId).listen((notifs) {
      state = state.copyWith(notifications: notifs);
    });

    ref.onDispose(() {
      subLocations.cancel();
      subPresence.cancel();
      subDestinations.cancel();
      subRoutes.cancel();
      subNotifications.cancel();
    });

    return LiveMapState();
  }

  void selectMember(String? userId) {
    state = state.copyWith(selectedMemberId: userId);
  }

  void toggleFollowMe(bool follow) {
    state = state.copyWith(followMe: follow);
  }

  void updateRotation(double rotation) {
    state = state.copyWith(mapRotation: rotation);
  }

  Future<void> selectActiveDestination(String? destId) async {
    state = state.copyWith(activeDestinationId: destId);
    _hasArrived = false; // Reset arrival state for new destination
    
    // Auto re-route if navigating
    if (state.isNavigating && destId != null) {
      await startNavigation(destId);
    }
  }

  Future<void> addNewDestination(String name, double lat, double lng) async {
    final destId = 'dest_${DateTime.now().millisecondsSinceEpoch}';
    await ref.read(realtimeLocationRepositoryProvider).setDestination(
      tripId: tripId,
      destinationId: destId,
      name: name,
      latitude: lat,
      longitude: lng,
    );
    await selectActiveDestination(destId);
  }

  Future<void> removeDestination(String destId) async {
    await ref.read(realtimeLocationRepositoryProvider).removeDestination(tripId, destId);
    if (state.activeDestinationId == destId) {
      final remaining = state.destinations.keys.where((k) => k != destId);
      await selectActiveDestination(remaining.isNotEmpty ? remaining.first : null);
    }
  }

  Future<void> startNavigation(String targetId) async {
    state = state.copyWith(
      navigationTargetId: targetId,
      isNavigating: true,
      isLoadingRoute: true,
    );

    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;
    final userId = user.uid;

    final myLocation = state.members.firstWhereOrNull((m) => m.userId == userId);
    if (myLocation == null) {
      state = state.copyWith(isLoadingRoute: false);
      return;
    }

    await _calculateAndPublishRoute(myLocation, targetId);
  }

  Future<void> stopNavigation() async {
    final user = ref.read(authStateChangesProvider).value;
    if (user != null) {
      final userId = user.uid;
      // Clear route in database
      await ref.read(firebaseDatabaseProvider).ref('trip_routes/$tripId/$userId').remove();
    }
    state = state.copyWith(
      navigationTargetId: null,
      navigationRoute: null,
      isNavigating: false,
      isLoadingRoute: false,
    );
    _lastQueryLatLng = null;
    _lastQueryTime = null;
  }

  void _checkArrivalAndRoute(List<MemberLocationModel> list) {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;
    final userId = user.uid;

    final myLocation = list.firstWhereOrNull((m) => m.userId == userId);
    if (myLocation == null) return;

    // 1. Check Arrival
    final activeDestId = state.activeDestinationId;
    if (activeDestId != null) {
      final dest = state.destinations[activeDestId];
      if (dest != null) {
        final destLat = (dest['latitude'] as num).toDouble();
        final destLng = (dest['longitude'] as num).toDouble();
        final distance = Geolocator.distanceBetween(
          myLocation.latitude,
          myLocation.longitude,
          destLat,
          destLng,
        );

        if (distance <= 50.0) {
          if (!_hasArrived) {
            _hasArrived = true;
            final destName = dest['name'] as String? ?? 'Destination';
            ref.read(realtimeLocationRepositoryProvider).postNotification(
              tripId: tripId,
              title: "Destination Reached!",
              body: "${myLocation.name} has arrived at $destName!",
            );
          }
        } else if (distance > 100.0) {
          _hasArrived = false;
        }
      }
    }

    // 2. Throttled Route Recalculation
    if (state.isNavigating && state.navigationTargetId != null) {
      final now = DateTime.now();
      final currentLatLng = LatLng(myLocation.latitude, myLocation.longitude);

      if (_lastQueryLatLng == null || _lastQueryTime == null) {
        _calculateAndPublishRoute(myLocation, state.navigationTargetId!);
      } else {
        final metersMoved = const Distance().as(LengthUnit.Meter, _lastQueryLatLng!, currentLatLng);
        final elapsedSeconds = now.difference(_lastQueryTime!).inSeconds;

        // Throttling: update route only if user moved > 80m or 45 seconds elapsed
        if (metersMoved > 80.0 || elapsedSeconds >= 45) {
          _calculateAndPublishRoute(myLocation, state.navigationTargetId!);
        }
      }
    }
  }

  Future<void> _calculateAndPublishRoute(MemberLocationModel myLocation, String targetId) async {
    LatLng? targetLatLng;

    // Check if target is a destination
    if (state.destinations.containsKey(targetId)) {
      final dest = state.destinations[targetId]!;
      targetLatLng = LatLng((dest['latitude'] as num).toDouble(), (dest['longitude'] as num).toDouble());
    } else {
      // Check if target is a member
      final targetMember = state.members.firstWhereOrNull((m) => m.userId == targetId);
      if (targetMember != null) {
        targetLatLng = LatLng(targetMember.latitude, targetMember.longitude);
      }
    }

    if (targetLatLng == null) {
      state = state.copyWith(isLoadingRoute: false);
      return;
    }

    _lastQueryLatLng = LatLng(myLocation.latitude, myLocation.longitude);
    _lastQueryTime = DateTime.now();

    try {
      final route = await ref.read(navigationRepositoryProvider).getRoute(
        startLat: myLocation.latitude,
        startLng: myLocation.longitude,
        endLat: targetLatLng.latitude,
        endLng: targetLatLng.longitude,
      );

      state = state.copyWith(
        navigationRoute: route,
        isLoadingRoute: false,
      );

      // Publish route to RTDB
      await ref.read(realtimeLocationRepositoryProvider).updateRoute(
        tripId: tripId,
        userId: myLocation.userId,
        encodedPolyline: route.encodedPolyline ?? "",
        distance: route.distance,
        duration: route.duration,
      );
    } catch (e) {
      debugPrint("Failed to calculate navigation route: $e");
      state = state.copyWith(isLoadingRoute: false);
    }
  }
}
