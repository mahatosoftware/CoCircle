import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/data/auth_repository_impl.dart';
import 'package:cocircle/core/config/firebase_providers.dart';
import '../data/live_tracking_repository_impl.dart';
import '../domain/live_tracking_repository.dart';

part 'tracking_notifier.g.dart';

class TrackingState {
  final bool isTracking;
  final String? tripId;
  final Position? lastPosition;
  final DateTime? lastWriteTime;
  final String? error;

  TrackingState({
    this.isTracking = false,
    this.tripId,
    this.lastPosition,
    this.lastWriteTime,
    this.error,
  });

  TrackingState copyWith({
    bool? isTracking,
    String? tripId,
    Position? lastPosition,
    DateTime? lastWriteTime,
    String? error,
  }) {
    return TrackingState(
      isTracking: isTracking ?? this.isTracking,
      tripId: tripId ?? this.tripId,
      lastPosition: lastPosition ?? this.lastPosition,
      lastWriteTime: lastWriteTime ?? this.lastWriteTime,
      error: error ?? this.error,
    );
  }
}

@riverpod
class TrackingNotifier extends _$TrackingNotifier {
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<DatabaseEvent>? _connectionSubscription;
  late LiveTrackingRepository _trackingRepository;

  @override
  TrackingState build() {
    _trackingRepository = ref.watch(liveTrackingRepositoryProvider);
    ref.onDispose(() {
      _positionSubscription?.cancel();
      _connectionSubscription?.cancel();
    });
    return TrackingState();
  }

