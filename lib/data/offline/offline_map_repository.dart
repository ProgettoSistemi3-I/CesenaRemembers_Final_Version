import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class OfflineMapProgress {
  const OfflineMapProgress({
    required this.downloaded,
    required this.total,
    required this.status,
  });

  final int downloaded;
  final int total;
  final OfflineMapStatus status;

  double get ratio => total == 0 ? 0 : downloaded / total;
}

enum OfflineMapStatus { idle, downloading, completed, deleting, failed }

class OfflineMapRepository {
  static const String _manifestFileName = 'manifest.json';
  static const String _cacheFolderName = 'offline_maps';
  static const String _mapStyle = 'basic-v2';
  static const String _mapTilerApiHost = 'https://api.maptiler.com/maps';

  static const int _minZoom = 12;
  static const int _maxZoom = 18;
  static const int _parallelism = 8;

  static const double _minLat = 44.1260;
  static const double _maxLat = 44.1498;
  static const double _minLon = 12.2348;
  static const double _maxLon = 12.2589;

  final http.Client _httpClient;
  final ValueNotifier<bool> availability = ValueNotifier<bool>(false);
  final String _mapTilerApiKey;

  Directory? _cacheRoot;

  OfflineMapRepository({http.Client? httpClient, String? mapTilerApiKey})
    : _httpClient = httpClient ?? http.Client(),
      _mapTilerApiKey =
          mapTilerApiKey ??
          const String.fromEnvironment('MAPTILER_API_KEY', defaultValue: '');

  Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    _cacheRoot = Directory('${appDir.path}/$_cacheFolderName');
    if (!await _cacheRoot!.exists()) {
      await _cacheRoot!.create(recursive: true);
    }
    availability.value = await hasOfflineMap();
  }

  Future<bool> hasOfflineMap() async {
    final manifest = await _readManifest();
    return manifest['isReady'] == true;
  }

  String get offlineMapTemplate =>
      'file://${_cacheRoot?.path ?? ''}/{z}/{x}/{y}.png';

  String get localCachePath => _requireRoot().path;

  Future<void> clearOfflineMap() async {
    final root = _requireRoot();
    if (await root.exists()) {
      await root.delete(recursive: true);
    }
    await root.create(recursive: true);
    availability.value = false;
  }

  Stream<OfflineMapProgress> downloadOfflineMap() async* {
    if (_mapTilerApiKey.trim().isEmpty) {
      throw StateError(
        'MAPTILER_API_KEY non configurata. Usa --dart-define=MAPTILER_API_KEY=la_tua_chiave',
      );
    }

    final root = _requireRoot();
    final allTiles = _buildCesenaTiles();

    int downloaded = 0;
    yield OfflineMapProgress(
      downloaded: downloaded,
      total: allTiles.length,
      status: OfflineMapStatus.downloading,
    );

    for (var i = 0; i < allTiles.length; i += _parallelism) {
      final chunk = allTiles.skip(i).take(_parallelism).toList(growable: false);

      await Future.wait(chunk.map((tile) => _downloadTile(root, tile)));
      downloaded = math.min(downloaded + chunk.length, allTiles.length);

      yield OfflineMapProgress(
        downloaded: downloaded,
        total: allTiles.length,
        status: OfflineMapStatus.downloading,
      );
    }

    await _writeManifest(<String, dynamic>{
      'isReady': true,
      'downloadedAt': DateTime.now().toIso8601String(),
      'minZoom': _minZoom,
      'maxZoom': _maxZoom,
      'source': 'maptiler:$_mapStyle',
    });
    availability.value = true;

    yield OfflineMapProgress(
      downloaded: downloaded,
      total: allTiles.length,
      status: OfflineMapStatus.completed,
    );
  }

  Directory _requireRoot() {
    final root = _cacheRoot;
    if (root == null) {
      throw StateError('OfflineMapRepository non inizializzato.');
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
    final value = (1 - math.log(math.tan(latRad) + 1 / math.cos(latRad)) / math.pi) / 2;
    return (value * n).floor();
  }

  Future<void> _downloadTile(Directory root, _TileCoords tile) async {
    final tileFile = File('${root.path}/${tile.z}/${tile.x}/${tile.y}.png');
    if (await tileFile.exists()) return;

    await tileFile.parent.create(recursive: true);
    final uri = Uri.parse(
      '$_mapTilerApiHost/$_mapStyle/${tile.z}/${tile.x}/${tile.y}.png?key=$_mapTilerApiKey',
    );

    Future<http.Response?> send() async {
      try {
        return _httpClient.get(uri, headers: const {'User-Agent': 'CesenaRemembers/1.0'});
      } catch (_) {
        return null;
      }
    }

    var response = await send();
    if (response?.statusCode == 429) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      response = await send();
    }

    if (response?.statusCode == 200 && response != null) {
      await tileFile.writeAsBytes(response.bodyBytes);
    }
  }
}

@immutable
class _TileCoords {
  const _TileCoords({required this.x, required this.y, required this.z});

  final int x;
  final int y;
  final int z;
}
