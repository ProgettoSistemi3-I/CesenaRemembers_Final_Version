import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../data/seeds/tour_stops_seed.dart';
import '../../domain/usecases/poi_use_cases.dart';
import '../../injection_container.dart';
import '../controllers/tour_session_controller.dart';
import '../services/location_permission_service.dart';
import '../services/poi_marker_factory.dart';
import '../theme/app_palette.dart';
import 'map/widgets/map_controls.dart';
import 'map/widgets/poi_bottom_sheet.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with WidgetsBindingObserver {
  final MapController _mapController = MapController();
  final _locationPermissionService = const LocationPermissionService();
  final _poiMarkerFactory = const PoiMarkerFactory();
  final TourSessionController _tourController = TourSessionController(
    availableStops: TourStopsSeed.cesena,
  );

  StreamSubscription<ServiceStatus>? _serviceStatusSub;
  StreamSubscription<void>? _tourUpdatesSub;

  AlignOnUpdate _alignPositionOnUpdate = AlignOnUpdate.always;
  double _currentRotation = 0.0;
  bool _isMapLocked = false;
  bool _isMapMenuOpen = false;

  static const _urlStandard =
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';
  static const _urlSatellite =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
  String _currentMapUrl = _urlStandard;

  List<Marker> _markers = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionsAndInitialize();
    _listenToServiceStatus();
    _loadPois();
    _tourUpdatesSub = _tourController.updates.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _serviceStatusSub?.cancel();
    _tourUpdatesSub?.cancel();
    _tourController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissionsAndInitialize();
    }
  }

  Future<void> _loadPois() async {
    try {
      final getPois = sl<GetPoisUseCase>();
      final pois = await getPois();
      if (!mounted) return;
      setState(() {
        _markers = pois.map(_poiMarkerFactory.fromPoi).toList();
        _loadError = null;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _markers = [];
        _loadError = 'Errore nel caricamento dei punti di interesse.';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Caricamento POI fallito: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _checkPermissionsAndInitialize() async {
    final isAuthorized = await _locationPermissionService
        .ensureLocationEnabledAndAuthorized();
    if (!isAuthorized || !mounted) {
      return;
    }
    setState(() {});
  }

  void _listenToServiceStatus() {
    if (kIsWeb) return;
    _serviceStatusSub = Geolocator.getServiceStatusStream().listen((status) {
      if (!mounted || status != ServiceStatus.disabled) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GPS disattivato'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    });
  }

  Future<void> _startTour() async {
    await _tourController.startTour();
    final currentStop = _tourController.currentStop;
    if (currentStop != null) {
      _centerOnStop(currentStop.position);
    }
  }

  void _centerOnStop(LatLng position) {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      _mapController.move(position, 17.0);
      setState(() => _alignPositionOnUpdate = AlignOnUpdate.never);
    });
  }

  void _openPoiPopup() {
    final currentStop = _tourController.currentStop;
    if (currentStop == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppPalette.warmWhite,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PoiBottomSheet(
        stop: currentStop,
        elapsedSeconds: _tourController.elapsedSeconds,
        onNextStop: () {
          Navigator.pop(context);
          final moved = _tourController.advanceToNextStop();
          if (moved) {
            final next = _tourController.currentStop;
            if (next != null) {
              _centerOnStop(next.position);
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('🎉 Tour completato! Ottimo lavoro.'),
                backgroundColor: AppPalette.olive,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
    );

    const cardHeight = 82.0;
    const cardPadding = 12.0;
    const cardBottom = cardHeight + cardPadding * 2;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppPalette.olive),
      );
    }

    if (_loadError != null) {
      return _buildErrorState();
    }

    final currentStop = _tourController.currentStop;
    final isTourActive = _tourController.isActive;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: defaultCesenaCenter,
              initialZoom: 14.0,
              minZoom: 3.0,
              maxZoom: 19.0,
              backgroundColor: const Color(0xFFE4E5E6),
              interactionOptions: InteractionOptions(
                flags:
                    _isMapLocked ? InteractiveFlag.none : InteractiveFlag.all,
              ),
              onMapEvent: (event) {
                if (event is MapEventMove || event is MapEventRotate) {
                  final rotation = _mapController.camera.rotation;
                  if ((rotation - _currentRotation).abs() > 0.1) {
                    setState(() => _currentRotation = rotation);
                  }
                }
                if (event is MapEventMoveStart && _isMapMenuOpen) {
                  setState(() => _isMapMenuOpen = false);
                }
              },
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture &&
                    _alignPositionOnUpdate != AlignOnUpdate.never) {
                  setState(() => _alignPositionOnUpdate = AlignOnUpdate.never);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _currentMapUrl,
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.geoapp.prototype',
                maxZoom: 19,
              ),
              CurrentLocationLayer(
                alignPositionOnUpdate: _alignPositionOnUpdate,
                alignDirectionOnUpdate: AlignOnUpdate.never,
                style: LocationMarkerStyle(
                  marker: const DefaultLocationMarker(
                    color: Colors.blue,
                    child: Icon(Icons.navigation, color: Colors.white, size: 14),
                  ),
                  markerSize: const Size(40, 40),
                  markerDirection: MarkerDirection.heading,
                  accuracyCircleColor: Colors.blue.withValues(alpha: 0.1),
                  headingSectorColor: Colors.blue.withValues(alpha: 0.2),
                  headingSectorRadius: 60,
                ),
                positionStream: const LocationMarkerDataStreamFactory()
                    .fromGeolocatorPositionStream(
                      stream: Geolocator.getPositionStream(
                        locationSettings: locationSettings,
                      ),
                    ),
              ),
              MarkerLayer(markers: _markers),
            ],
          ),
          SafeArea(
            child: Stack(
              children: [
                if (_currentRotation != 0)
                  Positioned(
                    top: 10,
                    right: 20,
                    child: GestureDetector(
                      onTap: () {
                        _mapController.rotate(0);
                        setState(() => _currentRotation = 0);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Transform.rotate(
                          angle: -_currentRotation * (math.pi / 180),
                          child: const Icon(
                            Icons.navigation,
                            color: Colors.red,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 20,
                  bottom: isTourActive ? cardBottom : 20,
                  child: MapTypeButton(
                    isOpen: _isMapMenuOpen,
                    urlStandard: _urlStandard,
                    urlSatellite: _urlSatellite,
                    onToggle: () => setState(() => _isMapMenuOpen = !_isMapMenuOpen),
                    onSelect: (url) => setState(() {
                      _currentMapUrl = url;
                      _isMapMenuOpen = false;
                    }),
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: isTourActive ? cardBottom + 66 : 90,
                  child: CircleFab(
                    heroTag: 'btnLock',
                    icon: _isMapLocked ? Icons.lock : Icons.lock_open,
                    iconColor: _isMapLocked ? Colors.red : Colors.black54,
                    onTap: () => setState(() => _isMapLocked = !_isMapLocked),
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: isTourActive ? cardBottom + 8 : 20,
                  child: CircleFab(
                    heroTag: 'btnLoc',
                    icon: Icons.my_location,
                    iconColor: _alignPositionOnUpdate == AlignOnUpdate.always
                        ? AppPalette.olive
                        : Colors.black54,
                    onTap: () {
                      setState(() => _alignPositionOnUpdate = AlignOnUpdate.always);
                      _checkPermissionsAndInitialize();
                    },
                  ),
                ),
                if (!isTourActive)
                  Positioned(
                    bottom: 28,
                    left: 0,
                    right: 0,
                    child: Center(child: StartTourButton(onTap: _startTour)),
                  ),
                if (isTourActive && _tourController.status == TourStatus.running)
                  Positioned(
                    right: 20,
                    bottom: cardBottom + 132,
                    child: ManualArrivalButton(
                      onTap: _tourController.markArrivedManually,
                    ),
                  ),
                if (isTourActive && currentStop != null)
                  Positioned(
                    bottom: cardPadding,
                    left: 16,
                    right: 16,
                    child: NextStopCard(
                      stop: currentStop,
                      stopIndex: _tourController.currentStopIndex,
                      totalStops: _tourController.orderedStops.length,
                      distanceMeters: _tourController.distanceToCurrentStop,
                      elapsedSeconds: _tourController.elapsedSeconds,
                      arrived: _tourController.isArrived,
                      onTap: _tourController.isArrived
                          ? _openPoiPopup
                          : () => _centerOnStop(currentStop.position),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 42),
            const SizedBox(height: 12),
            Text(
              _loadError!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() => _isLoading = true);
                _loadPois();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.olive,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Riprova'),
            ),
          ],
        ),
      ),
    );
  }
}
