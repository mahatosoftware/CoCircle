import 'package:latlong2/latlong.dart';

class NavigationRouteModel {
  final String? encodedPolyline;
  final double distance; // meters
  final double duration; // seconds
  final List<LatLng> coordinates;

  NavigationRouteModel({
    this.encodedPolyline,
    required this.distance,
    required this.duration,
    required this.coordinates,
  });

  factory NavigationRouteModel.fallback(LatLng start, LatLng end) {
    // Geodesic distance in meters as fallback
    final double distance = const Distance().as(LengthUnit.Meter, start, end);
    // Assumed speed of 50 km/h (13.88 m/s)
    final double duration = distance / 13.88;
    return NavigationRouteModel(
      encodedPolyline: null,
      distance: distance,
      duration: duration,
      coordinates: [start, end],
    );
  }
}
