import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../domain/entities/poi.dart';
import '../../../domain/entities/tour_stop.dart';
import '../../../domain/usecases/poi_use_cases.dart';
import '../../../injection_container.dart';
import '../../controllers/tour_session_controller.dart';
import '../../services/poi_marker_factory.dart';
import '../../services/location_preference_store.dart';
import '../../services/shell_navigation_store.dart';
import '../../services/tour_stop_mapper.dart';
import '../../theme/app_palette.dart';
import 'widgets/map_controls.dart';
import 'widgets/poi_bottom_sheet.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with WidgetsBindingObserver {
  final MapController _mapController = MapController();
  final _poiMarkerFactory = const PoiMarkerFactory();
  final TourStopMapper _tourStopMapper = const TourStopMapper();

  static final LatLngBounds _cesenaBounds = LatLngBounds(
    const LatLng(44.0700, 12.1700),
    const LatLng(44.2050, 12.3350),
  );

  // Cache per non ricaricare tutto ogni volta che si cambia tab
  static List<Poi>? _cachedPois;
  static List<TourStop>? _cachedStops;

  late TourSessionController _tourController;
  StreamSubscription<ServiceStatus>? _serviceStatusSub;
  StreamSubscription<void>? _tourUpdatesSub;

  AlignOnUpdate _alignPositionOnUpdate = AlignOnUpdate.always;
  double _currentRotation = 0.0;
  bool _isMapLocked = false;
  bool _isMapMenuOpen = false;

  // --- MOTORE GPS REATTIVO ---
  bool _isGpsEnabled = false;
  bool _hasPermissions = false;
  bool _isGpsPreferenceEnabled = LocationPreferenceStore.gpsEnabled.value;
  bool _isCheckingLocation = true; // Scudo anti-sfarfallio del banner
  bool _isCenteringOnUser = false;

  List<Poi> _pois = [];
  bool _isLoading = true;
  String? _loadError;

  static const _urlStandard =
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';
  static const _urlSatellite =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
  String _currentMapUrl = _urlStandard;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tourController = TourSessionController(availableStops: const []);
    _bindTourUpdates();
    LocationPreferenceStore.gpsEnabled.addListener(_onGpsPreferenceChanged);

    _initLocationLogic();
    _loadPois();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _serviceStatusSub?.cancel();
    _tourUpdatesSub?.cancel();
    LocationPreferenceStore.gpsEnabled.removeListener(_onGpsPreferenceChanged);
    _tourController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _verifyLocationState(requestPerms: false);
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  LOGICA POSIZIONE E GPS
  // ──────────────────────────────────────────────────────────────────────────

  void _onGpsPreferenceChanged() {
    if (!mounted) return;
    final enabled = LocationPreferenceStore.gpsEnabled.value;
    setState(() {
      _isGpsPreferenceEnabled = enabled;
      if (!enabled) {
        _alignPositionOnUpdate = AlignOnUpdate.never;
      }
    });
  }

  Future<void> _initLocationLogic() async {
    await _verifyLocationState(requestPerms: true);
    if (kIsWeb) return;
    _serviceStatusSub = Geolocator.getServiceStatusStream().listen((status) {
      if (!mounted) return;
      setState(() {
        _isGpsEnabled = (status == ServiceStatus.enabled);
      });
      _verifyLocationState(requestPerms: false);
    });
  }

  Future<void> _verifyLocationState({required bool requestPerms}) async {
    if (kIsWeb) {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied && requestPerms) {
        perm = await Geolocator.requestPermission();
      }
      final hasPerm =
          perm == LocationPermission.whileInUse ||
          perm == LocationPermission.always;
      if (mounted) {
        setState(() {
          _isGpsEnabled = true;
          _hasPermissions = hasPerm;
          _isCheckingLocation = false;
        });
      }
      return;
    }

    setState(() => _isCheckingLocation = true);

    bool gps = await Geolocator.isLocationServiceEnabled();
    LocationPermission perm = await Geolocator.checkPermission();

    if (perm == LocationPermission.denied && requestPerms) {
      perm = await Geolocator.requestPermission();
    }

    bool hasPerm =
        (perm == LocationPermission.whileInUse ||
        perm == LocationPermission.always);

    if (mounted) {
      setState(() {
        _isGpsEnabled = gps;
        _hasPermissions = hasPerm;
        _isCheckingLocation = false;
      });
    }
  }

  Future<void> _resolveLocationIssues() async {
    ShellNavigationStore.openSettingsAndFocusGpsToggle();
  }

  Future<void> _centerOnUserLocation() async {
    if (_isCenteringOnUser) return;

    if (!_isGpsPreferenceEnabled) {
      _resolveLocationIssues();
      return;
    }

    setState(() {
      _isCenteringOnUser = true;
      _alignPositionOnUpdate = AlignOnUpdate.always;
    });

    try {
      await _verifyLocationState(requestPerms: true);
      final canUseLocation =
          _isGpsEnabled && _hasPermissions && _isGpsPreferenceEnabled;
      if (!canUseLocation) return;

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation,
          timeLimit: const Duration(seconds: 6),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position != null && mounted) {
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          math.max(_mapController.camera.zoom, 16.5),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCenteringOnUser = false);
      }
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  CARICAMENTO DATI POI
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _loadPois() async {
    if (_cachedPois != null && _cachedStops != null) {
      _tourController.dispose();
      _tourController = TourSessionController(availableStops: _cachedStops!);
      _bindTourUpdates();
      setState(() {
        _pois = _cachedPois!;
        _isLoading = false;
      });
      return;
    }

    try {
      final getPois = sl<GetPoisUseCase>();
      final pois = await getPois();
      if (!mounted) return;

      final stops = _tourStopMapper.fromPois(pois);
      _cachedStops = stops;
      _cachedPois = pois;

      _tourController.dispose();
      _tourController = TourSessionController(availableStops: stops);
      _bindTourUpdates();

      setState(() {
        _pois = pois;
        _loadError = null;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _pois = [];
        _loadError = 'Errore nel caricamento dei punti di interesse.';
        _isLoading = false;
      });
    }
  }

  List<Marker> _buildMarkers() {
    return _pois
        .map(
          (poi) => _poiMarkerFactory.fromPoi(
            poi,
            counterRotationDegrees: _currentRotation,
          ),
        )
        .toList(growable: false);
  }

  void _bindTourUpdates() {
    _tourUpdatesSub?.cancel();
    _tourUpdatesSub = _tourController.updates.listen((_) {
      if (mounted) setState(() {});
    });
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  AZIONI TOUR E MAPPA
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _startTour() async {
    if (!_tourController.hasStops) return;
    final hasStarted = await _tourController.startTour();
    if (hasStarted && mounted && _tourController.currentStop != null) {
      _centerOnStop(_tourController.currentStop!.position);
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
      backgroundColor: Theme.of(context).colorScheme.surface,
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
          if (_tourController.advanceToNextStop()) {
            if (_tourController.currentStop != null) {
              _centerOnStop(_tourController.currentStop!.position);
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
    final theme = Theme.of(context);
    const LatLng defaultCesenaCenter = LatLng(44.1391, 12.2431);

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
    );

    const cardHeight = 82.0;
    const cardPadding = 12.0;
    const cardBottom = cardHeight + cardPadding * 2;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: AppPalette.olive),
        ),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: _buildErrorState(theme),
      );
    }

    final currentStop = _tourController.currentStop;
    final isTourActive = _tourController.isActive;
    final bool canUseLocation =
        _isGpsEnabled && _hasPermissions && _isGpsPreferenceEnabled;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: defaultCesenaCenter,
              initialZoom: 14.0,
              minZoom: 10.0,
              maxZoom: 18.5,
              cameraConstraint: CameraConstraint.contain(bounds: _cesenaBounds),
              backgroundColor: theme.scaffoldBackgroundColor,
              interactionOptions: InteractionOptions(
                flags: _isMapLocked
                    ? InteractiveFlag.none
                    : InteractiveFlag.all,
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
                tileBounds: _cesenaBounds,
              ),
              // PALLINO POSIZIONE
              if (canUseLocation)
                CurrentLocationLayer(
                  alignPositionOnUpdate: _alignPositionOnUpdate,
                  style: LocationMarkerStyle(
                    marker: const DefaultLocationMarker(
                      color: Colors.blue,
                      child: Icon(
                        Icons.navigation,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    accuracyCircleColor: Colors.blue.withOpacity(0.1),
                    headingSectorColor: Colors.blue.withOpacity(0.2),
                  ),
                  positionStream: const LocationMarkerDataStreamFactory()
                      .fromGeolocatorPositionStream(
                        stream: Geolocator.getPositionStream(
                          locationSettings: locationSettings,
                        ),
                      ),
                ),
              // MARKERS POI (RUOTATI)
              MarkerLayer(markers: _buildMarkers()),
            ],
          ),

          SafeArea(
            child: Stack(
              children: [
                // ── BANNER GPS DISATTIVATO ──
                if (!_isCheckingLocation && !canUseLocation)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppPalette.danger.withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppPalette.danger.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.location_off_rounded,
                                  color: AppPalette.danger,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _isGpsEnabled
                                          ? (_isGpsPreferenceEnabled
                                                ? 'Permessi mancanti'
                                                : 'Posizione disattivata')
                                          : 'GPS Disattivato',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _isGpsPreferenceEnabled
                                          ? 'Attiva la posizione per esplorare la mappa in tempo reale.'
                                          : 'Riattiva la posizione nelle impostazioni per mostrare la tua posizione sulla mappa.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.3,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppPalette.danger,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _resolveLocationIssues,
                                child: const Text(
                                  'Risolvi',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // ── CONTROLLI MAPPA ──
                if (_currentRotation != 0)
                  Positioned(
                    top: canUseLocation ? 16 : 100,
                    right: 20,
                    child: CircleFab(
                      heroTag: 'rot',
                      icon: Icons.navigation,
                      iconColor: AppPalette.danger,
                      onTap: () {
                        _mapController.rotate(0);
                        setState(() => _currentRotation = 0);
                      },
                    ),
                  ),
                Positioned(
                  left: 20,
                  bottom: isTourActive ? cardBottom : 20,
                  child: MapTypeButton(
                    isOpen: _isMapMenuOpen,
                    urlStandard: _urlStandard,
                    urlSatellite: _urlSatellite,
                    onToggle: () =>
                        setState(() => _isMapMenuOpen = !_isMapMenuOpen),
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
                    heroTag: 'lock',
                    icon: _isMapLocked ? Icons.lock : Icons.lock_open,
                    iconColor: _isMapLocked
                        ? AppPalette.danger
                        : theme.colorScheme.onSurfaceVariant,
                    onTap: () => setState(() => _isMapLocked = !_isMapLocked),
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: isTourActive ? cardBottom + 8 : 20,
                  child: CircleFab(
                    heroTag: 'loc',
                    icon: Icons.my_location,
                    iconColor: _isCenteringOnUser
                        ? AppPalette.olive
                        : _alignPositionOnUpdate == AlignOnUpdate.always
                        ? AppPalette.olive
                        : theme.colorScheme.onSurfaceVariant,
                    onTap: _centerOnUserLocation,
                  ),
                ),

                // ── INTERFACCIA TOUR ──
                if (!isTourActive)
                  Positioned(
                    bottom: 28,
                    left: 0,
                    right: 0,
                    child: Center(child: StartTourButton(onTap: _startTour)),
                  ),
                if (isTourActive &&
                    _tourController.status == TourStatus.running)
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

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppPalette.danger, size: 42),
            const SizedBox(height: 12),
            Text(
              _loadError!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
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
              ),
              child: const Text('Riprova'),
            ),
          ],
        ),
      ),
    );
  }
}
