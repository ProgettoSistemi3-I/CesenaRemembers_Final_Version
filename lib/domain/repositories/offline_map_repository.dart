import 'package:flutter/foundation.dart';

import '../entities/offline_map.dart';

abstract class IOfflineMapRepository {
  ValueListenable<bool> get availability;

  Future<void> init();
  Future<bool> hasOfflineMap();
  String get offlineMapTemplate;
  String get localCachePath;
  Future<void> clearOfflineMap();
  Stream<OfflineMapProgress> downloadOfflineMap();
}
