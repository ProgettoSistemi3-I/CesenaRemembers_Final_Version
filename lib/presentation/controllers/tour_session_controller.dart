import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/tour_stop.dart';
import '../../domain/services/tour_route_planner.dart';

const double defaultArrivedThresholdMeters = 50.0;
const LatLng defaultCesenaCenter = LatLng(44.143043, 12.253486);

enum TourStatus { idle, running, arrived }

class TourSessionController {
  TourSessionController({
    required List<TourStop> availableStops,
    TourRoutePlanner routePlanner = const TourRoutePlanner(),
    double arrivedThresholdMeters = defaultArrivedThresholdMeters,
  }) : _availableStops = List.unmodifiable(availableStops),
       _routePlanner = routePlanner,
       _arrivedThresholdMeters = arrivedThresholdMeters;

  final List<TourStop> _availableStops;
  final TourRoutePlanner _routePlanner;
  final double _arrivedThresholdMeters;

  final StreamController<void> _updates = StreamController<void>.broadcast();

  Stream<void> get updates => _updates.stream;

  TourStatus _status = TourStatus.idle;
  List<TourStop> _orderedStops = [];
  int _currentStopIndex = 0;
  LatLng? _userPosition;
  int _elapsedSeconds = 0;
  int _totalElapsedSeconds = 0;

  Timer? _timer;
  StreamSubscription<Position>? _positionSubscription;

  TourStatus get status => _status;
  bool get isActive => _status != TourStatus.idle;
  bool get isArrived => _status == TourStatus.arrived;
  int get elapsedSeconds => _elapsedSeconds;
  int get totalElapsedSeconds => _totalElapsedSeconds;
  List<TourStop> get orderedStops => List.unmodifiable(_orderedStops);
  int get currentStopIndex => _currentStopIndex;
  TourStop? get currentStop =>
      _orderedStops.isEmpty ? null : _orderedStops[_currentStopIndex];

  List<TourStop> get upcomingStops {
    if (_orderedStops.isEmpty || _currentStopIndex >= _orderedStops.length) {
      return const [];
    }
    return List.unmodifiable(_orderedStops.sublist(_currentStopIndex));
  }

  List<double?> get upcomingStopsDistanceFromPrevious {
    if (_orderedStops.isEmpty || _currentStopIndex >= _orderedStops.length) {
      return const [];
    }

    final distance = const Distance();
    return List<double?>.generate(upcomingStops.length, (relativeIndex) {
      final absoluteIndex = _currentStopIndex + relativeIndex;
      if (absoluteIndex == 0) return null;
      return distance.as(
        LengthUnit.Meter,
        _orderedStops[absoluteIndex - 1].position,
        _orderedStops[absoluteIndex].position,
      );
    }, growable: false);
  }

  double get distanceToCurrentStop {
    final stop = currentStop;
    if (stop == null || _userPosition == null) return -1;
    return const Distance().as(LengthUnit.Meter, _userPosition!, stop.position);
  }

  bool get hasStops => _availableStops.isNotEmpty;

  Future<bool> startTour() async {
    if (_availableStops.isEmpty) {
      _status = TourStatus.idle;
      _orderedStops = [];
      _currentStopIndex = 0;
      _elapsedSeconds = 0;
      _totalElapsedSeconds = 0;
      _emit();
      return false;
    }

    final origin = await _resolveOrigin();

    _orderedStops = _routePlanner.sortNearestNeighbor(
      origin: origin,
      stops: _availableStops,
    );
    _currentStopIndex = 0;
    _elapsedSeconds = 0;
    _totalElapsedSeconds = 0;
    _status = TourStatus.running;
    _emit();

    _startPositionTracking();
    _startTimer();
    return true;
  }

  void markArrivedManually() {
    if (_status != TourStatus.running) return;
    _triggerArrival();
  }

  bool advanceToNextStop() {
    if (_currentStopIndex < _orderedStops.length - 1) {
      _currentStopIndex++;
      _status = TourStatus.running;
      _elapsedSeconds = 0;
      _emit();
      _startTimer();
      return true;
    }

    stopTour();
    return false;
  }

  void stopTour() {
    _stopTracking();
    _status = TourStatus.idle;
    _orderedStops = [];
    _currentStopIndex = 0;
    _elapsedSeconds = 0;
    _totalElapsedSeconds = 0;
    _emit();
  }

  void reorderUpcomingStops({
    required int oldRelativeIndex,
    required int newRelativeIndex,
  }) {
    if (!isActive) return;

    final upcomingLength = _orderedStops.length - _currentStopIndex;
    if (upcomingLength < 2) return;
    if (oldRelativeIndex < 0 || oldRelativeIndex >= upcomingLength) return;
    if (newRelativeIndex < 0 || newRelativeIndex >= upcomingLength) return;

    final absoluteOldIndex = _currentStopIndex + oldRelativeIndex;
    final absoluteNewIndex = _currentStopIndex + newRelativeIndex;

    final movedStop = _orderedStops.removeAt(absoluteOldIndex);
    _orderedStops.insert(absoluteNewIndex, movedStop);

    _emit();
  }

  Future<void> refreshPermissionsState() async {
    _emit();
  }

  void dispose() {
    _timer?.cancel();
    _positionSubscription?.cancel();
    _updates.close();
  }

  Future<LatLng> _resolveOrigin() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 4));
      _userPosition = LatLng(pos.latitude, pos.longitude);
      return _userPosition!;
    } catch (_) {
      _userPosition = defaultCesenaCenter;
      return defaultCesenaCenter;
    }
  }

  void _startPositionTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen((position) {
      _userPosition = LatLng(position.latitude, position.longitude);
      if (_status == TourStatus.running &&
          distanceToCurrentStop >= 0 &&
          distanceToCurrentStop <= _arrivedThresholdMeters) {
        _triggerArrival();
      } else {
        _emit();
      }
    });
  }

  void _triggerArrival() {
    if (_status == TourStatus.arrived) return;
    _timer?.cancel();
    _status = TourStatus.arrived;
    _emit();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_status == TourStatus.running) {
        _elapsedSeconds++;
        _totalElapsedSeconds++;
        _emit();
      }
    });
  }

  void _stopTracking() {
    _timer?.cancel();
    _positionSubscription?.cancel();
  }

  void _emit() {
    if (!_updates.isClosed) {
      _updates.add(null);
    }
  }
}