  Future<void> startTracking(String tripId) async {
    if (state.isTracking && state.tripId == tripId) return;
    
    state = state.copyWith(isTracking: false, tripId: tripId, error: null);

    // 1. Check services and permissions
    final enabled = await _trackingRepository.isLocationServiceEnabled();
    if (!enabled) {
      state = state.copyWith(error: 'Location services are disabled.');
      return;
    }

    var permission = await _trackingRepository.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _trackingRepository.requestPermission();
      if (permission == LocationPermission.denied) {
        state = state.copyWith(error: 'Location permission denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      state = state.copyWith(error: 'Location permissions are permanently denied.');
      return;
    }

    // 2. Set up presence disconnect rules in Firebase Realtime Database
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) {
      state = state.copyWith(error: 'User not authenticated.');
      return;
    }

    final userId = user.uid;
    final presenceRef = ref.read(firebaseDatabaseProvider).ref('trip_presence/$tripId/$userId');
    final locationOnlineRef = ref.read(firebaseDatabaseProvider).ref('trip_locations/$tripId/members/$userId/online');

    // On disconnect, mark offline and lastSeen
    await presenceRef.onDisconnect().set({
      'online': false,
      'lastSeen': ServerValue.timestamp,
    });
    await locationOnlineRef.onDisconnect().set(false);

    // Set online = true initially
    await presenceRef.set({
      'online': true,
      'lastSeen': ServerValue.timestamp,
    });

    // Listen to connection state to auto-toggle online status
    _connectionSubscription?.cancel();
    _connectionSubscription = ref.read(firebaseDatabaseProvider).ref('.info/connected').onValue.listen((event) async {
      final connected = event.snapshot.value as bool? ?? false;
      if (connected) {
        await presenceRef.set({
          'online': true,
          'lastSeen': ServerValue.timestamp,
        });
        if (state.isTracking) {
          await locationOnlineRef.set(true);
        }
      }
    });

    // 3. Configure geolocator stream settings based on platform
    late LocationSettings locationSettings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
        intervalDuration: const Duration(seconds: 5),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText: "CoCircle is sharing your live location in the background",
          notificationTitle: "Live Location Active",
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
        activityType: ActivityType.fitness,
        pauseLocationUpdatesAutomatically: true,
        showBackgroundLocationIndicator: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      );
    }

    // 4. Start listening to position stream
    _positionSubscription?.cancel();
    _positionSubscription = _trackingRepository.getPositionStream(locationSettings: locationSettings).listen(
      (position) {
        _handlePositionUpdate(position);
      },
      onError: (err) {
        state = state.copyWith(error: err.toString());
      },
    );

    // Set tracking status true immediately to not block the UI or stream initiation
    state = state.copyWith(isTracking: true);

    // Fetch and publish first position asynchronously in the background
    _trackingRepository.getCurrentPosition().then((initialPos) {
      if (initialPos != null) {
        _publishLocation(initialPos);
        state = state.copyWith(
          lastPosition: initialPos,
          lastWriteTime: DateTime.now(),
        );
      }
    }).catchError((err) {
      debugPrint("Failed to get initial position: $err");
    });
  }

  Future<void> stopTracking() async {
    if (!state.isTracking) return;

    final tripId = state.tripId;
    final user = ref.read(authStateChangesProvider).value;
    
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _connectionSubscription?.cancel();
    _connectionSubscription = null;

    if (tripId != null && user != null) {
      final userId = user.uid;
      final presenceRef = ref.read(firebaseDatabaseProvider).ref('trip_presence/$tripId/$userId');
      final locationOnlineRef = ref.read(firebaseDatabaseProvider).ref('trip_locations/$tripId/members/$userId/online');

      // Cancel disconnect handlers
      await presenceRef.onDisconnect().cancel();
      await locationOnlineRef.onDisconnect().cancel();

      // Set status offline
      await presenceRef.set({
        'online': false,
        'lastSeen': ServerValue.timestamp,
      });
      await locationOnlineRef.set(false);
    }

    state = TrackingState();
  }

  void _handlePositionUpdate(Position position) {
    final lastPos = state.lastPosition;
    final lastTime = state.lastWriteTime;
    final now = DateTime.now();

    if (lastPos == null || lastTime == null) {
      _publishLocation(position);
      state = state.copyWith(lastPosition: position, lastWriteTime: now);
      return;
    }

    // Battery & Network Optimization rules:
    // Calculate distance moved in meters
    final distanceMoved = Geolocator.distanceBetween(
      lastPos.latitude,
      lastPos.longitude,
      position.latitude,
      position.longitude,
    );

    final secondsElapsed = now.difference(lastTime).inSeconds;

    // Rule 1: Immediately update if moved more than 25 meters
    final movedSignificantly = distanceMoved >= 25.0;

    // Rule 2: Every 12-15 seconds if the user is moving (speed > 0.4 m/s)
    final movingAndIntervalReached = secondsElapsed >= 12 && position.speed > 0.4;

    if (movedSignificantly || movingAndIntervalReached) {
      _publishLocation(position);
      state = state.copyWith(lastPosition: position, lastWriteTime: now);
    }
  }

  Future<void> _publishLocation(Position position) async {
    final tripId = state.tripId;
    final user = ref.read(authStateChangesProvider).value;
    if (tripId == null || user == null) return;

    final userId = user.uid;
    try {
      final memberRef = ref.read(firebaseDatabaseProvider).ref('trip_locations/$tripId/members/$userId');

      final battery = await _trackingRepository.getBatteryLevel();

      // Fetch current vehicle and destination id from the database, to avoid overwriting them
      final snapshot = await memberRef.get();
      String? currentVehicleId;
      String? currentDestinationId;
      if (snapshot.exists) {
        final data = snapshot.value as Map?;
        if (data != null) {
          currentVehicleId = data['vehicleId'] as String?;
          currentDestinationId = data['destinationId'] as String?;
        }
      }

      await memberRef.update({
        'name': user.displayName,
        'photoUrl': user.photoUrl,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'heading': position.heading,
        'speed': position.speed,
        'accuracy': position.accuracy,
        'battery': battery,
        'online': true,
        'lastUpdated': ServerValue.timestamp,
        if (currentVehicleId != null) 'vehicleId': currentVehicleId,
        if (currentDestinationId != null) 'destinationId': currentDestinationId,
      });
      debugPrint("Successfully published location to RTDB: ${position.latitude}, ${position.longitude}");
    } catch (e, stack) {
      debugPrint("Error publishing location to RTDB: $e");
      debugPrint("Stack trace: $stack");
    }
  }

  Future<void> updateVehicleAssignment(String vehicleId) async {
    final tripId = state.tripId;
    final user = ref.read(authStateChangesProvider).value;
    if (tripId == null || user == null) return;

    final userId = user.uid;
    await ref.read(firebaseDatabaseProvider).ref('trip_locations/$tripId/members/$userId').update({
      'vehicleId': vehicleId,
    });
  }

  Future<void> updateActiveDestination(String destinationId) async {
    final tripId = state.tripId;
    final user = ref.read(authStateChangesProvider).value;
    if (tripId == null || user == null) return;

    final userId = user.uid;
    await ref.read(firebaseDatabaseProvider).ref('trip_locations/$tripId/members/$userId').update({
      'destinationId': destinationId,
    });
  }
}
