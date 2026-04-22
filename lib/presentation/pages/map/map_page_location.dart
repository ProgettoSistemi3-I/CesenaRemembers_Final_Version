part of 'map_page.dart';

extension _MapPageLocationLogic on _MapPageState {
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
    final shouldRequestPermission =
        !_MapPageState._hasRequestedInitialLocationPermission;
    _MapPageState._hasRequestedInitialLocationPermission = true;
    await _verifyLocationState(requestPerms: shouldRequestPermission);
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
          perm == LocationPermission.whileInUse || perm == LocationPermission.always;
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

    final gps = await Geolocator.isLocationServiceEnabled();
    var perm = await Geolocator.checkPermission();

    if (perm == LocationPermission.denied && requestPerms) {
      perm = await Geolocator.requestPermission();
    }

    final hasPerm =
        perm == LocationPermission.whileInUse || perm == LocationPermission.always;

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
}
