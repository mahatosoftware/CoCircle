import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/live_tracking_repository.dart';

part 'live_tracking_repository_impl.g.dart';

@Riverpod(keepAlive: true)
LiveTrackingRepository liveTrackingRepository(Ref ref) {
  return LiveTrackingRepositoryImpl();
}

class LiveTrackingRepositoryImpl implements LiveTrackingRepository {
  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  @override
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  @override
  Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (_) {
      return await Geolocator.getLastKnownPosition();
    }
  }

  @override
  Stream<Position> getPositionStream({LocationSettings? locationSettings}) {
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  @override
  Future<int?> getBatteryLevel() async {
    // Battery percentage is optional. Returns null as fallback.
    return null;
  }
}
