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
  static const String _offlineMapTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  static const int _minZoom = 12;
  static const int _maxZoom = 18;

  static const double _minLat = 44.0700;
  static const double _maxLat = 44.2050;
  static const double _minLon = 12.1700;
  static const double _maxLon = 12.3350;

  final http.Client _httpClient;
  final ValueNotifier<bool> availability = ValueNotifier<bool>(false);

  Directory? _cacheRoot;

  OfflineMapRepository({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

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
    final root = _requireRoot();
    final allTiles = _buildCesenaTiles();

    int downloaded = 0;
    yield OfflineMapProgress(
      downloaded: downloaded,
      total: allTiles.length,
      status: OfflineMapStatus.downloading,
    );

    for (final tile in allTiles) {
      final tileFile = File('${root.path}/${tile.z}/${tile.x}/${tile.y}.png');

      if (await tileFile.exists()) {
        downloaded++;
        yield OfflineMapProgress(
          downloaded: downloaded,
          total: allTiles.length,
          status: OfflineMapStatus.downloading,
        );
        continue;
      }

      await tileFile.parent.create(recursive: true);
      final uri = Uri.parse(
        _offlineMapTemplate
            .replaceAll('{z}', tile.z.toString())
            .replaceAll('{x}', tile.x.toString())
            .replaceAll('{y}', tile.y.toString()),
      );

      try {
        final response = await _httpClient.get(uri);
        if (response.statusCode == 200) {
          await tileFile.writeAsBytes(response.bodyBytes);
        }
      } catch (_) {
        // Ignoriamo il singolo tile fallito, ma continuiamo il download.
      }

      downloaded++;
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
      'source': _offlineMapTemplate,
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
}

@immutable
class _TileCoords {
  const _TileCoords({required this.x, required this.y, required this.z});

  final int x;
  final int y;
  final int z;
}
