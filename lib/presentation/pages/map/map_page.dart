import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../domain/entities/tour_stop.dart';
import '../../../domain/usecases/poi_use_cases.dart';
import '../../../injection_container.dart';
import '../../controllers/tour_session_controller.dart';
import '../../services/poi_marker_factory.dart';
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

  static List<Marker>? _cachedMarkers;
  static List<TourStop>? _cachedStops;

  late TourSessionController _tourController;
  StreamSubscription<ServiceStatus>? _serviceStatusSub;
  StreamSubscription<void>? _tourUpdatesSub;

  AlignOnUpdate _alignPositionOnUpdate = AlignOnUpdate.always;
  double _currentRotation = 0.0;
  bool _isMapLocked = false;
  bool _isMapMenuOpen = false;

  // --- IL NUOVO MOTORE GPS BLINDATO ---
  bool _isGpsEnabled = false;
  bool _hasPermissions = false;
  bool _isCheckingLocation = true; // Scudo per nascondere il banner all'avvio

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
    _tourController = TourSessionController(availableStops: const []);
    _bindTourUpdates();

    _initLocationLogic();
    _loadPois();
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
      // Se l'utente torna dalle impostazioni del telefono, ricalcoliamo tutto
      _verifyLocationState(requestPerms: false);
    }
  }

  Future<void> _initLocationLogic() async {
    // 1. Controlla e chiedi permessi all'avvio
    await _verifyLocationState(requestPerms: true);

    // 2. Mettiti in ascolto del chip GPS (Hardware)
    if (kIsWeb) return;
    _serviceStatusSub = Geolocator.getServiceStatusStream().listen((status) {
      if (!mounted) return;
      setState(() {
        _isGpsEnabled = (status == ServiceStatus.enabled);
      });
    });
  }

  // IL METODO SUPREMO CHE CALCOLA LA VERITÀ SUL GPS
  Future<void> _verifyLocationState({required bool requestPerms}) async {
    if (kIsWeb) {
      if (mounted) setState(() => _isCheckingLocation = false);
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
        _isCheckingLocation = false; // Abbassa lo scudo, aggiorna l'interfaccia
      });
    }
  }

  // Azione del bottone "Risolvi" nel banner
  Future<void> _resolveLocationIssues() async {
    if (!_isGpsEnabled) {
      await Geolocator.openLocationSettings();
      // Quando torna, l'appLifecycle (resumed) farà ripartire il controllo
    } else if (!_hasPermissions) {
      await Geolocator.openAppSettings();
    }
  }

  Future<void> _loadPois() async {
    if (_cachedMarkers != null && _cachedStops != null) {
      _tourController.dispose();
      _tourController = TourSessionController(availableStops: _cachedStops!);
      _bindTourUpdates();
      setState(() {
        _markers = _cachedMarkers!;
        _isLoading = false;
      });
      return;
    }

    try {
      final getPois = sl<GetPoisUseCase>();
      final pois = await getPois();
      if (!mounted) return;

      final stops = _tourStopMapper.fromPois(pois);
      final markers = pois
          .map(_poiMarkerFactory.fromPoi)
          .toList(growable: false);

      _cachedStops = stops;
      _cachedMarkers = markers;

      _tourController.dispose();
      _tourController = TourSessionController(availableStops: stops);
      _bindTourUpdates();

      setState(() {
        _markers = markers;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Errore nel caricamento dei punti di interesse.';
        _isLoading = false;
      });
    }
  }

  void _bindTourUpdates() {
    _tourUpdatesSub?.cancel();
    _tourUpdatesSub = _tourController.updates.listen((_) {
      if (mounted) setState(() {});
    });
  }

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
            if (_tourController.currentStop != null)
              _centerOnStop(_tourController.currentStop!.position);
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

    // LA CONDIZIONE PERFETTA: Funziona solo se abbiamo SIA permessi SIA hardware acceso
    final bool canUseLocation = _isGpsEnabled && _hasPermissions;

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
                panBuffer: 0,
              ),

              // IL PALLINO BLU: Niente più stream difettosi. Gestisce tutto da solo!
              if (canUseLocation)
                CurrentLocationLayer(
                  alignPositionOnUpdate: _alignPositionOnUpdate,
                  alignDirectionOnUpdate: AlignOnUpdate.never,
                  style: LocationMarkerStyle(
                    marker: const DefaultLocationMarker(
                      color: Colors.blue,
                      child: Icon(
                        Icons.navigation,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    markerSize: const Size(40, 40),
                    markerDirection: MarkerDirection.heading,
                    accuracyCircleColor: Colors.blue.withOpacity(0.1),
                    headingSectorColor: Colors.blue.withOpacity(0.2),
                    headingSectorRadius: 60,
                  ),
                ),
              MarkerLayer(markers: _markers),
            ],
          ),
          SafeArea(
            child: Stack(
              children: [
                // ── BANNER UI FIGA PER GPS DISATTIVATO ──
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
                                          ? 'Permessi mancanti'
                                          : 'GPS Disattivato',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Attiva la posizione per esplorare la mappa in tempo reale.',
                                      style: TextStyle(
                                        fontSize: 12.5,
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed:
                                    _resolveLocationIssues, // Cliccando qui apre le impostazioni
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

                // ────────────────────────────────────────
                if (_currentRotation != 0)
                  Positioned(
                    top: 100,
                    right: 20,
                    child: GestureDetector(
                      onTap: () {
                        _mapController.rotate(0);
                        setState(() => _currentRotation = 0);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
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
                            color: AppPalette.danger,
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
                    heroTag: 'btnLock',
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
                    heroTag: 'btnLoc',
                    icon: Icons.my_location,
                    iconColor: _alignPositionOnUpdate == AlignOnUpdate.always
                        ? AppPalette.olive
                        : theme.colorScheme.onSurfaceVariant,
                    onTap: () {
                      setState(
                        () => _alignPositionOnUpdate = AlignOnUpdate.always,
                      );
                      _verifyLocationState(requestPerms: true);
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
