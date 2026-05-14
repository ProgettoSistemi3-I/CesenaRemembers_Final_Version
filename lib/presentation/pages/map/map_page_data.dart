part of 'map_page.dart';

extension _MapPageDataLogic on _MapPageState {
  Future<void> _loadPois() async {
    if (_MapPageState._cachedPois != null &&
        _MapPageState._cachedStops != null) {
      _tourController.dispose();
      _tourController = TourSessionController(
        availableStops: _MapPageState._cachedStops!,
      );
      _bindTourUpdates();
      setState(() {
        _pois = _MapPageState._cachedPois!;
        _isLoading = false;
        _loadError = null;
        _markers = _buildMarkers(_pois);
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
        _markers = _buildMarkers(pois);
        _loadError = null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pois = [];
        _markers = const [];
        _loadError = 'errorLoadPoi';
        _isLoading = false;
      });
    }
  }

  // I marker non dipendono dallo stato del tour o dalla rotazione — vengono
  // ricalcolati solo quando la lista POI cambia (o la rotazione della mappa),
  // non ad ogni tick del timer.
  List<Marker> _buildMarkers(List<Poi> pois) {
    return pois
        .map(
          (poi) => _poiMarkerFactory.fromPoi(
            poi,
            counterRotationDegrees: _currentRotation,
          ),
        )
        .toList(growable: false);
  }

  void _onRotationChanged(double rotation) {
    if ((_currentRotation - rotation).abs() < 0.5) {
      return; // Soglia per evitare ricalcoli eccessivi
    }
    setState(() {
      _currentRotation = rotation;
      // Ricalcola i marker solo quando la rotazione cambia
      if (_pois.isNotEmpty) _markers = _buildMarkers(_pois);
    });
  }

  void _bindTourUpdates() {
    _tourUpdatesSub?.cancel();
    _tourUpdatesSub = _tourController.updates.listen((_) {
      // Aggiorna solo lo stato del tour, NON i marker
      if (mounted) setState(() {});
    });
  }
}
