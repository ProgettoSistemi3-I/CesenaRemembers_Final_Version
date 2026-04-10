import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/offline/offline_map_repository.dart';

class OfflineMapsController extends ChangeNotifier {
  OfflineMapsController({required OfflineMapRepository repository})
    : _repository = repository;

  final OfflineMapRepository _repository;

  bool _enabled = false;
  bool _isBusy = false;
  double _progress = 0;
  String _statusMessage = 'Mappe offline non scaricate';

  StreamSubscription<OfflineMapProgress>? _downloadSub;

  bool get enabled => _enabled;
  bool get isBusy => _isBusy;
  double get progress => _progress;
  String get statusMessage => _statusMessage;

  Future<void> init() async {
    _enabled = await _repository.hasOfflineMap();
    if (_enabled) {
      _statusMessage = 'Mappe offline pronte all\'uso';
      _progress = 1;
    }
    notifyListeners();
  }

  Future<bool> enableOfflineMaps() async {
    if (_isBusy) return false;

    _isBusy = true;
    _progress = 0;
    _statusMessage = 'Download mappe in corso...';
    notifyListeners();

    final completer = Completer<bool>();
    await _downloadSub?.cancel();
    _downloadSub = _repository.downloadOfflineMap().listen(
      (event) {
        _progress = event.ratio;
        if (event.status == OfflineMapStatus.downloading) {
          _statusMessage =
              'Scaricamento tile ${event.downloaded}/${event.total}';
        }
        if (event.status == OfflineMapStatus.completed) {
          _enabled = true;
          _isBusy = false;
          _progress = 1;
          _statusMessage = 'Download completato. Mappe disponibili offline.';
          completer.complete(true);
        }
        notifyListeners();
      },
      onError: (_) {
        _isBusy = false;
        _enabled = false;
        _statusMessage = 'Errore durante il download mappe.';
        notifyListeners();
        completer.complete(false);
      },
    );

    return completer.future;
  }

  Future<void> disableOfflineMaps() async {
    if (_isBusy) return;

    _isBusy = true;
    _statusMessage = 'Eliminazione mappe offline...';
    _progress = 0;
    notifyListeners();

    await _downloadSub?.cancel();
    await _repository.clearOfflineMap();

    _enabled = false;
    _isBusy = false;
    _statusMessage = 'Mappe offline eliminate';
    _progress = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _downloadSub?.cancel();
    super.dispose();
  }
}
