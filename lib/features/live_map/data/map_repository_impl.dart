import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/map_repository.dart';

part 'map_repository_impl.g.dart';

@Riverpod(keepAlive: true)
MapRepository mapRepository(Ref ref) {
  return MapRepositoryImpl();
}

class MapRepositoryImpl implements MapRepository {
  Directory? _cacheDir;

  Future<Directory> _getCacheDirectory() async {
    if (_cacheDir != null) return _cacheDir!;
    final baseDir = await getApplicationDocumentsDirectory();
    final cachePath = Directory('${baseDir.path}/map_tiles');
    if (!await cachePath.exists()) {
      await cachePath.create(recursive: true);
    }
    _cacheDir = cachePath;
    return _cacheDir!;
  }

  @override
  Future<TileProvider> getTileProvider() async {
    final dir = await _getCacheDirectory();
    return CachedTileProvider(cacheDir: dir);
  }

  @override
  Future<void> clearCache() async {
    try {
      final dir = await _getCacheDirectory();
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        await dir.create(recursive: true);
      }
    } catch (e) {
      debugPrint("Failed to clear map tiles cache: $e");
    }
  }
}

class CachedTileProvider extends TileProvider {
  final Directory cacheDir;

  CachedTileProvider({required this.cacheDir});

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final url = getTileUrl(coordinates, options);
    final file = File('${cacheDir.path}/${coordinates.z}/${coordinates.x}/${coordinates.y}.png');

    if (file.existsSync()) {
      return FileImage(file);
    }

    return CachedNetworkTileImageProvider(url: url, file: file);
  }
}

class CachedNetworkTileImageProvider extends ImageProvider<CachedNetworkTileImageProvider> {
  final String url;
  final File file;

  CachedNetworkTileImageProvider({required this.url, required this.file});

  @override
  Future<CachedNetworkTileImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CachedNetworkTileImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(CachedNetworkTileImageProvider key, ImageDecoderCallback decode) {
    final StreamController<ImageChunkEvent> chunkEvents = StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents, decode),
      chunkEvents: chunkEvents.stream,
      scale: 1.0,
      debugLabel: key.url,
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<CachedNetworkTileImageProvider>('Image key', key),
      ],
    );
  }

  Future<ui.Codec> _loadAsync(
    CachedNetworkTileImageProvider key,
    StreamController<ImageChunkEvent> chunkEvents,
    ImageDecoderCallback decode,
  ) async {
    try {
      if (await key.file.exists()) {
        final bytes = await key.file.readAsBytes();
        final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
        return await decode(buffer);
      }

      final response = await http.get(Uri.parse(key.url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        _saveTileToDisk(key.file, bytes);
        final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
        return await decode(buffer);
      }
      throw Exception('Failed to load tile: status code ${response.statusCode}');
    } catch (e) {
      rethrow;
    } finally {
      chunkEvents.close();
    }
  }

  Future<void> _saveTileToDisk(File file, Uint8List bytes) async {
    try {
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);
    } catch (e) {
      debugPrint("Failed to save tile to disk: $e");
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is CachedNetworkTileImageProvider && other.url == url;
  }

  @override
  int get hashCode => url.hashCode;
}
