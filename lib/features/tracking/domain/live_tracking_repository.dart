import 'package:geolocator/geolocator.dart';

abstract class LiveTrackingRepository {
  Future<bool> isLocationServiceEnabled();
  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();
  Future<Position?> getCurrentPosition();
  Stream<Position> getPositionStream({LocationSettings? locationSettings});
  Future<int?> getBatteryLevel();
}
