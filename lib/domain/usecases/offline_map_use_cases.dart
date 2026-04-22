import 'package:flutter/foundation.dart';

import '../entities/offline_map.dart';
import '../repositories/offline_map_repository.dart';

class OfflineMapUseCases {
  const OfflineMapUseCases(this._repository);

  final IOfflineMapRepository _repository;

  ValueListenable<bool> get availability => _repository.availability;
  String get offlineMapTemplate => _repository.offlineMapTemplate;
  String get localCachePath => _repository.localCachePath;

  Future<void> init() => _repository.init();
  Future<bool> hasOfflineMap() => _repository.hasOfflineMap();
  Future<void> clearOfflineMap() => _repository.clearOfflineMap();
  Stream<OfflineMapProgress> downloadOfflineMap() =>
      _repository.downloadOfflineMap();
}
