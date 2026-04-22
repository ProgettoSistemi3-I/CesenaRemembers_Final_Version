part of 'map_page.dart';

extension _MapPageView on _MapPageState {
  Widget _buildPage() {
    final data = _buildData;
    final offlineTemplate = _offlineMapUseCases.offlineMapTemplate;
    final currentMapUrl = switch (_selectedMapStyle) {
      MapStyle.satellite => _MapPageState._urlSatellite,
      MapStyle.offline => offlineTemplate,
      MapStyle.standard => data.standardMapUrl,
    };

    if (_isLoading) {
      return Scaffold(
        backgroundColor: data.theme.scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: AppPalette.olive),
        ),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        backgroundColor: data.theme.scaffoldBackgroundColor,
        body: _buildErrorState(data.theme),
      );
    }

    return Scaffold(
      backgroundColor: data.theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          _MapCanvas(
            mapController: _mapController,
            cesenaBounds: _MapPageState._cesenaBounds,
            isMapLocked: _isMapLocked,
            currentRotation: _currentRotation,
            onRotationChanged: (rotation) =>
                setState(() => _currentRotation = rotation),
            isMapMenuOpen: _isMapMenuOpen,
            onCloseMapMenu: () => setState(() => _isMapMenuOpen = false),
            alignPositionOnUpdate: _alignPositionOnUpdate,
            onDisableFollowUser: () =>
                setState(() => _alignPositionOnUpdate = AlignOnUpdate.never),
            canUseLocation: data.canUseLocation,
            currentMapUrl: currentMapUrl,
            selectedMapStyle: _selectedMapStyle,
            localTileProvider: data.localTileProvider,
            markers: _buildMarkers(),
            scaffoldBackgroundColor: data.theme.scaffoldBackgroundColor,
          ),
          _buildOverlay(data),
        ],
      ),
    );
  }

  Widget _buildOverlay(_MapBuildData data) {
    const cardHeight = 82.0;
    const cardPadding = 12.0;
    const cardBottom = cardHeight + cardPadding * 2;

    return SafeArea(
      child: Stack(
        children: [
          if (data.isLocationBannerVisible)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: LocationIssueBanner(
                isGpsEnabled: _isGpsEnabled,
                isGpsPreferenceEnabled: _isGpsPreferenceEnabled,
                onResolve: _resolveLocationIssues,
              ),
            ),
          if (_currentRotation != 0 && !data.isLocationBannerVisible)
            Positioned(
              top: 16,
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
            bottom: data.isTourActive ? cardBottom : 20,
            child: MapTypeButton(
              isOpen: _isMapMenuOpen,
              selectedMapStyle: _selectedMapStyle,
              offlineEnabled: _hasOfflineMaps,
              onToggle: () => setState(() => _isMapMenuOpen = !_isMapMenuOpen),
              onSelectStandard: () => setState(() {
                _selectedMapStyle = MapStyle.standard;
                _isMapMenuOpen = false;
              }),
              onSelectSatellite: () => setState(() {
                _selectedMapStyle = MapStyle.satellite;
                _isMapMenuOpen = false;
              }),
              onSelectOffline: () => setState(() {
                _selectedMapStyle = MapStyle.offline;
                _isMapMenuOpen = false;
              }),
            ),
          ),
          Positioned(
            right: 20,
            bottom: data.isTourActive ? cardBottom + 66 : 90,
            child: CircleFab(
              heroTag: 'lock',
              icon: _isMapLocked ? Icons.lock : Icons.lock_open,
              iconColor: _isMapLocked
                  ? AppPalette.danger
                  : data.theme.colorScheme.onSurfaceVariant,
              onTap: () => setState(() => _isMapLocked = !_isMapLocked),
            ),
          ),
          Positioned(
            right: 20,
            bottom: data.isTourActive ? cardBottom + 8 : 20,
            child: CircleFab(
              heroTag: 'loc',
              icon: Icons.my_location,
              iconColor: _isCenteringOnUser
                  ? AppPalette.olive
                  : _alignPositionOnUpdate == AlignOnUpdate.always
                  ? AppPalette.olive
                  : data.theme.colorScheme.onSurfaceVariant,
              onTap: _centerOnUserLocation,
            ),
          ),
          if (!data.isTourActive)
            Positioned(
              bottom: 28,
              left: 0,
              right: 0,
              child: Center(child: StartTourButton(onTap: _startTour)),
            ),
          if (data.isTourActive && _tourController.status == TourStatus.running)
            Positioned(
              right: 20,
              bottom: cardBottom + 180,
              child: ManualArrivalButton(
                onTap: _tourController.markArrivedManually,
              ),
            ),
          if (data.isTourActive)
            Positioned(
              left: 16,
              top: data.isLocationBannerVisible ? 112 : 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TourQuickActionButton(
                    label: 'Interrompi tour',
                    icon: Icons.stop_circle_outlined,
                    color: AppPalette.danger,
                    onTap: _confirmStopTour,
                  ),
                  const SizedBox(height: 10),
                  TourQuickActionButton(
                    label: 'Ordina tappe',
                    icon: Icons.format_list_bulleted_rounded,
                    color: AppPalette.olive,
                    onTap: _openTourPlanSheet,
                  ),
                ],
              ),
            ),
          if (data.isTourActive && data.currentStop != null)
            Positioned(
              bottom: cardPadding,
              left: 16,
              right: 16,
              child: NextStopCard(
                stop: data.currentStop!,
                icon: data.currentStopVisual!.icon,
                iconBackground: data.currentStopVisual!.iconBackground,
                stopIndex: _tourController.currentStopIndex,
                totalStops: _tourController.orderedStops.length,
                distanceMeters: _tourController.distanceToCurrentStop,
                elapsedSeconds: _tourController.elapsedSeconds,
                arrived: _tourController.isArrived,
                onTap: _tourController.isArrived
                    ? _openPoiPopup
                    : () => _centerOnStop(data.currentStop!.position),
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

class _MapCanvas extends StatelessWidget {
  const _MapCanvas({
    required this.mapController,
    required this.cesenaBounds,
    required this.isMapLocked,
    required this.currentRotation,
    required this.onRotationChanged,
    required this.isMapMenuOpen,
    required this.onCloseMapMenu,
    required this.alignPositionOnUpdate,
    required this.onDisableFollowUser,
    required this.canUseLocation,
    required this.currentMapUrl,
    required this.selectedMapStyle,
    required this.localTileProvider,
    required this.markers,
    required this.scaffoldBackgroundColor,
  });

  final MapController mapController;
  final LatLngBounds cesenaBounds;
  final bool isMapLocked;
  final double currentRotation;
  final ValueChanged<double> onRotationChanged;
  final bool isMapMenuOpen;
  final VoidCallback onCloseMapMenu;
  final AlignOnUpdate alignPositionOnUpdate;
  final VoidCallback onDisableFollowUser;
  final bool canUseLocation;
  final String currentMapUrl;
  final MapStyle selectedMapStyle;
  final LocalFileTileProvider localTileProvider;
  final List<Marker> markers;
  final Color scaffoldBackgroundColor;

  @override
  Widget build(BuildContext context) {
    const defaultCesenaCenter = LatLng(44.1384, 12.2471);
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
    );

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: defaultCesenaCenter,
        initialZoom: 14.0,
        minZoom: 10.0,
        maxZoom: 18.5,
        cameraConstraint: CameraConstraint.contain(bounds: cesenaBounds),
        backgroundColor: scaffoldBackgroundColor,
        interactionOptions: InteractionOptions(
          flags: isMapLocked ? InteractiveFlag.none : InteractiveFlag.all,
        ),
        onMapEvent: (event) {
          if (event is MapEventMove || event is MapEventRotate) {
            final rotation = mapController.camera.rotation;
            if ((rotation - currentRotation).abs() > 0.1) {
              onRotationChanged(rotation);
            }
          }
          if (event is MapEventMoveStart && isMapMenuOpen) {
            onCloseMapMenu();
          }
        },
        onPositionChanged: (_, hasGesture) {
          if (hasGesture && alignPositionOnUpdate != AlignOnUpdate.never) {
            onDisableFollowUser();
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: currentMapUrl,
          subdomains: selectedMapStyle == MapStyle.offline
              ? const []
              : const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.geoapp.prototype',
          maxZoom: 19,
          tileBounds: cesenaBounds,
          tileProvider: selectedMapStyle == MapStyle.offline
              ? localTileProvider
              : null,
        ),
        if (canUseLocation)
          CurrentLocationLayer(
            alignPositionOnUpdate: alignPositionOnUpdate,
            style: LocationMarkerStyle(
              marker: const DefaultLocationMarker(
                color: Colors.blue,
                child: Icon(Icons.navigation, color: Colors.white, size: 14),
              ),
              accuracyCircleColor: Colors.blue.withValues(alpha: 0.1),
              headingSectorColor: Colors.blue.withValues(alpha: 0.2),
            ),
            positionStream: const LocationMarkerDataStreamFactory()
                .fromGeolocatorPositionStream(
                  stream: Geolocator.getPositionStream(
                    locationSettings: locationSettings,
                  ),
                ),
          ),
        MarkerLayer(markers: markers),
      ],
    );
  }
}
