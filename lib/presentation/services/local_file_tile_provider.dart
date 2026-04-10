import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';

class LocalFileTileProvider extends TileProvider {
  LocalFileTileProvider({required this.cacheRootPath});

  final String cacheRootPath;

  // PNG trasparente 1x1 — usato come fallback per tile mancanti
  static final Uint8List _transparentPng = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8Xw8AAoMBgQf8dQwAAAAASUVORK5CYII=',
  );

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final file = File(
      '$cacheRootPath/${coordinates.z}/${coordinates.x}/${coordinates.y}.png',
    );

    if (file.existsSync()) {
      return FileImage(file);
    }

    // Tile mancante → trasparente, nessuna eccezione
    return MemoryImage(_transparentPng);
  }
}
