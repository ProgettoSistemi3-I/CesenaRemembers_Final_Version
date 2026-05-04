part of 'map_page.dart';

extension _MapPageDataLogic on _MapPageState {
  Future<void> _loadPois() async {
    if (_MapPageState._cachedPois != null && _MapPageState._cachedStops != null) {
      _tourController.dispose();
      _tourController = TourSessionController(
        availableStops: _MapPageState._cachedStops!,
      );
      _bindTourUpdates();
      setState(() {
        _pois = _MapPageState._cachedPois!;
        _cachedMarkers = const [];
        _lastMarkerRotation = null;
        _isLoading = false;
      });
      return;
    }

    try {
      final getPois = sl<GetPoisUseCase>();
      final pois = await getPois();
      if (!mounted) return;

      final stops = _tourStopMapper.fromPois(pois);
      _MapPageState._cachedStops = stops;
      _MapPageState._cachedPois = pois;

      _tourController.dispose();
      _tourController = TourSessionController(availableStops: stops);
      _bindTourUpdates();

      setState(() {
        _pois = pois;
        _cachedMarkers = const [];
        _lastMarkerRotation = null;
        _loadError = null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pois = [];
        _loadError = 'Errore nel caricamento dei punti di interesse.';
        _isLoading = false;
      });
    }
  }

  List<Marker> _buildMarkers() {
    if (_cachedMarkers.isNotEmpty && _lastMarkerRotation == _currentRotation) {
      return _cachedMarkers;
    }

    _lastMarkerRotation = _currentRotation;
    _cachedMarkers = _pois
        .map(
          (poi) => _poiMarkerFactory.fromPoi(
            poi,
            counterRotationDegrees: _currentRotation,
          ),
        )
        .toList(growable: false);

    return _cachedMarkers;
  }

  void _bindTourUpdates() {
    _tourUpdatesSub?.cancel();
    _tourUpdatesSub = _tourController.updates.listen((_) {
      if (mounted) setState(() {});
    });
  }
}
