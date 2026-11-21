import 'package:flutter_map/flutter_map.dart';

/// Configuration for OpenStreetMap & free map tile providers in flutter_map.
///
/// Features:
/// - 100% Free OpenStreetMap raster tiles with NO API key and NO watermarks.
/// - Built-in dark mode tile builder that inverts OSM tiles without requiring third-party API keys.
/// - Optional CARTO key support ONLY if explicitly configured with a non-empty key.
class MapTileConfig {
  /// Optional CARTO API key (free at https://carto.com/basemaps/apikey).
  /// If unset, the app uses standard, crystal-clear OpenStreetMap tiles with ZERO watermarks.
  static const String cartoApiKey =
      String.fromEnvironment('CARTO_API_KEY', defaultValue: '');

  /// Standard OpenStreetMap raster tiles (100% free, NO API key, ZERO watermarks).
  static const String osm = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Humanitarian OpenStreetMap raster tiles (Pastel road trip colors, zero watermarks).
  static const String osmHot = 'https://tile.openstreetmap.fr/hot/{z}/{x}/{y}.png';

  /// CARTO Voyager (Only used if cartoApiKey is provided; otherwise defaults to clean OSM).
  static String get voyager => cartoApiKey.isNotEmpty
      ? 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png?key=$cartoApiKey'
      : osm;

  /// CARTO Positron (Only used if cartoApiKey is provided; otherwise defaults to clean OSM).
  static String get positron => cartoApiKey.isNotEmpty
      ? 'https://{s}.basemaps.cartocdn.com/rastertiles/light_all/{z}/{x}/{y}.png?key=$cartoApiKey'
      : osm;

  /// CARTO Dark Matter (Only used if cartoApiKey is provided; otherwise defaults to clean OSM).
  static String get darkMatter => cartoApiKey.isNotEmpty
      ? 'https://{s}.basemaps.cartocdn.com/rastertiles/dark_all/{z}/{x}/{y}.png?key=$cartoApiKey'
      : osm;

  /// OpenFreeMap Style JSON endpoints (open-source vector styles).
  static const String openFreeMapLiberty = 'https://tiles.openfreemap.org/styles/liberty';
  static const String openFreeMapBright = 'https://tiles.openfreemap.org/styles/bright';
  static const String openFreeMapPositron = 'https://tiles.openfreemap.org/styles/positron';

  /// Returns clean, watermark-free tile URL template.
  /// If no CARTO API key is provided, ALWAYS returns standard OpenStreetMap so that
  /// NO "API KEY REQUIRED" watermark appears anywhere on the map!
  static String getUrlTemplate({bool isDark = false, bool isClean = false}) {
    if (cartoApiKey.isNotEmpty) {
      if (isDark) return darkMatter;
      if (isClean) return positron;
      return voyager;
    }
    // Default to clean OSM tiles: 100% free, NO watermark, NO API key required.
    return osm;
  }

  /// Dark mode tile builder for TileLayer that simulates dark mode cleanly
  /// without requiring paid dark tile services.
  static TileBuilder? getTileBuilder({bool isDark = false}) {
    if (cartoApiKey.isNotEmpty) return null; // Carto Dark Matter already dark
    return isDark ? darkModeTileBuilder : null;
  }

  /// Subdomains for tile servers (if applicable).
  static const List<String> subdomains = ['a', 'b', 'c'];

  /// App user agent package name required by OSM tile servers.
  static const String userAgentPackageName = 'in.mahato.cocircle';
}
