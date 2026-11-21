import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Configuration and theme styling for Google Maps across CoCircle.
class GoogleMapsConfig {
  /// Compile-time Google Maps API key passed via `--dart-define=MAPS_API_KEY=your_key`.
  static const String apiKey =
      String.fromEnvironment('MAPS_API_KEY', defaultValue: '');

  /// Default camera center (Bengaluru, India) for fallback positioning.
  static const LatLng defaultLocation = LatLng(12.9716, 77.5946);

  /// Sleek, modern dark-mode style JSON for Google Maps matching CoCircle's dark palette.
  static const String darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#1e293b"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#94a3b8"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#0f172a"}]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#e2e8f0"}]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#cbd5e1"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [{"color": "#14532d"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{"color": "#334155"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#1e293b"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{"color": "#6366f1"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#4338ca"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#0f172a"}]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#64748b"}]
  }
]
''';

  /// Returns dark map style string if [isDark] is true, otherwise null.
  static String? getMapStyle(bool isDark) => isDark ? darkMapStyle : null;
}
