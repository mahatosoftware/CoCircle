/// Configuration for OpenStreetMap & Carto map tile providers in flutter_map.
///
/// Features:
/// - 100% Free OpenStreetMap raster tiles with NO API key and NO watermarks.
/// - Optional CARTO key support for Voyager/Positron/Dark Matter if configured.
class MapTileConfig {
  /// Optional CARTO API key (free at https://carto.com/basemaps/apikey).
  /// If unset, the app uses standard, crystal-clear OpenStreetMap tiles with zero watermarks.
  static const String cartoApiKey =
      String.fromEnvironment('CARTO_API_KEY', defaultValue: '');

  /// Standard OpenStreetMap raster tiles (100% free, no API key, no watermark).
  static const String osm = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// CARTO Voyager (Travel / Road-trip style).
  static String get voyager => cartoApiKey.isNotEmpty
      ? 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png?key=$cartoApiKey'
      : osm;

  /// CARTO Positron (Clean light style).
  static String get positron => cartoApiKey.isNotEmpty
      ? 'https://{s}.basemaps.cartocdn.com/rastertiles/light_all/{z}/{x}/{y}.png?key=$cartoApiKey'
      : osm;

  /// CARTO Dark Matter (Dark mode style).
  static String get darkMatter => cartoApiKey.isNotEmpty
      ? 'https://{s}.basemaps.cartocdn.com/rastertiles/dark_all/{z}/{x}/{y}.png?key=$cartoApiKey'
      : osm;

  /// Returns the recommended tile URL template.
  /// If no CARTO API key is provided, defaults to standard OpenStreetMap so that
  /// no "API KEY REQUIRED" watermark appears on the map.
  static String getUrlTemplate({bool isDark = false, bool isClean = false}) {
    if (cartoApiKey.isNotEmpty) {
      if (isDark) return darkMatter;
      if (isClean) return positron;
      return voyager;
    }
    // Default to clean OSM tiles without any API key or watermark
    return osm;
  }

  /// Subdomains for tile load balancing across servers.
  static const List<String> subdomains = ['a', 'b', 'c'];

  /// App user agent package name required by OSM/CARTO tile servers.
  static const String userAgentPackageName = 'in.mahato.cocircle';
}
