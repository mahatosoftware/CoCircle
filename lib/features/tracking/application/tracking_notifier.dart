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
  final String sharingStatus; // 'sharing', 'paused', 'offline'
  final DateTime? sharingExpiry;

  TrackingState({
    this.isTracking = false,
    this.tripId,
    this.lastPosition,
    this.lastWriteTime,
    this.error,
    this.sharingStatus = 'offline',
    this.sharingExpiry,
  });

  TrackingState copyWith({
    bool? isTracking,
    String? tripId,
    Position? lastPosition,
    DateTime? lastWriteTime,
    String? error,
    String? sharingStatus,
    DateTime? sharingExpiry,
    bool clearExpiry = false,
  }) {
    return TrackingState(
      isTracking: isTracking ?? this.isTracking,
      tripId: tripId ?? this.tripId,
      lastPosition: lastPosition ?? this.lastPosition,
      lastWriteTime: lastWriteTime ?? this.lastWriteTime,
      error: error ?? this.error,
      sharingStatus: sharingStatus ?? this.sharingStatus,
      sharingExpiry: clearExpiry ? null : (sharingExpiry ?? this.sharingExpiry),
    );
  }
}

@riverpod
class TrackingNotifier extends _$TrackingNotifier {
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<DatabaseEvent>? _connectionSubscription;
  Timer? _expiryTimer;
  late LiveTrackingRepository _trackingRepository;

  @override
  TrackingState build() {
    _trackingRepository = ref.watch(liveTrackingRepositoryProvider);
    ref.onDispose(() {
      _positionSubscription?.cancel();
      _connectionSubscription?.cancel();
      _expiryTimer?.cancel();
    });
    return TrackingState();
  }

