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

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with WidgetsBindingObserver {
  final MapController _mapController = MapController();
  final _locationPermissionService = const LocationPermissionService();
  final _poiMarkerFactory = const PoiMarkerFactory();

  AlignOnUpdate _alignPositionOnUpdate = AlignOnUpdate.always;

  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;

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

  @override
  void initState() {
    super.initState();
    _currentMapUrl = _urlStandard;
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionsAndInitialize();
    _listenToServiceStatus();
    _loadPois();
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _serviceStatusStreamSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissionsAndInitialize();
    }
  }

  Future<void> _checkPermissionsAndInitialize() async {
    final hasPermission = await _locationPermissionService
        .ensureLocationEnabledAndAuthorized();
    if (!hasPermission) return;

    if (mounted) setState(() {});
  }

  void _listenToServiceStatus() {
    if (kIsWeb) return;
    _serviceStatusStreamSubscription = Geolocator.getServiceStatusStream()
        .listen((ServiceStatus status) {
          if (!mounted) return;
          if (status == ServiceStatus.disabled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("GPS disattivato"),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
        });
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
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 42,
                    ),
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
                    minZoom: 3.0,
                    maxZoom: 19.0,
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
                              heroTag: "btnMapType",
                              backgroundColor: Colors.white,
                              elevation: 4,
                              icon: Icon(
                                _isMapMenuOpen ? Icons.close : Icons.layers,
                                color: Colors.black87,
                              ),
                              label: Text(
                                _isMapMenuOpen ? "Chiudi" : "Mappe",
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
                        bottom: 90,
                        child: FloatingActionButton(
                          heroTag: "btnLockMap",
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
                          heroTag: "btnMyLocation",
                          backgroundColor: Colors.white,
                          elevation: 4,
                          shape: const CircleBorder(),
                          child: Icon(
                            Icons.my_location,
                            color:
                                _alignPositionOnUpdate == AlignOnUpdate.always
                                ? Colors.blue
                                : Colors.black54,
                          ),
                          onPressed: () {
                            setState(
                              () =>
                                  _alignPositionOnUpdate = AlignOnUpdate.always,
                            );
                            _checkPermissionsAndInitialize();
                          },
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
