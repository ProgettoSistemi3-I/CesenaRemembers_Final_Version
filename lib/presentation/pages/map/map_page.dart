import 'dart:async';
import 'dart:math' as math;

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cesena_remembers/l10n/app_localizations.dart';
import 'package:cesena_remembers/l10n/l10n_extensions.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http_cache_file_store/http_cache_file_store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:latlong2/latlong.dart';

import '../../../domain/entities/poi.dart';
import '../../../config/app_runtime_config.dart';
import '../../../domain/entities/tour_stop.dart';
import '../../../domain/services/tour_scoring_service.dart';
import '../../../domain/usecases/poi_use_cases.dart';
import '../../../domain/usecases/user_profile_use_cases.dart';
import '../../../domain/usecases/user_progress_use_cases.dart';
import '../../../injection_container.dart';
import '../../controllers/tour_session_controller.dart';
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
  final UserProfileUseCases _profileUseCases = sl<UserProfileUseCases>();
  final UserProgressUseCases _progressUseCases = sl<UserProgressUseCases>();

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
  CacheStore? _tileCacheStore;

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
  Locale? _lastLocale;
  late VoidCallback _onLocaleChanged;

  List<Poi> _pois = [];
  List<Marker> _markers = const [];
  bool _isLoading = true;
  String? _loadError;

  static const _urlStandard =
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';
  static final _urlStandardDark =
      'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png'
      '?api_key=${AppRuntimeConfig.stadiaMapsApiKey}';
  static const _urlSatellite =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

  _MapBuildData get _buildData => _MapBuildData(
    theme: Theme.of(context),
    standardMapUrl:
        Theme.of(context).brightness == Brightness.dark &&
            AppRuntimeConfig.stadiaMapsApiKey.trim().isNotEmpty
        ? _urlStandardDark
        : _urlStandard,
    currentStop: _tourController.currentStop,
    isTourActive: _tourController.isActive,
    canUseLocation: _isGpsEnabled && _hasPermissions && _isGpsPreferenceEnabled,
    isLocationBannerVisible:
        !_isCheckingLocation &&
        !(_isGpsEnabled && _hasPermissions && _isGpsPreferenceEnabled),
    currentStopVisual: _tourController.currentStop == null
        ? null
        : _tourStopVisuals.forStop(_tourController.currentStop!),
  );

  MapStyle _selectedMapStyle = MapStyle.standard;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initTileCaching();
    _tourController = TourSessionController(availableStops: const []);
    _bindTourUpdates();
    LocationPreferenceStore.gpsEnabled.addListener(_onGpsPreferenceChanged);

    final localeNotifier = sl<ValueNotifier<Locale>>();
    _onLocaleChanged = () {
      if (_pois.isNotEmpty && mounted) {
        setState(() {
          _markers = _buildMarkers(_pois);
        });
      }
    };
    localeNotifier.addListener(_onLocaleChanged);

    _initLocationLogic();
    _loadPois();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _serviceStatusSub?.cancel();
    _tourUpdatesSub?.cancel();
    LocationPreferenceStore.gpsEnabled.removeListener(_onGpsPreferenceChanged);
    sl<ValueNotifier<Locale>>().removeListener(_onLocaleChanged);
    _tourController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_lastLocale == locale) return;
    _lastLocale = locale;

    if (_pois.isNotEmpty) {
      setState(() {
        _markers = _buildMarkers(_pois);
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _verifyLocationState(requestPerms: false);
    }
  }

  Future<void> _initTileCaching() async {
    final cacheDir = await getTemporaryDirectory();
    final cachePath = '${cacheDir.path}/map_tiles_cache';
    final cacheStore = FileCacheStore(cachePath);
    if (!mounted) return;
    setState(() => _tileCacheStore = cacheStore);
  }

  CachedTileProvider? get _cachedTileProvider {
    final store = _tileCacheStore;
    if (store == null) return null;
    return CachedTileProvider(
      store: store,
      maxStale: const Duration(days: 120),
      hitCacheOnNetworkFailure: true,
    );
  }

  @override
  Widget build(BuildContext context) => _buildPage();
}

class _MapBuildData {
  const _MapBuildData({
    required this.theme,
    required this.standardMapUrl,
    required this.currentStop,
    required this.isTourActive,
    required this.canUseLocation,
    required this.isLocationBannerVisible,
    required this.currentStopVisual,
  });

  final ThemeData theme;
  final String standardMapUrl;
  final TourStop? currentStop;
  final bool isTourActive;
  final bool canUseLocation;
  final bool isLocationBannerVisible;
  final TourStopVisualData? currentStopVisual;
}
