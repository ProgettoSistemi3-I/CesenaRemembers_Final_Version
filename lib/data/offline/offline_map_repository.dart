import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../config/app_runtime_config.dart';
import '../../domain/entities/offline_map.dart';
import '../../domain/repositories/offline_map_repository.dart';

class OfflineMapRepository implements IOfflineMapRepository {
  static const String _manifestFileName = 'manifest.json';
  static const String _cacheFolderName = 'offline_maps';
  static const String _mapStyle = 'basic-v2';
  static const String _mapTilerApiHost = 'https://api.maptiler.com/maps';

  static const int _minZoom = 12;
  static const int _maxZoom = 18;
  static const int _parallelism = 16;

  static const double _minLat = 44.1054;
  static const double _maxLat = 44.1714;
  static const double _minLon = 12.2131;
  static const double _maxLon = 12.2811;

  final http.Client _httpClient;

  @override
  final ValueNotifier<bool> availability = ValueNotifier<bool>(false);

  Directory? _cacheRoot;

  OfflineMapRepository({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  @override
  Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    _cacheRoot = Directory('${appDir.path}/$_cacheFolderName');
    if (!await _cacheRoot!.exists()) {
      await _cacheRoot!.create(recursive: true);
    }
    availability.value = await hasOfflineMap();
  }

  @override
  Future<bool> hasOfflineMap() async {
    final manifest = await _readManifest();
    final isReady = manifest['isReady'] == true;
    final expectedTiles = manifest['expectedTiles'];
    final downloadedTiles = manifest['downloadedTiles'];

    if (!isReady) return false;
    if (expectedTiles is! int || downloadedTiles is! int) return false;
    return expectedTiles > 0 && downloadedTiles == expectedTiles;
  }

  @override
  String get offlineMapTemplate =>
      'file://${_cacheRoot?.path ?? ''}/{z}/{x}/{y}.png';

  @override
  String get localCachePath => _requireRoot().path;

  @override
  Future<void> clearOfflineMap() async {
    final root = _requireRoot();
    if (await root.exists()) {
      await root.delete(recursive: true);
    }
    await root.create(recursive: true);
    availability.value = false;
  }

  @override
  Stream<OfflineMapProgress> downloadOfflineMap() async* {
    final mapTilerApiKey = AppRuntimeConfig.mapTilerApiKey;
    if (mapTilerApiKey.trim().isEmpty) {
      throw StateError('MapTiler API key non configurata (MAPTILER_API_KEY).');
    }

    final root = _requireRoot();
    final allTiles = _buildCesenaTiles();
    final total = allTiles.length;

    var processed = 0;
    var failed = 0;
    final progressController = StreamController<int>();

    yield OfflineMapProgress(
      downloaded: 0,
      total: total,
      status: OfflineMapStatus.downloading,
    );

    final poolDone = _runWorkerPool(
      root: root,
      tiles: allTiles,
      mapTilerApiKey: mapTilerApiKey,
      onTileComplete: (didSucceed) {
        processed++;
        if (!didSucceed) failed++;
        progressController.add(processed);
      },
    );

    await for (final count in progressController.stream) {
      yield OfflineMapProgress(
        downloaded: count,
        total: total,
        status: OfflineMapStatus.downloading,
      );
      if (count >= total) break;
    }

    await poolDone;
    await progressController.close();

    final downloadedTiles = total - failed;
    final storedBytes = await _calculateStoredBytes(root);

    await _writeManifest(<String, dynamic>{
      'isReady': failed == 0,
      'downloadedAt': DateTime.now().toIso8601String(),
      'minZoom': _minZoom,
      'maxZoom': _maxZoom,
      'source': 'maptiler:$_mapStyle',
      'expectedTiles': total,
      'downloadedTiles': downloadedTiles,
      'failedTiles': failed,
      'storedBytes': storedBytes,
    });
    availability.value = failed == 0;

    if (failed > 0) {
      throw StateError(
        'Download offline incompleto: $failed tile mancanti su $total. '
        'Controlla connessione/restrizioni API e riprova.',
      );
    }

    yield OfflineMapProgress(
      downloaded: total,
      total: total,
      status: OfflineMapStatus.completed,
    );
  }

  Future<void> _runWorkerPool({
    required Directory root,
    required List<_TileCoords> tiles,
    required String mapTilerApiKey,
    required void Function(bool didSucceed) onTileComplete,
  }) async {
    var index = 0;

    Future<void> worker() async {
      while (true) {
        if (index >= tiles.length) return;
        final tile = tiles[index++];

        final didSucceed = await _downloadTile(root, tile, mapTilerApiKey);
        onTileComplete(didSucceed);
      }
    }

    await Future.wait(List.generate(_parallelism, (_) => worker()));
  }

  Directory _requireRoot() {
    final root = _cacheRoot;
    if (root == null) {
      throw StateError(
        'OfflineMapRepository non inizializzato. Chiama init() prima.',
      );
    }
    return root;
  }

  Future<File> _manifestFile() async =>
      File('${_requireRoot().path}/$_manifestFileName');

  Future<Map<String, dynamic>> _readManifest() async {
    final file = await _manifestFile();
    if (!await file.exists()) return <String, dynamic>{};
    final raw = await file.readAsString();
    if (raw.trim().isEmpty) return <String, dynamic>{};
    return (jsonDecode(raw) as Map).cast<String, dynamic>();
  }

  Future<void> _writeManifest(Map<String, dynamic> data) async {
    final file = await _manifestFile();
    await file.writeAsString(jsonEncode(data));
  }

  List<_TileCoords> _buildCesenaTiles() {
    final result = <_TileCoords>[];
    for (var z = _minZoom; z <= _maxZoom; z++) {
      final minX = _lonToTileX(_minLon, z);
      final maxX = _lonToTileX(_maxLon, z);
      final minY = _latToTileY(_maxLat, z);
      final maxY = _latToTileY(_minLat, z);

      for (var x = minX; x <= maxX; x++) {
        for (var y = minY; y <= maxY; y++) {
          result.add(_TileCoords(x: x, y: y, z: z));
        }
      }
    }
    return result;
  }

  int _lonToTileX(double lon, int zoom) {
    final n = math.pow(2, zoom).toDouble();
    return ((lon + 180.0) / 360.0 * n).floor();
  }

  int _latToTileY(double lat, int zoom) {
    final n = math.pow(2, zoom).toDouble();
    final latRad = lat * math.pi / 180;
    final value =
        (1 - math.log(math.tan(latRad) + 1 / math.cos(latRad)) / math.pi) / 2;
    return (value * n).floor();
  }

  Future<bool> _downloadTile(
    Directory root,
    _TileCoords tile,
    String mapTilerApiKey,
  ) async {
    final tileFile = File('${root.path}/${tile.z}/${tile.x}/${tile.y}.png');
    if (await tileFile.exists()) return true;

    await tileFile.parent.create(recursive: true);

    final uri = Uri.parse(
      '$_mapTilerApiHost/$_mapStyle/${tile.z}/${tile.x}/${tile.y}.png'
      '?key=$mapTilerApiKey',
    );

    Future<http.Response?> send() async {
      try {
        return await _httpClient.get(
          uri,
          headers: const {'User-Agent': 'CesenaRemembers/1.0'},
        );
      } catch (_) {
        return null;
      }
    }

    var response = await send();

    if (response?.statusCode == 429) {
      await Future<void>.delayed(const Duration(seconds: 1));
      response = await send();
    }
    if (response?.statusCode == 429) {
      await Future<void>.delayed(const Duration(seconds: 3));
      response = await send();
    }

    if (response != null &&
        response.statusCode == 200 &&
        response.bodyBytes.isNotEmpty) {
      await tileFile.writeAsBytes(response.bodyBytes);
      return true;
    }

    return false;
  }

  Future<int> _calculateStoredBytes(Directory root) async {
    var totalBytes = 0;

    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.endsWith('.png')) {
        totalBytes += await entity.length();
      }
    }

    return totalBytes;
  }
}

@immutable
class _TileCoords {
  const _TileCoords({required this.x, required this.y, required this.z});

  final int x;
  final int y;
  final int z;
}
