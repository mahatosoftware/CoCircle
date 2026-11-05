import 'package:flutter_map/flutter_map.dart';

abstract class MapRepository {
  Future<TileProvider> getTileProvider();
  Future<void> clearCache();
}
