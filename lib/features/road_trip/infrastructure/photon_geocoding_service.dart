import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final photonGeocodingServiceProvider = Provider<PhotonGeocodingService>((ref) {
  return PhotonGeocodingService();
});

/// Represents a geographic place returned by the Photon / Nominatim (OpenStreetMap) geocoding API.
class PhotonPlace {
  final String name;
  final String displayName;
  final double latitude;
  final double longitude;
  final String? city;
  final String? state;
  final String? country;
  final String? postcode;

  const PhotonPlace({
    required this.name,
    required this.displayName,
    required this.latitude,
    required this.longitude,
    this.city,
    this.state,
    this.country,
    this.postcode,
  });

  factory PhotonPlace.fromJson(Map<String, dynamic> json) {
    final properties = json['properties'] as Map<String, dynamic>? ?? {};
    final geometry = json['geometry'] as Map<String, dynamic>? ?? {};
    final coordinates = geometry['coordinates'] as List<dynamic>? ?? [0.0, 0.0];

    final lon = (coordinates[0] as num).toDouble();
    final lat = (coordinates[1] as num).toDouble();

    final name = (properties['name'] as String?) ?? 'Unknown';
    final city = (properties['city'] as String?) ?? (properties['county'] as String?);
    final state = properties['state'] as String?;
    final country = properties['country'] as String?;
    final postcode = properties['postcode'] as String?;

    final parts = [name, city, state, country].where((p) => p != null && p.isNotEmpty).toSet();
    final displayName = parts.join(', ');

    return PhotonPlace(
      name: name,
      displayName: displayName,
      latitude: lat,
      longitude: lon,
      city: city,
      state: state,
      country: country,
      postcode: postcode,
    );
  }

  @override
  String toString() => displayName;
}

/// Free, open-source geocoding service backed by Komoot Photon & OpenStreetMap Nominatim.
/// Requires NO API keys and has zero rate limit configuration.
class PhotonGeocodingService {
  final http.Client? _client;

  PhotonGeocodingService({http.Client? client}) : _client = client;

  http.Client get client => _client ?? http.Client();

  /// Forward geocode query text to place suggestions with coordinates.
  /// First tries Photon (fast, typo-tolerant); seamlessly falls back to Nominatim (all streets, pin codes).
  Future<List<PhotonPlace>> search(
    String query, {
    int limit = 6,
    double? biasLat,
    double? biasLng,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    // 1. Try Photon first
    try {
      final queryParams = <String, String>{
        'q': trimmed,
        'limit': limit.toString(),
      };
      if (biasLat != null && biasLng != null) {
        queryParams['lat'] = biasLat.toString();
        queryParams['lon'] = biasLng.toString();
      }

      final uri = Uri.https('photon.komoot.io', '/api/', queryParams);
      final res = await client.get(uri).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final features = data['features'] as List<dynamic>? ?? [];
        if (features.isNotEmpty) {
          return features.map((f) => PhotonPlace.fromJson(f as Map<String, dynamic>)).toList();
        }
      }
    } catch (e) {
      debugPrint('Photon geocoding error for "$query": $e');
    }

    // 2. Seamless Fallback: Official OpenStreetMap Nominatim
    try {
      final nomUri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': trimmed,
        'format': 'json',
        'limit': limit.toString(),
        'addressdetails': '1',
      });
      final nomRes = await client.get(
        nomUri,
        headers: {'User-Agent': 'in.mahato.cocircle/1.0 (mahatosoftware@gmail.com)'},
      ).timeout(const Duration(seconds: 5));

      if (nomRes.statusCode == 200) {
        final list = json.decode(utf8.decode(nomRes.bodyBytes)) as List<dynamic>? ?? [];
        if (list.isNotEmpty) {
          return list.map<PhotonPlace>((item) {
            final m = item as Map<String, dynamic>;
            final lat = double.tryParse(m['lat']?.toString() ?? '0') ?? 0.0;
            final lon = double.tryParse(m['lon']?.toString() ?? '0') ?? 0.0;
            final name = (m['name'] as String?)?.isNotEmpty == true
                ? m['name'] as String
                : (m['display_name'] as String).split(',').first.trim();
            final displayName = (m['display_name'] as String?) ?? name;
            final addr = m['address'] as Map<String, dynamic>? ?? {};

            return PhotonPlace(
              name: name,
              displayName: displayName,
              latitude: lat,
              longitude: lon,
              city: addr['city'] as String? ?? addr['town'] as String? ?? addr['village'] as String?,
              state: addr['state'] as String?,
              country: addr['country'] as String?,
              postcode: addr['postcode'] as String?,
            );
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('Nominatim geocoding fallback error for "$query": $e');
    }

    return [];
  }

  /// Reverse geocode coordinates into a structured location name.
  Future<PhotonPlace?> reverse(double lat, double lng) async {
    // 1. Try Photon reverse
    try {
      final uri = Uri.https('photon.komoot.io', '/reverse', {
        'lat': lat.toString(),
        'lon': lng.toString(),
      });
      final res = await client.get(uri).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final features = data['features'] as List<dynamic>? ?? [];
        if (features.isNotEmpty) {
          return PhotonPlace.fromJson(features.first as Map<String, dynamic>);
        }
      }
    } catch (_) {}

    // 2. Fallback Nominatim reverse
    try {
      final nomUri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'lat': lat.toString(),
        'lon': lng.toString(),
        'format': 'json',
      });
      final nomRes = await client.get(
        nomUri,
        headers: {'User-Agent': 'in.mahato.cocircle/1.0 (mahatosoftware@gmail.com)'},
      ).timeout(const Duration(seconds: 5));
      if (nomRes.statusCode == 200) {
        final m = json.decode(utf8.decode(nomRes.bodyBytes)) as Map<String, dynamic>;
        final displayName = (m['display_name'] as String?) ?? 'Current Location';
        final name = (m['name'] as String?)?.isNotEmpty == true
            ? m['name'] as String
            : displayName.split(',').first.trim();
        return PhotonPlace(
          name: name,
          displayName: displayName,
          latitude: lat,
          longitude: lng,
        );
      }
    } catch (_) {}

    return PhotonPlace(
      name: 'Current Location',
      displayName: 'Location (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})',
      latitude: lat,
      longitude: lng,
    );
  }
}
