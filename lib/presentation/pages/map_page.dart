import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/poi.dart';
import '../../domain/usecases/poi_use_cases.dart';
import '../../injection_container.dart';
import '../services/location_permission_service.dart';
import '../services/poi_marker_factory.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with WidgetsBindingObserver {
  final MapController _mapController = MapController();
  final _locationPermissionService = const LocationPermissionService();
  final _poiMarkerFactory = const PoiMarkerFactory();
  static final LatLngBounds _cesenaBounds = LatLngBounds(
    const LatLng(44.0400, 12.1200),
    const LatLng(44.2500, 12.3800),
  );

  AlignOnUpdate _alignPositionOnUpdate = AlignOnUpdate.always;

  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;
  StreamSubscription<Position>? _positionStreamSubscription;

  double _currentRotation = 0.0;
  bool _isMapLocked = false;
  bool _isMapMenuOpen = false;

  final String _urlStandard =
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';
  final String _urlSatellite =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
  late String _currentMapUrl;

  List<Marker> _markers = [];
  List<Poi> _pois = [];
  bool _isLoading = true;
  String? _loadError;

  Poi? _activeTourPoi;
  double? _activeTourDistanceMeters;
  bool _arrivalHandled = false;

  @override
  void initState() {
    super.initState();
    _currentMapUrl = _urlStandard;
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionsAndInitialize();
    _listenToServiceStatus();
    _startPositionTracking();
    _loadPois();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _serviceStatusStreamSubscription?.cancel();
    _positionStreamSubscription?.cancel();
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
        _pois = pois;
        _markers = pois.map(_poiMarkerFactory.fromPoi).toList();
        _loadError = null;
        _isLoading = false;
      });
      unawaited(_precachePoiImages());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pois = [];
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
    final result =
        await _locationPermissionService.ensureLocationEnabledAndAuthorized();
    if (!result.granted) {
      if (mounted && result.message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message!),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (mounted) setState(() {});
  }

  void _listenToServiceStatus() {
    if (kIsWeb) return;
    _serviceStatusStreamSubscription = Geolocator.getServiceStatusStream().listen(
      (ServiceStatus status) {
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
      },
    );
  }

  void _startPositionTracking() {
    const trackingSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 3,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: trackingSettings,
    ).listen((position) {
      final tourPoi = _activeTourPoi;
      if (tourPoi == null) return;

      final distanceMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        tourPoi.latitude,
        tourPoi.longitude,
      );

      if (!mounted) return;
      setState(() => _activeTourDistanceMeters = distanceMeters);

      if (!_arrivalHandled && distanceMeters <= 40) {
        _arrivalHandled = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sei arrivato a ${tourPoi.name}!'),
            backgroundColor: Colors.green,
          ),
        );
        _showPoiPopup(tourPoi);
      }
    });
  }

  Future<void> _startTour() async {
    if (_pois.isEmpty) return;

    LatLng reference = const LatLng(44.143043, 12.253486);
    final current = await _locationPermissionService.getCurrentPositionSafely();
    if (current != null) {
      reference = LatLng(current.latitude, current.longitude);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GPS non disponibile: uso centro Cesena come fallback.'),
          backgroundColor: Colors.orange,
        ),
      );
    }

    Poi nearest = _pois.first;
    double minDistance = double.infinity;

    for (final poi in _pois) {
      final distance = Geolocator.distanceBetween(
        reference.latitude,
        reference.longitude,
        poi.latitude,
        poi.longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
        nearest = poi;
      }
    }

    _mapController.move(LatLng(nearest.latitude, nearest.longitude), 16);

    if (!mounted) return;
    setState(() {
      _activeTourPoi = nearest;
      _activeTourDistanceMeters = minDistance;
      _arrivalHandled = false;
    });
  }

  String _poiImageUrl(Poi poi) {
    switch (poi.id) {
      case '1':
        return 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/33/School_building_icon.svg/320px-School_building_icon.svg.png';
      case '2':
        return 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/10/Bridge_icon.svg/320px-Bridge_icon.svg.png';
      case '3':
        return 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/Books-aj.svg_aj_ashton_01.svg/320px-Books-aj.svg_aj_ashton_01.svg.png';
      default:
        return 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/320px-No_image_available.svg.png';
    }
  }

  String _distanceLabel(double? meters) {
    if (meters == null) return 'Distanza non disponibile';
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(2)} km';
    return '${meters.toStringAsFixed(0)} m';
  }

  void _openQuizManually() {
    final poi = _activeTourPoi;
    if (poi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prima avvia un tour.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    _showPoiPopup(poi);
  }

  Future<void> _showPoiPopup(Poi poi) async {
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return DefaultTabController(
          length: 2,
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.62,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  poi.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.info_outline), text: 'Informazioni'),
                    Tab(icon: Icon(Icons.quiz_outlined), text: 'Quiz'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _poiImageUrl(poi),
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 180,
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tappa: ${poi.name}\n'
                            'Tipo: ${poi.type}\n'
                            'Questa sezione ospiterà descrizione storica e carosello immagini.',
                            style: const TextStyle(fontSize: 15, height: 1.4),
                          ),
                        ],
                      ),
                      ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          const Text(
                            'Quiz rapido',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'In quale città si trova questa tappa?',
                            style: TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 10),
                          ...['Cesena', 'Ravenna', 'Bologna', 'Forlì'].map(
                            (option) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: OutlinedButton(
                                onPressed: () {
                                  final isCorrect = option == 'Cesena';
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isCorrect
                                            ? 'Risposta corretta! +10 punti'
                                            : 'Risposta errata',
                                      ),
                                      backgroundColor:
                                          isCorrect ? Colors.green : Colors.red,
                                    ),
                                  );
                                },
                                child: Text(option),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Nota: questa è una versione base utile per sviluppo e test.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _centerOnMyLocation() async {
    final result =
        await _locationPermissionService.ensureLocationEnabledAndAuthorized();
    if (!result.granted) {
      if (mounted && result.message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message!),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final position = await _locationPermissionService.getCurrentPositionSafely();
    if (position == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossibile ottenere la posizione attuale.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final target = LatLng(position.latitude, position.longitude);
    if (!_cesenaBounds.contains(target)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Posizione fuori dall’area di Cesena.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _mapController.move(target, 16);
    if (mounted) {
      setState(() => _alignPositionOnUpdate = AlignOnUpdate.always);
    }
  }

  Future<void> _precachePoiImages() async {
    for (final poi in _pois) {
      final image = NetworkImage(_poiImageUrl(poi));
      await precacheImage(image, context);
    }
  }

  Widget _buildMapTypeSquare({
    required String title,
    required IconData icon,
    required Color bgColor,
    required String url,
  }) {
    final isSelected = _currentMapUrl == url;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentMapUrl = url;
          _isMapMenuOpen = false;
        });
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
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

  @override
  Widget build(BuildContext context) {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
    );

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? Center(
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
                      child: const Text('Riprova'),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(44.143043, 12.253486),
                    initialZoom: 14.0,
                    minZoom: 12.0,
                    maxZoom: 18.0,
                    cameraConstraint: CameraConstraint.contain(
                      bounds: _cesenaBounds,
                    ),
                    backgroundColor: const Color(0xFFE4E5E6),
                    interactionOptions: InteractionOptions(
                      flags: _isMapLocked
                          ? InteractiveFlag.none
                          : InteractiveFlag.all,
                    ),
                    onMapEvent: (MapEvent event) {
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
                    onPositionChanged: (MapCamera camera, bool hasGesture) {
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
                      maxZoom: 18,
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
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isMapMenuOpen) ...[
                              Row(
                                children: [
                                  _buildMapTypeSquare(
                                    title: 'Standard',
                                    icon: Icons.map,
                                    bgColor: Colors.grey.shade100,
                                    url: _urlStandard,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildMapTypeSquare(
                                    title: 'Satellite',
                                    icon: Icons.satellite_alt,
                                    bgColor: Colors.green.shade100,
                                    url: _urlSatellite,
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
                                _isMapMenuOpen ? Icons.close : Icons.layers,
                                color: Colors.black87,
                              ),
                              label: Text(
                                _isMapMenuOpen ? 'Chiudi' : 'Mappe',
                                style: const TextStyle(color: Colors.black87),
                              ),
                              onPressed: () => setState(
                                () => _isMapMenuOpen = !_isMapMenuOpen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 20,
                        bottom: 160,
                        child: FloatingActionButton.small(
                          heroTag: 'btnManualQuiz',
                          backgroundColor: Colors.white,
                          elevation: 4,
                          onPressed: _openQuizManually,
                          child:
                              const Icon(Icons.auto_awesome, color: Colors.purple),
                        ),
                      ),
                      Positioned(
                        right: 20,
                        bottom: 90,
                        child: FloatingActionButton(
                          heroTag: 'btnLockMap',
                          backgroundColor: Colors.white,
                          elevation: 4,
                          shape: const CircleBorder(),
                          child: Icon(
                            _isMapLocked ? Icons.lock : Icons.lock_open,
                            color: _isMapLocked ? Colors.red : Colors.black54,
                          ),
                          onPressed: () =>
                              setState(() => _isMapLocked = !_isMapLocked),
                        ),
                      ),
                      Positioned(
                        right: 20,
                        bottom: 20,
                        child: FloatingActionButton(
                          heroTag: 'btnMyLocation',
                          backgroundColor: Colors.white,
                          elevation: 4,
                          shape: const CircleBorder(),
                          child: Icon(
                            Icons.my_location,
                            color: _alignPositionOnUpdate == AlignOnUpdate.always
                                ? Colors.blue
                                : Colors.black54,
                          ),
                          onPressed: () {
                            _centerOnMyLocation();
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 24,
                        left: 24,
                        right: 24,
                        child: Center(
                          child: _activeTourPoi == null
                              ? FloatingActionButton.extended(
                                  heroTag: 'btnStartTour',
                                  onPressed: _startTour,
                                  backgroundColor: Colors.blue,
                                  icon: const Icon(Icons.play_arrow),
                                  label: const Text('Inizia Tour'),
                                )
                              : GestureDetector(
                                  onTap: () => _showPoiPopup(_activeTourPoi!),
                                  child: Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 380),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.blue.shade100,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.network(
                                            _poiImageUrl(_activeTourPoi!),
                                            width: 72,
                                            height: 72,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                              width: 72,
                                              height: 72,
                                              color: Colors.grey.shade200,
                                              child: const Icon(
                                                Icons.image_not_supported,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _activeTourPoi!.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                _distanceLabel(
                                                  _activeTourDistanceMeters,
                                                ),
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
