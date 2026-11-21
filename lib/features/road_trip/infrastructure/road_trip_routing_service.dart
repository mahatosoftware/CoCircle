import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/road_trip_route_model.dart';

class RouteCalculationResult {
  final double totalDistanceKm;
  final int estimatedDurationMinutes;
  final List<LatLng> polylinePoints;
  final List<double> legDistancesKm;
  final List<int> legDurationsMinutes;
  final bool isFromApi;

  const RouteCalculationResult({
    required this.totalDistanceKm,
    required this.estimatedDurationMinutes,
    required this.polylinePoints,
    required this.legDistancesKm,
    required this.legDurationsMinutes,
    required this.isFromApi,
  });
}

class RoadTripRoutingService {
  final http.Client? _client;
  final Map<String, RouteCalculationResult> _cache = {};

  RoadTripRoutingService({http.Client? client}) : _client = client;

  http.Client get client => _client ?? http.Client();

  /// Calculates the complete multi-stop route connecting origin -> stops -> destination (and optional return)
  Future<RouteCalculationResult> calculateRoute({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
    double? returnDestinationLat,
    double? returnDestinationLng,
    List<RouteStopModel> intermediateStops = const [],
    TravelMode mode = TravelMode.car,
    bool forceRefresh = false,
  }) async {
    // 1. Assemble coordinates in traversal order
    final coordinates = <LatLng>[];
    coordinates.add(LatLng(originLat, originLng));

    // Sort intermediate stops by sequence
    final sortedStops = List<RouteStopModel>.from(intermediateStops)
      ..sort((a, b) => a.sequence.compareTo(b.sequence));

    for (final s in sortedStops) {
      coordinates.add(LatLng(s.latitude, s.longitude));
    }

    coordinates.add(LatLng(destinationLat, destinationLng));

    if (returnDestinationLat != null && returnDestinationLng != null) {
      coordinates.add(LatLng(returnDestinationLat, returnDestinationLng));
    }

    // 2. Check memory cache
    final cacheKey = _buildCacheKey(coordinates, mode);
    if (!forceRefresh && _cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    // 3. Attempt OSRM public routing API
    try {
      final osrmProfile = mode == TravelMode.motorcycle ? 'driving' : 'driving';
      // Format coordinates for OSRM: {longitude},{latitude};{longitude},{latitude}
      final coordsParam = coordinates.map((c) => '${c.longitude},${c.latitude}').join(';');
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/$osrmProfile/$coordsParam?overview=full&geometries=geojson&steps=false',
      );

      final response = await client.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['code'] == 'Ok' && (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0] as Map<String, dynamic>;
          final distanceMeters = (route['distance'] as num).toDouble();
          final durationSeconds = (route['duration'] as num).toDouble();

          final geometry = route['geometry'] as Map<String, dynamic>;
          final rawCoords = geometry['coordinates'] as List<dynamic>;
          final polyline = rawCoords.map<LatLng>((coord) {
            final lng = (coord[0] as num).toDouble();
            final lat = (coord[1] as num).toDouble();
            return LatLng(lat, lng);
          }).toList();

          final legs = route['legs'] as List<dynamic>? ?? [];
          final legDists = legs.map((l) => ((l['distance'] as num).toDouble()) / 1000.0).toList();
          final legDurs = legs.map((l) => (((l['duration'] as num).toDouble()) / 60.0).round()).toList();

          final result = RouteCalculationResult(
            totalDistanceKm: (distanceMeters / 1000.0).roundToDouble(),
            estimatedDurationMinutes: (durationSeconds / 60.0).round(),
            polylinePoints: polyline,
            legDistancesKm: legDists,
            legDurationsMinutes: legDurs,
            isFromApi: true,
          );

          _cache[cacheKey] = result;
          return result;
        }
      }
    } catch (e) {
      debugPrint('OSRM routing request failed or timed out: $e. Falling back to robust Haversine calculation.');
    }

    // 4. Offline Fallback: Haversine distance with 1.25 road curvature factor
    final fallbackResult = calculateOfflineHaversineRoute(coordinates);
    _cache[cacheKey] = fallbackResult;
    return fallbackResult;
  }

  /// Builds Google Maps directions Uri with all multi-stop waypoints
  static Uri buildGoogleMapsNavigationUri({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
    List<RouteStopModel> waypoints = const [],
    TravelMode mode = TravelMode.car,
  }) {
    final originStr = '$originLat,$originLng';
    final destStr = '$destinationLat,$destinationLng';

    final waypointsParam = waypoints
        .map((w) => '${w.latitude},${w.longitude}')
        .join('|');

    String travelModeParam = 'driving';
    if (mode == TravelMode.motorcycle) travelModeParam = 'two-wheeler';

    final queryParams = <String, String>{
      'api': '1',
      'origin': originStr,
      'destination': destStr,
      'travelmode': travelModeParam,
    };

    if (waypointsParam.isNotEmpty) {
      queryParams['waypoints'] = waypointsParam;
    }

    return Uri.https('www.google.com', '/maps/dir/', queryParams);
  }

  /// Launches Google Maps with all multi-stop waypoints for turn-by-turn navigation
  static Future<bool> launchMultiStopGoogleMaps({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
    List<RouteStopModel> waypoints = const [],
    TravelMode mode = TravelMode.car,
  }) async {
    final uri = buildGoogleMapsNavigationUri(
      originLat: originLat,
      originLng: originLng,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
      waypoints: waypoints,
      mode: mode,
    );

    // 1. Try launching in Google Maps app / external app directly
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (launched) return true;
    } catch (e) {
      debugPrint('External Google Maps launch failed, falling back: $e');
    }

    // 2. Fallback to platform default browser / viewer
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      if (launched) return true;
    } catch (e) {
      debugPrint('Platform default launch failed: $e');
    }

    // 3. Fallback geo URI if waypoints are empty
    if (waypoints.isEmpty) {
      try {
        final geoUri = Uri.parse('geo:$destinationLat,$destinationLng?q=$destinationLat,$destinationLng');
        return await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }

    return false;
  }

  // --- Offline Haversine Math ---
  static RouteCalculationResult calculateOfflineHaversineRoute(List<LatLng> points) {
    if (points.length < 2) {
      return RouteCalculationResult(
        totalDistanceKm: 0.0,
        estimatedDurationMinutes: 0,
        polylinePoints: points,
        legDistancesKm: const [],
        legDurationsMinutes: const [],
        isFromApi: false,
      );
    }

    double totalDist = 0.0;
    int totalDur = 0;
    final legDists = <double>[];
    final legDurs = <int>[];

    // Curvature multiplier: Road distance is typically 1.22x to 1.3x straight-line distance
    const curvatureMultiplier = 1.25;
    // Estimated average road trip speed: 55 km/h
    const averageSpeedKmH = 55.0;

    for (int i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      final haversine = haversineDistanceKm(a.latitude, a.longitude, b.latitude, b.longitude);
      final roadDist = haversine * curvatureMultiplier;
      final legMinutes = ((roadDist / averageSpeedKmH) * 60).round();

      legDists.add((roadDist * 10).round() / 10.0);
      legDurs.add(legMinutes);

      totalDist += roadDist;
      totalDur += legMinutes;
    }

    return RouteCalculationResult(
      totalDistanceKm: (totalDist * 10).round() / 10.0,
      estimatedDurationMinutes: totalDur,
      polylinePoints: points, // Straight connected legs as fallback polyline
      legDistancesKm: legDists,
      legDurationsMinutes: legDurs,
      isFromApi: false,
    );
  }

  static double haversineDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0; // Earth's radius in kilometers
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) * math.cos(_deg2rad(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  static double _deg2rad(double deg) => deg * (math.pi / 180.0);

  static String _buildCacheKey(List<LatLng> coords, TravelMode mode) {
    return '${mode.name}_${coords.map((c) => "${c.latitude.toStringAsFixed(4)},${c.longitude.toStringAsFixed(4)}").join("|")}';
  }
}
