import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/navigation_repository.dart';
import '../domain/navigation_route_model.dart';

part 'navigation_repository_impl.g.dart';

@Riverpod(keepAlive: true)
NavigationRepository navigationRepository(Ref ref) {
  return NavigationRepositoryImpl();
}

class NavigationRepositoryImpl implements NavigationRepository {
  // If user provides a key, it can be set here. Fallback is active otherwise.
  static const String _orsApiKey = ""; 

  @override
  Future<NavigationRouteModel> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    final start = LatLng(startLat, startLng);
    final end = LatLng(endLat, endLng);

    if (_orsApiKey.isEmpty) {
      debugPrint("OpenRouteService API key not configured. Using fallback straight line.");
      return NavigationRouteModel.fallback(start, end);
    }

    final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/driving-car'
      '?api_key=$_orsApiKey'
      '&start=$startLng,$startLat'
      '&end=$endLng,$endLat',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List?;
        if (features != null && features.isNotEmpty) {
          final firstFeature = features[0] as Map;
          final properties = firstFeature['properties'] as Map?;
          final summary = properties != null ? properties['summary'] as Map? : null;
          final geometry = firstFeature['geometry'] as Map?;
          final coords = geometry != null ? geometry['coordinates'] as List? : null;

          if (summary != null && coords != null) {
            final distance = (summary['distance'] as num).toDouble();
            final duration = (summary['duration'] as num).toDouble();

            final List<LatLng> points = coords.map((c) {
              final pointList = c as List;
              return LatLng(
                (pointList[1] as num).toDouble(),
                (pointList[0] as num).toDouble(),
              );
            }).toList();

            final polyline = _encodePolyline(points);

            return NavigationRouteModel(
              encodedPolyline: polyline,
              distance: distance,
              duration: duration,
              coordinates: points,
            );
          }
        }
      }

      debugPrint("ORS request failed with status: ${response.statusCode}. Using fallback.");
      return NavigationRouteModel.fallback(start, end);
    } catch (e) {
      debugPrint("ORS routing request error: $e. Using fallback.");
      return NavigationRouteModel.fallback(start, end);
    }
  }

  String _encodePolyline(List<LatLng> points) {
    final StringBuffer stringBuffer = StringBuffer();
    int lastLat = 0;
    int lastLng = 0;

    void encode(int value) {
      int v = value < 0 ? ~(value << 1) : (value << 1);
      while (v >= 0x20) {
        stringBuffer.writeCharCode(((0x20 | (v & 0x1f)) + 63));
        v >>= 5;
      }
      stringBuffer.writeCharCode((v + 63));
    }

    for (final point in points) {
      final int lat = (point.latitude * 1e5).round();
      final int lng = (point.longitude * 1e5).round();
      encode(lat - lastLat);
      encode(lng - lastLng);
      lastLat = lat;
      lastLng = lng;
    }

    return stringBuffer.toString();
  }
}
