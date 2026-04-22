import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/entities/offline_map.dart';
import '../../domain/usecases/offline_map_use_cases.dart';

class OfflineMapsController extends ChangeNotifier {
  OfflineMapsController({required OfflineMapUseCases useCases})
    : _useCases = useCases;

  final OfflineMapUseCases _useCases;

  bool _enabled = false;
  bool _isBusy = false;
  double _progress = 0;
  String _statusMessage = 'Mappa offline non scaricata';

  Completer<bool>? _activeCompleter;
  StreamSubscription<OfflineMapProgress>? _downloadSub;

  bool get enabled => _enabled;
  bool get isBusy => _isBusy;
  double get progress => _progress;
  String get statusMessage => _statusMessage;

  Future<void> init() async {
    _enabled = await _useCases.hasOfflineMap();
    if (_enabled) {
      _statusMessage = 'Mappa offline disponibile nel menu mappe';
      _progress = 1;
    }
    notifyListeners();
  }

  Future<bool> enableOfflineMaps() async {
    if (_isBusy) return false;

    _isBusy = true;
    _progress = 0;
    _statusMessage = 'Download mappa in corso...';
    notifyListeners();

    await _downloadSub?.cancel();
    _downloadSub = null;

    final completer = Completer<bool>();
    _activeCompleter = completer;

    _downloadSub = _useCases.downloadOfflineMap().listen(
      (event) {
        _progress = event.ratio;

        if (event.status == OfflineMapStatus.downloading) {
          _statusMessage =
              'Scaricamento mappa ${event.downloaded}/${event.total}';
        }

        if (event.status == OfflineMapStatus.completed) {
          _enabled = true;
          _isBusy = false;
          _progress = 1;
          _statusMessage =
              'Download completato. Mappa offline disponibile nel menu mappe.';
          _activeCompleter = null;
          if (!completer.isCompleted) completer.complete(true);
        }

        notifyListeners();
      },
      onError: (Object error) {
        _isBusy = false;
        _enabled = false;
        _progress = 0;
        _statusMessage = 'Errore durante il download: $error';
        notifyListeners();
        _activeCompleter = null;
        if (!completer.isCompleted) completer.complete(false);
      },
      cancelOnError: true,
    );

    return completer.future;
  }

  Future<void> disableOfflineMaps() async {
    if (_isBusy) return;

    _isBusy = true;
    _statusMessage = 'Eliminazione mappa offline...';
    _progress = 0;
    notifyListeners();

    await _downloadSub?.cancel();
    _downloadSub = null;

    await _useCases.clearOfflineMap();

    _enabled = false;
    _isBusy = false;
    _statusMessage = 'Mappa offline eliminata';
    _progress = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _downloadSub?.cancel();
    if (_activeCompleter != null && !_activeCompleter!.isCompleted) {
      _activeCompleter!.complete(false);
    }
    super.dispose();
  }
}
