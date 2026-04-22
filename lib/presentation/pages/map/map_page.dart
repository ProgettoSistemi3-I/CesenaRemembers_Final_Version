import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/offline/offline_map_repository.dart';
import '../../../domain/entities/poi.dart';
import '../../../domain/entities/tour_stop.dart';
import '../../../domain/services/tour_scoring_service.dart';
import '../../../domain/usecases/poi_use_cases.dart';
import '../../../domain/usecases/user_use_cases.dart';
import '../../../injection_container.dart';
import '../../controllers/tour_session_controller.dart';
import '../../services/local_file_tile_provider.dart';
import '../../services/location_preference_store.dart';
import '../../services/poi_marker_factory.dart';
import '../../services/shell_navigation_store.dart';
import '../../services/tour_stop_mapper.dart';
import '../../services/tour_stop_visuals.dart';
import '../../theme/app_palette.dart';
import 'widgets/location_issue_banner.dart';
import 'widgets/map_controls.dart';
import 'widgets/poi_bottom_sheet.dart';

part 'map_page_data.dart';
part 'map_page_location.dart';
part 'map_page_tour.dart';
part 'map_page_view.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with WidgetsBindingObserver {
  final MapController _mapController = MapController();
  final _poiMarkerFactory = const PoiMarkerFactory();
  final TourStopMapper _tourStopMapper = const TourStopMapper();
  final TourStopVisuals _tourStopVisuals = const TourStopVisuals();
  final TourScoringService _tourScoringService = const TourScoringService();
  final UserUseCases _userUseCases = sl<UserUseCases>();

  static final LatLngBounds _cesenaBounds = LatLngBounds(
    const LatLng(44.1054, 12.2131),
    const LatLng(44.1714, 12.2811),
  );

  static List<Poi>? _cachedPois;
  static List<TourStop>? _cachedStops;
  static bool _hasRequestedInitialLocationPermission = false;

  late TourSessionController _tourController;
  StreamSubscription<ServiceStatus>? _serviceStatusSub;
  StreamSubscription<void>? _tourUpdatesSub;
  late final OfflineMapRepository _offlineMapRepository;

  AlignOnUpdate _alignPositionOnUpdate = AlignOnUpdate.never;
  double _currentRotation = 0.0;
  bool _isMapLocked = false;
  bool _isMapMenuOpen = false;

  bool _isGpsEnabled = false;
  bool _hasPermissions = false;
  bool _isGpsPreferenceEnabled = LocationPreferenceStore.gpsEnabled.value;
  bool _isCheckingLocation = true;
  bool _isCenteringOnUser = false;
  bool _isSavingQuizResult = false;

  List<Poi> _pois = [];
  bool _isLoading = true;
  String? _loadError;

  static const _urlStandard =
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';
  static const _urlStandardDark =
      'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png?api_key=8331ce94-8651-4d9c-9534-b5891833b33e';
  static const _urlSatellite =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

  _MapBuildData get _buildData => _MapBuildData(
    theme: Theme.of(context),
    standardMapUrl: Theme.of(context).brightness == Brightness.dark
        ? _urlStandardDark
        : _urlStandard,
    localTileProvider: LocalFileTileProvider(
      cacheRootPath: _offlineMapRepository.localCachePath,
    ),
    currentStop: _tourController.currentStop,
    isTourActive: _tourController.isActive,
    canUseLocation: _isGpsEnabled && _hasPermissions && _isGpsPreferenceEnabled,
    isLocationBannerVisible:
        !_isCheckingLocation && !(_isGpsEnabled && _hasPermissions && _isGpsPreferenceEnabled),
    currentStopVisual: _tourController.currentStop == null
        ? null
        : _tourStopVisuals.forStop(_tourController.currentStop!),
  );

  MapStyle _selectedMapStyle = MapStyle.standard;
  bool _hasOfflineMaps = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _offlineMapRepository = sl<OfflineMapRepository>();
    _offlineMapRepository.availability.addListener(_onOfflineAvailabilityChanged);
    _tourController = TourSessionController(availableStops: const []);
    _bindTourUpdates();
    LocationPreferenceStore.gpsEnabled.addListener(_onGpsPreferenceChanged);

    _initLocationLogic();
    _loadPois();
    _loadOfflineAvailability(forceRefresh: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _serviceStatusSub?.cancel();
    _tourUpdatesSub?.cancel();
    LocationPreferenceStore.gpsEnabled.removeListener(_onGpsPreferenceChanged);
    _tourController.dispose();
    _offlineMapRepository.availability.removeListener(_onOfflineAvailabilityChanged);
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _verifyLocationState(requestPerms: false);
      _loadOfflineAvailability();
    }
  }

  @override
  Widget build(BuildContext context) => _buildPage();
}

class _MapBuildData {
  const _MapBuildData({
    required this.theme,
    required this.standardMapUrl,
    required this.localTileProvider,
    required this.currentStop,
    required this.isTourActive,
    required this.canUseLocation,
    required this.isLocationBannerVisible,
    required this.currentStopVisual,
  });

  final ThemeData theme;
  final String standardMapUrl;
  final LocalFileTileProvider localTileProvider;
  final TourStop? currentStop;
  final bool isTourActive;
  final bool canUseLocation;
  final bool isLocationBannerVisible;
  final TourStopVisualData? currentStopVisual;
}
