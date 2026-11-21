import 'package:cocircle/features/road_trip/infrastructure/photon_geocoding_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhotonGeocodingService Model Tests', () {
    test('PhotonPlace.fromJson parses FeatureCollection feature correctly', () {
      final sampleJson = {
        'properties': {
          'name': 'Bengaluru',
          'city': 'Bangalore Urban',
          'state': 'Karnataka',
          'country': 'India',
          'postcode': '560001',
        },
        'geometry': {
          'coordinates': [77.5946, 12.9716],
        },
      };

      final place = PhotonPlace.fromJson(sampleJson);
      expect(place.name, 'Bengaluru');
      expect(place.latitude, 12.9716);
      expect(place.longitude, 77.5946);
      expect(place.state, 'Karnataka');
      expect(place.country, 'India');
      expect(place.displayName, contains('Bengaluru'));
      expect(place.displayName, contains('Karnataka'));
    });
  });
}
