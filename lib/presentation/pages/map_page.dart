import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/usecases/poi_use_cases.dart';
import '../../injection_container.dart';
import '../services/location_permission_service.dart';
import '../services/poi_marker_factory.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
const _cream = Color(0xFFF7F3EE);
const _warmWhite = Color(0xFFFFFFFF);
const _olive = Color(0xFF5C6B3A);
const _moss = Color(0xFF8A9E5B);
const _tan = Color(0xFFB5885A);
const _tanLight = Color(0xFFE8D4BE);
const _textDark = Color(0xFF2C2C2C);
const _textMid = Color(0xFF7A7A7A);

// ─── Modello ──────────────────────────────────────────────────────────────────
class TourStop {
  final String id;
  final String name;
  final String period;
  final String description;
  final LatLng position;
  final IconData icon;
  final Color iconBg;
  final List<QuizQuestion> questions;

  const TourStop({
    required this.id,
    required this.name,
    required this.period,
    required this.description,
    required this.position,
    required this.icon,
    required this.iconBg,
    required this.questions,
  });
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

// ─── Dati demo ────────────────────────────────────────────────────────────────
final _allStops = <TourStop>[
  TourStop(
    id: 'rocca',
    name: 'Rocca Malatestiana',
    period: 'XIV sec.',
    description:
        'La Rocca Malatestiana è una fortezza medievale che domina il centro storico di Cesena. '
        'Costruita dai Malatesta nel 1380, ospita la Biblioteca Malatestiana, patrimonio UNESCO dal 2005.',
    position: const LatLng(44.1441, 12.2428),
    icon: Icons.castle_outlined,
    iconBg: Color(0xFFC8E6C9),
    questions: [
      QuizQuestion(
        question: 'Chi ha fatto costruire la Rocca?',
        options: ['I Visconti', 'I Malatesta', 'Federico da Montefeltro'],
        correctIndex: 1,
      ),
      QuizQuestion(
        question: 'In quale anno la Biblioteca è diventata patrimonio UNESCO?',
        options: ['1995', '2005', '2015'],
        correctIndex: 1,
      ),
    ],
  ),
  TourStop(
    id: 'duomo',
    name: 'Cattedrale di S. Giovanni',
    period: 'XII sec.',
    description:
        'La cattedrale di San Giovanni Battista è il principale luogo di culto cattolico di Cesena. '
        'La facciata neoclassica cela un interno ricco di opere d\'arte dal Medioevo al Barocco.',
    position: const LatLng(44.1435, 12.2442),
    icon: Icons.church_outlined,
    iconBg: Color(0xFFFFECB3),
    questions: [
      QuizQuestion(
        question: 'A quale santo è dedicata la cattedrale?',
        options: ['San Pietro', 'San Giovanni Battista', 'San Francesco'],
        correctIndex: 1,
      ),
    ],
  ),
  TourStop(
    id: 'piazza',
    name: 'Piazza del Popolo',
    period: 'Medioevo',
    description:
        'Il cuore pulsante di Cesena fin dal Medioevo. La piazza è dominata dal Palazzo del Ridotto '
        'e dalla fontana del Masini, punto di ritrovo storico per cesenati e visitatori.',
    position: const LatLng(44.1438, 12.2455),
    icon: Icons.account_balance_outlined,
    iconBg: Color(0xFFBBDEFB),
    questions: [
      QuizQuestion(
        question: 'Come si chiama la fontana in piazza?',
        options: [
          'Fontana di Nettuno',
          'Fontana del Masini',
          'Fontana dei Delfini',
        ],
        correctIndex: 1,
      ),
    ],
  ),
];

// ─── Helpers globali ──────────────────────────────────────────────────────────
const double _arrivedThresholdMeters = 50.0;

/// Ordina le tappe con algoritmo greedy nearest-neighbor.
/// Parte da [origin] (posizione utente), poi a ogni step sceglie
/// la tappa non ancora visitata più vicina all'ultima.
List<TourStop> _sortStopsGreedy(LatLng origin, List<TourStop> stops) {
  final remaining = List<TourStop>.from(stops);
  final result = <TourStop>[];
  LatLng current = origin;
  const dist = Distance();
  while (remaining.isNotEmpty) {
    remaining.sort(
      (a, b) => dist
          .as(LengthUnit.Meter, current, a.position)
          .compareTo(dist.as(LengthUnit.Meter, current, b.position)),
    );
    result.add(remaining.first);
    current = remaining.first.position;
    remaining.removeAt(0);
  }
  return result;
}

String _formatElapsed(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

String _formatDistance(double meters) {
  if (meters < 0) return '— m';
  return meters >= 1000
      ? '${(meters / 1000).toStringAsFixed(1)} km'
      : '${meters.round()} m';
}

// ─── Tour status ─────────────────────────────────────────────────────────────
enum TourStatus { idle, running, arrived }

// ─────────────────────────────────────────────────────────────────────────────
class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with WidgetsBindingObserver {
  // ── Map ────────────────────────────────────────────────────────────────────
  final MapController _mapController = MapController();
  final _locationPermissionService = const LocationPermissionService();
  final _poiMarkerFactory = const PoiMarkerFactory();

  AlignOnUpdate _alignPositionOnUpdate = AlignOnUpdate.always;
  StreamSubscription<ServiceStatus>? _serviceStatusSub;

  double _currentRotation = 0.0;
  bool _isMapLocked = false;
  bool _isMapMenuOpen = false;

  final String _urlStandard =
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';
  final String _urlSatellite =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
  late String _currentMapUrl;

  List<Marker> _markers = [];
  bool _isLoading = true;
  String? _loadError;

  // ── Tour ───────────────────────────────────────────────────────────────────
  TourStatus _tourStatus = TourStatus.idle;
  List<TourStop> _orderedStops = [];
  int _currentStopIndex = 0;
  LatLng? _userPosition;
  StreamSubscription<Position>? _positionSub;

  // ── Timer ──────────────────────────────────────────────────────────────────
  int _elapsedSeconds = 0;
  Timer? _timer;

  // ── Shortcut ───────────────────────────────────────────────────────────────
  TourStop get _currentStop => _orderedStops[_currentStopIndex];

  double get _distanceToCurrentStop {
    if (_userPosition == null || _orderedStops.isEmpty) return -1;
    return const Distance().as(
      LengthUnit.Meter,
      _userPosition!,
      _currentStop.position,
    );
  }

  // ── Init ───────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _currentMapUrl = _urlStandard;
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionsAndInitialize();
    _listenToServiceStatus();
    _loadPois();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _serviceStatusSub?.cancel();
    _positionSub?.cancel();
    _timer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkPermissionsAndInitialize();
  }

  // ── POI loading ────────────────────────────────────────────────────────────
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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _markers = [];
        _loadError = 'Errore nel caricamento dei punti di interesse.';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Caricamento POI fallito: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _checkPermissionsAndInitialize() async {
    final ok = await _locationPermissionService
        .ensureLocationEnabledAndAuthorized();
    if (!ok) return;
    if (mounted) setState(() {});
  }

  void _listenToServiceStatus() {
    if (kIsWeb) return;
    _serviceStatusSub = Geolocator.getServiceStatusStream().listen((status) {
      if (!mounted) return;
      if (status == ServiceStatus.disabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('GPS disattivato'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TOUR LOGIC
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _startTour() async {
    // 1. Ottieni posizione attuale (timeout 4s, fallback centro Cesena)
    LatLng origin = const LatLng(44.143043, 12.253486);
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 4));
      origin = LatLng(pos.latitude, pos.longitude);
      if (mounted) setState(() => _userPosition = origin);
    } catch (_) {
      // GPS non disponibile, usa fallback
    }

    // 2. Ordina greedy dalla posizione utente
    final sorted = _sortStopsGreedy(origin, List.from(_allStops));

    setState(() {
      _orderedStops = sorted;
      _currentStopIndex = 0;
      _tourStatus = TourStatus.running;
      _elapsedSeconds = 0;
    });

    // 3. Centra sulla prima tappa (con delay per lasciar renderizzare la mappa)
    _centerOnStop(_currentStop);

    // 4. Tracking posizione GPS
    _startPositionTracking();

    // 5. Avvia timer
    _restartTimer();
  }

  void _startPositionTracking() {
    _positionSub?.cancel();
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen(_onPositionUpdate);
  }

  void _onPositionUpdate(Position pos) {
    if (!mounted) return;
    setState(() => _userPosition = LatLng(pos.latitude, pos.longitude));
    if (_tourStatus == TourStatus.running && _orderedStops.isNotEmpty) {
      if (_distanceToCurrentStop >= 0 &&
          _distanceToCurrentStop <= _arrivedThresholdMeters) {
        _triggerArrival();
      }
    }
  }

  void _triggerArrival() {
    if (_tourStatus == TourStatus.arrived) return;
    _timer?.cancel();
    setState(() => _tourStatus = TourStatus.arrived);
  }

  void _manualArrival() => _triggerArrival();

  void _centerOnStop(TourStop stop) {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _mapController.move(stop.position, 17.0);
        setState(() => _alignPositionOnUpdate = AlignOnUpdate.never);
      }
    });
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_tourStatus == TourStatus.running) setState(() => _elapsedSeconds++);
    });
  }

  void _openPoiPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _warmWhite,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _PoiBottomSheet(
        stop: _currentStop,
        elapsedSeconds: _elapsedSeconds,
        onNextStop: () {
          Navigator.pop(context);
          _advanceToNextStop();
        },
      ),
    );
  }

  void _advanceToNextStop() {
    if (_currentStopIndex < _orderedStops.length - 1) {
      setState(() {
        _currentStopIndex++;
        _tourStatus = TourStatus.running;
        _elapsedSeconds = 0;
      });
      _centerOnStop(_currentStop);
      _restartTimer();
    } else {
      // Tour completato
      _timer?.cancel();
      _positionSub?.cancel();
      setState(() => _tourStatus = TourStatus.idle);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('🎉 Tour completato! Ottimo lavoro.'),
          backgroundColor: _olive,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPER UI
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildMapTypeSquare({
    required String title,
    required IconData icon,
    required Color bgColor,
    required String url,
  }) {
    final isSelected = _currentMapUrl == url;
    return GestureDetector(
      onTap: () => setState(() {
        _currentMapUrl = url;
        _isMapMenuOpen = false;
      }),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _olive : Colors.transparent,
            width: 3,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.black87),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
    );

    final bool tourActive = _tourStatus != TourStatus.idle;
    // Altezza card + padding bottom → i FAB devono stare sopra
    const double cardH = 82.0;
    const double cardPad = 12.0;
    const double cardBottom = cardH + cardPad * 2; // ~106

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _olive))
          : _loadError != null
          ? _buildErrorState()
          : Stack(
              children: [
                // ── Mappa ──────────────────────────────────────────────
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(44.143043, 12.253486),
                    initialZoom: 14.0,
                    minZoom: 3.0,
                    maxZoom: 19.0,
                    backgroundColor: const Color(0xFFE4E5E6),
                    interactionOptions: InteractionOptions(
                      flags: _isMapLocked
                          ? InteractiveFlag.none
                          : InteractiveFlag.all,
                    ),
                    onMapEvent: (event) {
                      if (event is MapEventMove || event is MapEventRotate) {
                        final r = _mapController.camera.rotation;
                        if ((r - _currentRotation).abs() > 0.1)
                          setState(() => _currentRotation = r);
                      }
                      if (event is MapEventMoveStart && _isMapMenuOpen) {
                        setState(() => _isMapMenuOpen = false);
                      }
                    },
                    onPositionChanged: (camera, hasGesture) {
                      if (hasGesture &&
                          _alignPositionOnUpdate != AlignOnUpdate.never) {
                        setState(
                          () => _alignPositionOnUpdate = AlignOnUpdate.never,
                        );
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
                          child: Icon(
                            Icons.navigation,
                            color: Colors.white,
                            size: 14,
                          ),
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

                // ── Overlay ────────────────────────────────────────────
                SafeArea(
                  child: Stack(
                    children: [
                      // Bussola (sempre top-right quando ruotato)
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

                      // ════════════════════════════════════════════════
                      // IDLE – bottoni standard in basso
                      // ════════════════════════════════════════════════
                      if (!tourActive) ...[
                        // Mappe (basso-sinistra)
                        Positioned(
                          left: 20,
                          bottom: 20,
                          child: _MapTypeButton(
                            isOpen: _isMapMenuOpen,
                            urlStandard: _urlStandard,
                            urlSatellite: _urlSatellite,
                            currentUrl: _currentMapUrl,
                            onToggle: () => setState(
                              () => _isMapMenuOpen = !_isMapMenuOpen,
                            ),
                            onSelect: (url) => setState(() {
                              _currentMapUrl = url;
                              _isMapMenuOpen = false;
                            }),
                            buildSquare: _buildMapTypeSquare,
                          ),
                        ),

                        // Lock
                        Positioned(
                          right: 20,
                          bottom: 90,
                          child: _CircleFab(
                            heroTag: 'btnLock',
                            icon: _isMapLocked ? Icons.lock : Icons.lock_open,
                            iconColor: _isMapLocked
                                ? Colors.red
                                : Colors.black54,
                            onTap: () =>
                                setState(() => _isMapLocked = !_isMapLocked),
                          ),
                        ),

                        // My location
                        Positioned(
                          right: 20,
                          bottom: 20,
                          child: _CircleFab(
                            heroTag: 'btnLoc',
                            icon: Icons.my_location,
                            iconColor:
                                _alignPositionOnUpdate == AlignOnUpdate.always
                                ? _olive
                                : Colors.black54,
                            onTap: () {
                              setState(
                                () => _alignPositionOnUpdate =
                                    AlignOnUpdate.always,
                              );
                              _checkPermissionsAndInitialize();
                            },
                          ),
                        ),

                        // Start tour (centro-basso)
                        Positioned(
                          bottom: 28,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: _StartTourButton(onTap: _startTour),
                          ),
                        ),
                      ],

                      // ════════════════════════════════════════════════
                      // TOUR ATTIVO – bottoni spostati sopra la card
                      // ════════════════════════════════════════════════
                      if (tourActive) ...[
                        // Mappe (basso-sinistra, sopra la card)
                        Positioned(
                          left: 20,
                          bottom: cardBottom,
                          child: _MapTypeButton(
                            isOpen: _isMapMenuOpen,
                            urlStandard: _urlStandard,
                            urlSatellite: _urlSatellite,
                            currentUrl: _currentMapUrl,
                            onToggle: () => setState(
                              () => _isMapMenuOpen = !_isMapMenuOpen,
                            ),
                            onSelect: (url) => setState(() {
                              _currentMapUrl = url;
                              _isMapMenuOpen = false;
                            }),
                            buildSquare: _buildMapTypeSquare,
                          ),
                        ),

                        // Lock (destra, sopra location + card)
                        Positioned(
                          right: 20,
                          bottom: cardBottom + 66,
                          child: _CircleFab(
                            heroTag: 'btnLock',
                            icon: _isMapLocked ? Icons.lock : Icons.lock_open,
                            iconColor: _isMapLocked
                                ? Colors.red
                                : Colors.black54,
                            onTap: () =>
                                setState(() => _isMapLocked = !_isMapLocked),
                          ),
                        ),

                        // My location (destra, sopra la card)
                        Positioned(
                          right: 20,
                          bottom: cardBottom + 8,
                          child: _CircleFab(
                            heroTag: 'btnLoc',
                            icon: Icons.my_location,
                            iconColor:
                                _alignPositionOnUpdate == AlignOnUpdate.always
                                ? _olive
                                : Colors.black54,
                            onTap: () {
                              setState(
                                () => _alignPositionOnUpdate =
                                    AlignOnUpdate.always,
                              );
                              _checkPermissionsAndInitialize();
                            },
                          ),
                        ),

                        // Pulsante "Sono arrivato" (solo durante running)
                        if (_tourStatus == TourStatus.running)
                          Positioned(
                            right: 20,
                            bottom: cardBottom + 132,
                            child: _ManualArrivalButton(onTap: _manualArrival),
                          ),

                        // Card prossima tappa
                        Positioned(
                          bottom: cardPad,
                          left: 16,
                          right: 16,
                          child: _NextStopCard(
                            stop: _currentStop,
                            stopIndex: _currentStopIndex,
                            totalStops: _orderedStops.length,
                            distanceLabel: _formatDistance(
                              _distanceToCurrentStop,
                            ),
                            elapsedSeconds: _elapsedSeconds,
                            arrived: _tourStatus == TourStatus.arrived,
                            onTap: _tourStatus == TourStatus.arrived
                                ? _openPoiPopup
                                : () => _centerOnStop(_currentStop),
                          ),
                        ),
                      ],
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
                backgroundColor: _olive,
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

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET: FAB circolare riutilizzabile
// ─────────────────────────────────────────────────────────────────────────────
class _CircleFab extends StatelessWidget {
  final String heroTag;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  const _CircleFab({
    required this.heroTag,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      backgroundColor: Colors.white,
      elevation: 4,
      shape: const CircleBorder(),
      onPressed: onTap,
      child: Icon(icon, color: iconColor),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET: Bottone mappe (estratto per riusarlo in idle/active)
// ─────────────────────────────────────────────────────────────────────────────
class _MapTypeButton extends StatelessWidget {
  final bool isOpen;
  final String urlStandard;
  final String urlSatellite;
  final String currentUrl;
  final VoidCallback onToggle;
  final ValueChanged<String> onSelect;
  final Widget Function({
    required String title,
    required IconData icon,
    required Color bgColor,
    required String url,
  })
  buildSquare;

  const _MapTypeButton({
    required this.isOpen,
    required this.urlStandard,
    required this.urlSatellite,
    required this.currentUrl,
    required this.onToggle,
    required this.onSelect,
    required this.buildSquare,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isOpen) ...[
          Row(
            children: [
              buildSquare(
                title: 'Standard',
                icon: Icons.map,
                bgColor: Colors.grey.shade100,
                url: urlStandard,
              ),
              const SizedBox(width: 12),
              buildSquare(
                title: 'Satellite',
                icon: Icons.satellite_alt,
                bgColor: Colors.green.shade100,
                url: urlSatellite,
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        FloatingActionButton.extended(
          heroTag: 'btnMapType',
          backgroundColor: Colors.white,
          elevation: 4,
          icon: Icon(
            isOpen ? Icons.close : Icons.layers,
            color: Colors.black87,
          ),
          label: Text(
            isOpen ? 'Chiudi' : 'Mappe',
            style: const TextStyle(color: Colors.black87),
          ),
          onPressed: onToggle,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET: Bottone Start Tour
// ─────────────────────────────────────────────────────────────────────────────
class _StartTourButton extends StatelessWidget {
  final VoidCallback onTap;
  const _StartTourButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: _olive,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: _olive.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.explore_outlined, color: Colors.white, size: 22),
            SizedBox(width: 10),
            Text(
              'Inizia il tour',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET: Card prossima tappa (con timer)
// ─────────────────────────────────────────────────────────────────────────────
class _NextStopCard extends StatelessWidget {
  final TourStop stop;
  final int stopIndex;
  final int totalStops;
  final String distanceLabel;
  final int elapsedSeconds;
  final bool arrived;
  final VoidCallback onTap;

  const _NextStopCard({
    required this.stop,
    required this.stopIndex,
    required this.totalStops,
    required this.distanceLabel,
    required this.elapsedSeconds,
    required this.arrived,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: _warmWhite,
          borderRadius: BorderRadius.circular(20),
          border: arrived ? Border.all(color: _olive, width: 1.5) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icona POI
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: stop.iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                stop.icon,
                size: 26,
                color: _textDark.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    stop.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        arrived ? Icons.check_circle : Icons.place_outlined,
                        size: 12,
                        color: arrived ? _olive : _moss,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          arrived
                              ? 'Sei arrivato! Tocca per aprire'
                              : '$distanceLabel · tappa ${stopIndex + 1}/$totalStops',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: arrived ? _olive : _textMid,
                            fontWeight: arrived
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Destra: timer oppure chevron arrivato
            if (arrived)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _olive.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: _olive,
                ),
              )
            else
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer_outlined, size: 14, color: _textMid),
                  const SizedBox(height: 2),
                  Text(
                    _formatElapsed(elapsedSeconds),
                    style: const TextStyle(
                      fontSize: 11,
                      color: _textMid,
                      fontWeight: FontWeight.w600,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET: Pulsante "Sono arrivato" manuale
// ─────────────────────────────────────────────────────────────────────────────
class _ManualArrivalButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ManualArrivalButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: _warmWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _moss.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.place, size: 15, color: _olive),
            SizedBox(width: 5),
            Text(
              'Sono arrivato',
              style: TextStyle(
                fontSize: 11.5,
                color: _olive,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM SHEET: POI – Informazioni / Quiz
// ─────────────────────────────────────────────────────────────────────────────
class _PoiBottomSheet extends StatefulWidget {
  final TourStop stop;
  final int elapsedSeconds;
  final VoidCallback onNextStop;

  const _PoiBottomSheet({
    required this.stop,
    required this.elapsedSeconds,
    required this.onNextStop,
  });

  @override
  State<_PoiBottomSheet> createState() => _PoiBottomSheetState();
}

class _PoiBottomSheetState extends State<_PoiBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _selectedAnswer;
  int _questionIndex = 0;
  int _score = 0;
  bool _quizDone = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  QuizQuestion get _currentQuestion => widget.stop.questions[_questionIndex];
  bool get _hasMoreQuestions =>
      _questionIndex < widget.stop.questions.length - 1;

  void _onAnswerTap(int idx) {
    if (_selectedAnswer != null) return;
    final correct = idx == _currentQuestion.correctIndex;
    setState(() {
      _selectedAnswer = idx;
      if (correct) _score++;
      if (!_hasMoreQuestions) _quizDone = true;
    });
  }

  void _nextQuestion() {
    setState(() {
      _questionIndex++;
      _selectedAnswer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.60,
      minChildSize: 0.45,
      maxChildSize: 0.90,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: _warmWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                decoration: BoxDecoration(
                  color: _tanLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: widget.stop.iconBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.stop.icon,
                        size: 24,
                        color: _textDark.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.stop.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                            ),
                          ),
                          Text(
                            widget.stop.period,
                            style: const TextStyle(
                              fontSize: 12,
                              color: _textMid,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Badge tempo
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _olive.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 12,
                            color: _olive,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatElapsed(widget.elapsedSeconds),
                            style: const TextStyle(
                              fontSize: 11,
                              color: _olive,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              Container(
                height: .5,
                color: _tanLight.withValues(alpha: 0.8),
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),

              TabBar(
                controller: _tabController,
                labelColor: _olive,
                unselectedLabelColor: _textMid,
                indicatorColor: _olive,
                indicatorWeight: 2,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                tabs: const [
                  Tab(text: 'Informazioni'),
                  Tab(text: 'Quiz'),
                ],
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // ── Informazioni ──────────────────────────────────
                    SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 140,
                            decoration: BoxDecoration(
                              color: widget.stop.iconBg,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Icon(
                                widget.stop.icon,
                                size: 56,
                                color: _textDark.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                width: 3,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: _olive,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                margin: const EdgeInsets.only(right: 8),
                              ),
                              const Text(
                                'Storia',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.stop.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: _textMid,
                              height: 1.65,
                            ),
                          ),
                          const SizedBox(height: 24),
                          GestureDetector(
                            onTap: () => _tabController.animateTo(1),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              decoration: BoxDecoration(
                                color: _tanLight.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: _tanLight),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.quiz_outlined,
                                    size: 16,
                                    color: _tan,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Fai il quiz su questa tappa →',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _tan,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Quiz ──────────────────────────────────────────
                    SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: _buildQuizContent(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuizContent() {
    if (_quizDone) {
      return Column(
        children: [
          _QuizResultCard(
            score: _score,
            total: widget.stop.questions.length,
            elapsed: widget.elapsedSeconds,
          ),
          const SizedBox(height: 20),
          _NextStopActionButton(onTap: widget.onNextStop),
        ],
      );
    }

    final q = _currentQuestion;
    final answered = _selectedAnswer != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Domanda ${_questionIndex + 1} di ${widget.stop.questions.length}',
              style: const TextStyle(fontSize: 12, color: _textMid),
            ),
            const Spacer(),
            if (_score > 0)
              Text(
                '$_score ✓',
                style: const TextStyle(
                  fontSize: 12,
                  color: _olive,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (_questionIndex + 1) / widget.stop.questions.length,
            backgroundColor: _tanLight,
            valueColor: const AlwaysStoppedAnimation<Color>(_olive),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          q.question,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _textDark,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),

        // Opzioni
        ...List.generate(q.options.length, (i) {
          final isSelected = _selectedAnswer == i;
          final isCorrect = i == q.correctIndex;
          Color bgColor = _warmWhite;
          Color borderColor = _tanLight;
          Color textColor = _textDark;
          IconData? trailing;

          if (answered) {
            if (isCorrect) {
              bgColor = const Color(0xFFEAF3DE);
              borderColor = _moss;
              textColor = const Color(0xFF3B6D11);
              trailing = Icons.check_circle_outline;
            } else if (isSelected) {
              bgColor = const Color(0xFFFCEBEB);
              borderColor = const Color(0xFFE24B4A);
              textColor = const Color(0xFFA32D2D);
              trailing = Icons.cancel_outlined;
            }
          }

          return GestureDetector(
            onTap: () => _onAnswerTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: borderColor,
                  width: isSelected || (answered && isCorrect) ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: answered
                          ? (isCorrect
                                ? _moss.withValues(alpha: 0.2)
                                : (isSelected
                                      ? const Color(
                                          0xFFE24B4A,
                                        ).withValues(alpha: 0.1)
                                      : _tanLight.withValues(alpha: 0.5)))
                          : _tanLight.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + i),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      q.options[i],
                      style: TextStyle(fontSize: 14, color: textColor),
                    ),
                  ),
                  if (trailing != null)
                    Icon(trailing, size: 18, color: textColor),
                ],
              ),
            ),
          );
        }),

        // Prossima domanda
        if (answered && _hasMoreQuestions) ...[
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _nextQuestion,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _olive,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'Prossima domanda →',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET: Card risultato quiz
// ─────────────────────────────────────────────────────────────────────────────
class _QuizResultCard extends StatelessWidget {
  final int score;
  final int total;
  final int elapsed;
  const _QuizResultCard({
    required this.score,
    required this.total,
    required this.elapsed,
  });

  @override
  Widget build(BuildContext context) {
    final perfect = score == total;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: perfect
            ? const Color(0xFFEAF3DE)
            : _tanLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: perfect ? _moss : _tanLight),
      ),
      child: Column(
        children: [
          Icon(
            perfect ? Icons.emoji_events_rounded : Icons.stars_rounded,
            size: 48,
            color: perfect ? _olive : _tan,
          ),
          const SizedBox(height: 12),
          Text(
            perfect ? 'Perfetto!' : 'Molto bravo!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: perfect ? _olive : _tan,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$score / $total risposte corrette',
            style: const TextStyle(fontSize: 15, color: _textMid),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer_outlined, size: 13, color: _textMid),
              const SizedBox(width: 4),
              Text(
                'Tempo: ${_formatElapsed(elapsed)}',
                style: const TextStyle(fontSize: 13, color: _textMid),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET: Bottone "Prossima tappa" (dentro il popup, dopo il quiz)
// ─────────────────────────────────────────────────────────────────────────────
class _NextStopActionButton extends StatelessWidget {
  final VoidCallback onTap;
  const _NextStopActionButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _olive,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _olive.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.directions_walk, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Prossima tappa →',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
