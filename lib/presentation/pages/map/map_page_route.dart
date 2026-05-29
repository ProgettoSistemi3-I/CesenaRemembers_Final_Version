part of 'map_page.dart';

extension _MapPageRouteLine on _MapPageState {
  Future<void> _refreshRouteLine() async {
    final origin = _tourController.userPosition;
    final destination = _tourController.currentStop;

    if (!_tourController.isActive || origin == null || destination == null) {
      _clearRouteLine();
      return;
    }

    final signature = _routeSignature(origin, destination);
    if (signature == _lastRouteLineSignature) return;

    _lastRouteLineSignature = signature;
    final requestId = ++_routeLineRequestId;

    final path = await _routePathService.buildCurrentLegPath(
      origin: GeoPoint(latitude: origin.latitude, longitude: origin.longitude),
      destination: destination,
    );

    if (!mounted || requestId != _routeLineRequestId) return;

    setState(() {
      _routeLinePoints = _toRouteLinePoints(path);
    });
  }

  void _clearRouteLine() {
    _lastRouteLineSignature = null;
    _routeLineRequestId++;
    if (_routeLinePoints.isEmpty) return;
    if (mounted) {
      setState(() => _routeLinePoints = const []);
    }
  }

  String _routeSignature(LatLng origin, TourStop destination) {
    return [
      _coordinateBucket(origin.latitude),
      _coordinateBucket(origin.longitude),
      destination.id,
      _coordinateBucket(destination.position.latitude),
      _coordinateBucket(destination.position.longitude),
    ].join('|');
  }

  int _coordinateBucket(double coordinate) => (coordinate * 10000).round();

  List<LatLng> _toRouteLinePoints(RoutePath path) {
    return path.points
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList(growable: false);
  }
}