  Future<void> startTracking(String tripId, {Duration? duration}) async {
    if (state.isTracking && state.tripId == tripId && state.sharingStatus == 'sharing') {
      return;
    }

    DateTime? expiry;
    if (duration != null) {
      expiry = DateTime.now().add(duration);
      _scheduleExpiry(duration);
    }
    
    state = state.copyWith(
      isTracking: false,
      tripId: tripId,
      error: null,
      sharingStatus: 'sharing',
      sharingExpiry: expiry,
    );

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
    final sharingStatusRef = ref.read(firebaseDatabaseProvider).ref('trip_locations/$tripId/members/$userId/sharingStatus');

    // On disconnect, mark offline and lastSeen
    await presenceRef.onDisconnect().set({
      'online': false,
      'lastSeen': ServerValue.timestamp,
    });
    await locationOnlineRef.onDisconnect().set(false);
    await sharingStatusRef.onDisconnect().set('offline');

    // Set online = true initially
    await presenceRef.set({
      'online': true,
      'lastSeen': ServerValue.timestamp,
    });
    await sharingStatusRef.set('sharing');

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
          await sharingStatusRef.set(state.sharingStatus);
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
          notificationText: "CoCircle is sharing your live location with your group",
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

    state = state.copyWith(isTracking: true, sharingStatus: 'sharing');

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

  Future<void> pauseTracking() async {
    if (!state.isTracking) return;

    _positionSubscription?.cancel();
    _positionSubscription = null;

    final tripId = state.tripId;
    final user = ref.read(authStateChangesProvider).value;
    if (tripId != null && user != null) {
      final userId = user.uid;
      await ref.read(firebaseDatabaseProvider)
          .ref('trip_locations/$tripId/members/$userId/sharingStatus')
          .set('paused');
    }

    state = state.copyWith(sharingStatus: 'paused');
  }

  Future<void> resumeTracking() async {
    if (!state.isTracking || state.tripId == null) return;
    await startTracking(state.tripId!, duration: state.sharingExpiry?.difference(DateTime.now()));
  }

  Future<void> stopTracking() async {
    if (!state.isTracking) return;

    final tripId = state.tripId;
    final user = ref.read(authStateChangesProvider).value;
    
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _connectionSubscription?.cancel();
    _connectionSubscription = null;
    _expiryTimer?.cancel();
    _expiryTimer = null;

    if (tripId != null && user != null) {
      final userId = user.uid;
      final presenceRef = ref.read(firebaseDatabaseProvider).ref('trip_presence/$tripId/$userId');
      final locationOnlineRef = ref.read(firebaseDatabaseProvider).ref('trip_locations/$tripId/members/$userId/online');
      final sharingStatusRef = ref.read(firebaseDatabaseProvider).ref('trip_locations/$tripId/members/$userId/sharingStatus');

      // Cancel disconnect handlers
      await presenceRef.onDisconnect().cancel();
      await locationOnlineRef.onDisconnect().cancel();
      await sharingStatusRef.onDisconnect().cancel();

      // Set status offline
      await presenceRef.set({
        'online': false,
        'lastSeen': ServerValue.timestamp,
      });
      await locationOnlineRef.set(false);
      await sharingStatusRef.set('offline');
    }

    state = TrackingState();
  }

  void _scheduleExpiry(Duration duration) {
    _expiryTimer?.cancel();
    _expiryTimer = Timer(duration, () {
      debugPrint("Location sharing period expired automatically.");
      stopTracking();
    });
  }

  void _handlePositionUpdate(Position position) {
    if (state.sharingStatus == 'paused') return;

    final lastPos = state.lastPosition;
    final lastTime = state.lastWriteTime;
    final now = DateTime.now();

    if (lastPos == null || lastTime == null) {
      _publishLocation(position);
      state = state.copyWith(lastPosition: position, lastWriteTime: now);
      return;
    }

    // Battery & Network Optimization rules:
    final distanceMoved = Geolocator.distanceBetween(
      lastPos.latitude,
      lastPos.longitude,
      position.latitude,
      position.longitude,
    );

    final secondsElapsed = now.difference(lastTime).inSeconds;

    // Rule 1: Immediately update if moved more than 20 meters
    final movedSignificantly = distanceMoved >= 20.0;

    // Rule 2: Every 10 seconds if user is moving (speed > 0.4 m/s)
    final movingAndIntervalReached = secondsElapsed >= 10 && position.speed > 0.4;

    // Rule 3: Heartbeat update every 60 seconds even if stationary
    final heartbeatReached = secondsElapsed >= 60;

    if (movedSignificantly || movingAndIntervalReached || heartbeatReached) {
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

      final snapshot = await memberRef.get();
      String? currentVehicleId;
      String? currentVehicleName;
      String? currentDestinationId;
      bool isEmergency = false;

      if (snapshot.exists) {
        final data = snapshot.value as Map?;
        if (data != null) {
          currentVehicleId = data['vehicleId'] as String?;
          currentVehicleName = data['vehicleName'] as String?;
          currentDestinationId = data['destinationId'] as String?;
          isEmergency = data['isEmergency'] as bool? ?? false;
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
        'sharingStatus': state.sharingStatus,
        'isEmergency': isEmergency,
        'lastUpdated': ServerValue.timestamp,
        if (currentVehicleId != null) 'vehicleId': currentVehicleId,
        if (currentVehicleName != null) 'vehicleName': currentVehicleName,
        if (currentDestinationId != null) 'destinationId': currentDestinationId,
      });
      debugPrint("Published location to RTDB: ${position.latitude}, ${position.longitude}");
    } catch (e, stack) {
      debugPrint("Error publishing location to RTDB: $e");
      debugPrint("Stack trace: $stack");
    }
  }

  Future<void> updateVehicleAssignment(String vehicleId, {String? vehicleName}) async {
    final tripId = state.tripId;
    final user = ref.read(authStateChangesProvider).value;
    if (tripId == null || user == null) return;

    final userId = user.uid;
    await ref.read(firebaseDatabaseProvider).ref('trip_locations/$tripId/members/$userId').update({
      'vehicleId': vehicleId,
      if (vehicleName != null) 'vehicleName': vehicleName,
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
