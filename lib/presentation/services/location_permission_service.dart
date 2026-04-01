import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

enum LocationAccessStatus { granted, serviceDisabled, denied, deniedForever, error }

class LocationPermissionService {
  const LocationPermissionService();

  Future<LocationAccessStatus> ensureLocationAccess() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationAccessStatus.serviceDisabled;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationAccessStatus.denied;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationAccessStatus.deniedForever;
      }

      return LocationAccessStatus.granted;
    } catch (_) {
      if (!kIsWeb) {
        return LocationAccessStatus.error;
      }
      return LocationAccessStatus.denied;
    }
  }
}
