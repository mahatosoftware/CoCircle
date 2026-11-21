import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigationHelper {
  /// Launches turn-by-turn navigation to the given [latitude] and [longitude].
  /// On iOS, tries Apple Maps then Google Maps.
  /// On Android / other platforms, uses Google Maps navigation intent.
  static Future<bool> launchNavigation({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final encodedLabel = Uri.encodeComponent(label ?? 'Destination');

    // 1. Apple Maps scheme for iOS
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final appleMapsUri = Uri.parse(
        'https://maps.apple.com/?daddr=$latitude,$longitude&dirflg=d&q=$encodedLabel',
      );
      if (await canLaunchUrl(appleMapsUri)) {
        return await launchUrl(appleMapsUri, mode: LaunchMode.externalApplication);
      }
    }

    // 2. Google Maps Navigation Intent (Android and Universal)
    final googleMapsDirectionsUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving',
    );

    if (await canLaunchUrl(googleMapsDirectionsUri)) {
      return await launchUrl(
        googleMapsDirectionsUri,
        mode: LaunchMode.externalApplication,
      );
    }

    // 3. Fallback generic geo URI
    final geoUri = Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude($encodedLabel)');
    if (await canLaunchUrl(geoUri)) {
      return await launchUrl(geoUri, mode: LaunchMode.externalApplication);
    }

    debugPrint('Could not launch any navigation app for $latitude, $longitude');
    return false;
  }
}
