import 'dart:async';
import 'package:flutter/foundation.dart';
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
  final Map<String, Map<String, dynamic>> meetingPoints;
  final Map<String, Map<String, dynamic>> vehicles;
  final Map<String, Map<String, dynamic>> sosAlerts;
  final String? selectedMemberId;
  final String? activeDestinationId;
  final bool followMe;
  final double mapRotation;
  final String? navigationTargetId; 
  final NavigationRouteModel? navigationRoute;
  final bool isNavigating;
  final bool isLoadingRoute;
  final String? selectedVehicleId;

  LiveMapState({
    this.members = const [],
    this.presence = const {},
    this.destinations = const {},
    this.routes = const {},
    this.notifications = const [],
    this.meetingPoints = const {},
    this.vehicles = const {},
    this.sosAlerts = const {},
    this.selectedMemberId,
    this.activeDestinationId,
    this.followMe = false,
    this.mapRotation = 0.0,
    this.navigationTargetId,
    this.navigationRoute,
    this.isNavigating = false,
    this.isLoadingRoute = false,
    this.selectedVehicleId,
  });

  LiveMapState copyWith({
    List<MemberLocationModel>? members,
    Map<String, Map<String, dynamic>>? presence,
    Map<String, Map<String, dynamic>>? destinations,
    Map<String, Map<String, dynamic>>? routes,
    List<Map<String, dynamic>>? notifications,
    Map<String, Map<String, dynamic>>? meetingPoints,
    Map<String, Map<String, dynamic>>? vehicles,
    Map<String, Map<String, dynamic>>? sosAlerts,
    String? selectedMemberId,
    String? activeDestinationId,
    bool? followMe,
    double? mapRotation,
    String? navigationTargetId,
    NavigationRouteModel? navigationRoute,
    bool? isNavigating,
    bool? isLoadingRoute,
    String? selectedVehicleId,
    bool clearActiveDestination = false,
  }) {
    return LiveMapState(
      members: members ?? this.members,
      presence: presence ?? this.presence,
      destinations: destinations ?? this.destinations,
      routes: routes ?? this.routes,
      notifications: notifications ?? this.notifications,
      meetingPoints: meetingPoints ?? this.meetingPoints,
      vehicles: vehicles ?? this.vehicles,
      sosAlerts: sosAlerts ?? this.sosAlerts,
      selectedMemberId: selectedMemberId ?? this.selectedMemberId,
      activeDestinationId: clearActiveDestination ? null : (activeDestinationId ?? this.activeDestinationId),
      followMe: followMe ?? this.followMe,
      mapRotation: mapRotation ?? this.mapRotation,
      navigationTargetId: navigationTargetId ?? this.navigationTargetId,
      navigationRoute: navigationRoute ?? this.navigationRoute,
      isNavigating: isNavigating ?? this.isNavigating,
      isLoadingRoute: isLoadingRoute ?? this.isLoadingRoute,
      selectedVehicleId: selectedVehicleId ?? this.selectedVehicleId,
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
        // Pick destination with lowest order or first
        final sortedKeys = dests.keys.toList()
          ..sort((a, b) {
            final orderA = dests[a]?['order'] as int? ?? 999;
            final orderB = dests[b]?['order'] as int? ?? 999;
            return orderA.compareTo(orderB);
          });
        state = state.copyWith(activeDestinationId: sortedKeys.first);
      }
    });

    final subRoutes = locationRepo.streamRoutes(tripId).listen((rts) {
      state = state.copyWith(routes: rts);
    });

    final subNotifications = locationRepo.streamNotifications(tripId).listen((notifs) {
      state = state.copyWith(notifications: notifs);
    });

    final subMeetingPoints = locationRepo.streamMeetingPoints(tripId).listen((points) {
      state = state.copyWith(meetingPoints: points);
    });

    final subVehicles = locationRepo.streamVehicles(tripId).listen((vehs) {
      state = state.copyWith(vehicles: vehs);
    });

    final subSOS = locationRepo.streamSOSAlerts(tripId).listen((alerts) {
      state = state.copyWith(sosAlerts: alerts);
    });

    ref.onDispose(() {
      subLocations.cancel();
      subPresence.cancel();
      subDestinations.cancel();
      subRoutes.cancel();
      subNotifications.cancel();
      subMeetingPoints.cancel();
      subVehicles.cancel();
      subSOS.cancel();
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

  void selectVehicle(String? vehicleId) {
    state = state.copyWith(selectedVehicleId: vehicleId);
  }

  Future<void> selectActiveDestination(String? destId) async {
    state = state.copyWith(activeDestinationId: destId);
    _hasArrived = false;
    
    if (state.isNavigating && destId != null) {
      await startNavigation(destId);
    }
  }

  /// Automatically seeds trip destination into RTDB if not present yet
  Future<void> seedTripDestinationIfNeeded({
    required String name,
    required double lat,
    required double lng,
    String? address,
  }) async {
    if (state.destinations.isEmpty) {
      await addNewDestination(name, lat, lng, address: address, order: 1);
    }
  }

  Future<void> addNewDestination(
    String name,
    double lat,
    double lng, {
    String? address,
    int? order,
  }) async {
    final destId = 'dest_${DateTime.now().millisecondsSinceEpoch}';
    final repo = ref.read(realtimeLocationRepositoryProvider);
    
    await repo.setDestination(
      tripId: tripId,
      destinationId: destId,
      name: name,
      latitude: lat,
      longitude: lng,
      address: address,
      order: order ?? (state.destinations.length + 1),
    );

    await repo.postNotification(
      tripId: tripId,
      title: 'Shared Destination Added',
      body: 'New destination added: $name 📍',
    );

    await selectActiveDestination(destId);
  }

  Future<void> removeDestination(String destId) async {
    final repo = ref.read(realtimeLocationRepositoryProvider);
    final destName = state.destinations[destId]?['name'] as String? ?? 'Destination';
    
    await repo.removeDestination(tripId, destId);
    await repo.postNotification(
      tripId: tripId,
      title: 'Destination Removed',
      body: '$destName was removed from the trip plan',
    );

    if (state.activeDestinationId == destId) {
      final remaining = state.destinations.keys.where((k) => k != destId);
      await selectActiveDestination(remaining.isNotEmpty ? remaining.first : null);
    }
  }

  // --- Meeting Points ---

  Future<void> addMeetingPoint(String name, double lat, double lng, {String? note}) async {
    final user = ref.read(authStateChangesProvider).value;
    final pointId = 'meet_${DateTime.now().millisecondsSinceEpoch}';
    final repo = ref.read(realtimeLocationRepositoryProvider);

    await repo.setMeetingPoint(
      tripId: tripId,
      meetingPointId: pointId,
      name: name,
      latitude: lat,
      longitude: lng,
      createdBy: user?.displayName ?? 'Organizer',
      note: note,
    );

    await repo.postNotification(
      tripId: tripId,
      title: '🚩 New Meeting Point Created',
      body: '$name has been added as a group rendezvous stop',
    );
  }

  Future<void> removeMeetingPoint(String pointId) async {
    await ref.read(realtimeLocationRepositoryProvider).removeMeetingPoint(tripId, pointId);
  }

  Future<void> checkInAtMeetingPoint(String pointId) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    await ref.read(realtimeLocationRepositoryProvider).checkInAtMeetingPoint(
      tripId: tripId,
      meetingPointId: pointId,
      userId: user.uid,
      userName: user.displayName.isNotEmpty ? user.displayName : 'Member',
    );
  }

  // --- Vehicle Convoy Coordination ---

  Future<void> createOrUpdateVehicle({
    required String vehicleId,
    required String name,
    required String type,
    String? driverId,
    String? driverName,
    String? colorHex,
  }) async {
    await ref.read(realtimeLocationRepositoryProvider).setVehicle(
      tripId: tripId,
      vehicleId: vehicleId,
      name: name,
      type: type,
      driverId: driverId,
      driverName: driverName,
      colorHex: colorHex,
    );
  }

  Future<void> joinVehicle(String vehicleId, String vehicleName) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    await ref.read(realtimeLocationRepositoryProvider).assignMemberToVehicle(
      tripId: tripId,
      vehicleId: vehicleId,
      userId: user.uid,
      userName: user.displayName.isNotEmpty ? user.displayName : 'Member',
      vehicleName: vehicleName,
    );
  }

  // --- Emergency SOS ---

  Future<void> triggerEmergencySOS() async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    final myLocation = state.members.firstWhereOrNull((m) => m.userId == user.uid);
    final lat = myLocation?.latitude ?? 0.0;
    final lng = myLocation?.longitude ?? 0.0;
    final battery = myLocation?.battery;

    await ref.read(realtimeLocationRepositoryProvider).triggerSOS(
      tripId: tripId,
      userId: user.uid,
      userName: user.displayName.isNotEmpty ? user.displayName : 'Member',
      latitude: lat,
      longitude: lng,
      battery: battery,
    );
  }

  Future<void> resolveEmergencySOS() async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    await ref.read(realtimeLocationRepositoryProvider).clearSOS(
      tripId: tripId,
      userId: user.uid,
    );
  }

  // --- Navigation & Routing ---

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
      await ref.read(firebaseDatabaseProvider).ref('trip_routes/$tripId/$userId').remove();
    }
    state = state.copyWith(
      navigationTargetId: null,
      navigationRoute: null,
      isNavigating: false,
      isLoadingRoute: false,
    );
  }

  void _checkArrivalAndRoute(List<MemberLocationModel> list) {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;
    final userId = user.uid;

    final myLocation = list.firstWhereOrNull((m) => m.userId == userId);
    if (myLocation == null) return;

    // 1. Geofence arrival check
    final activeDestId = state.activeDestinationId;
    if (activeDestId != null && state.destinations.containsKey(activeDestId)) {
      final dest = state.destinations[activeDestId]!;
      final destLat = dest['latitude'] as double;
      final destLng = dest['longitude'] as double;
      final destName = dest['name'] as String? ?? 'Destination';

      final distToDest = Geolocator.distanceBetween(
        myLocation.latitude,
        myLocation.longitude,
        destLat,
        destLng,
      );

      if (distToDest <= 75.0 && !_hasArrived) {
        _hasArrived = true;
        ref.read(realtimeLocationRepositoryProvider).postNotification(
          tripId: tripId,
          title: 'Member Arrived! 🏁',
          body: '${myLocation.name} reached $destName!',
        );
      }
    }

    // 2. Continuous routing recalculation
    if (state.isNavigating && state.navigationTargetId != null) {
      final currentLatLng = LatLng(myLocation.latitude, myLocation.longitude);
      final now = DateTime.now();

      final hasMoved = _lastQueryLatLng == null ||
          Geolocator.distanceBetween(
                _lastQueryLatLng!.latitude,
                _lastQueryLatLng!.longitude,
                currentLatLng.latitude,
                currentLatLng.longitude,
              ) >= 50.0;

      final isThrottleElapsed = _lastQueryTime == null ||
          now.difference(_lastQueryTime!).inSeconds >= 20;

      if (hasMoved && isThrottleElapsed) {
        _calculateAndPublishRoute(myLocation, state.navigationTargetId!);
      }
    }
  }

  Future<void> _calculateAndPublishRoute(MemberLocationModel myLocation, String targetId) async {
    double? targetLat;
    double? targetLng;

    // Check destinations
    if (state.destinations.containsKey(targetId)) {
      final dest = state.destinations[targetId]!;
      targetLat = (dest['latitude'] as num).toDouble();
      targetLng = (dest['longitude'] as num).toDouble();
    } 
    // Check meeting points
    else if (state.meetingPoints.containsKey(targetId)) {
      final point = state.meetingPoints[targetId]!;
      targetLat = (point['latitude'] as num).toDouble();
      targetLng = (point['longitude'] as num).toDouble();
    }
    // Check other members
    else {
      final targetMember = state.members.firstWhereOrNull((m) => m.userId == targetId);
      if (targetMember != null) {
        targetLat = targetMember.latitude;
        targetLng = targetMember.longitude;
      }
    }

    if (targetLat == null || targetLng == null) {
      state = state.copyWith(isLoadingRoute: false);
      return;
    }

    final currentLatLng = LatLng(myLocation.latitude, myLocation.longitude);
    _lastQueryLatLng = currentLatLng;
    _lastQueryTime = DateTime.now();

    try {
      final routeModel = await ref.read(navigationRepositoryProvider).getRoute(
        startLat: myLocation.latitude,
        startLng: myLocation.longitude,
        endLat: targetLat,
        endLng: targetLng,
      );

      state = state.copyWith(
        navigationRoute: routeModel,
        isLoadingRoute: false,
      );

      // Publish to RTDB for other convoy vehicles
      await ref.read(realtimeLocationRepositoryProvider).updateRoute(
        tripId: tripId,
        userId: myLocation.userId,
        encodedPolyline: routeModel.encodedPolyline ?? '',
        distance: routeModel.distance,
        duration: routeModel.duration,
      );
    } catch (e) {
      debugPrint("Error routing: $e");
      state = state.copyWith(isLoadingRoute: false);
    }
  }
}
