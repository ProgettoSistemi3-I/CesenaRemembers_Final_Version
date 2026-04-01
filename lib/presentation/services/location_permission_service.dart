import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationCheckResult {
  const LocationCheckResult({required this.granted, this.message});

  final bool granted;
  final String? message;
}

class LocationPermissionService {
  const LocationPermissionService();

  Future<LocationCheckResult> ensureLocationEnabledAndAuthorized() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!kIsWeb) {
        await Geolocator.openLocationSettings();
      }
      return const LocationCheckResult(
        granted: false,
        message: 'GPS disattivato. Attiva la posizione per continuare.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return const LocationCheckResult(
          granted: false,
          message: 'Permesso posizione negato.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return const LocationCheckResult(
        granted: false,
        message: 'Permesso posizione negato permanentemente.',
      );
    }

    return const LocationCheckResult(granted: true);
  }

  Future<Position?> getCurrentPositionSafely() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
        ),
        timeLimit: const Duration(seconds: 6),
      );
    } catch (_) {
      return null;
    }
  }
}
