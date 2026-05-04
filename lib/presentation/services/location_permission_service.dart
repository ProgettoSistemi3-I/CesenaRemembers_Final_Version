import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

enum LocationAccessStatus { granted, serviceDisabled, denied, deniedForever, error }

class LocationPermissionService {
  const LocationPermissionService();

  Future<bool> hasActivePermission() async {
    try {
      if (!kIsWeb) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) return false;
      }

      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (_) {
      return false;
    }
  }

  /// Controlla solo se il permesso è stato concesso dall'utente,
  /// indipendentemente dallo stato del servizio GPS hardware.
  /// Usato per il toggle nelle impostazioni: se l'utente ha autorizzato
  /// l'app, il toggle deve risultare attivo anche se il GPS è spento.
  Future<bool> hasPermissionGranted() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (_) {
      return false;
    }
  }

  Future<LocationAccessStatus> ensureLocationAccess() async {
    try {
      if (kIsWeb) {
        var webPermission = await Geolocator.checkPermission();
        if (webPermission == LocationPermission.denied) {
          webPermission = await Geolocator.requestPermission();
        }
        if (webPermission == LocationPermission.deniedForever) {
          return LocationAccessStatus.deniedForever;
        }
        return (webPermission == LocationPermission.always ||
                webPermission == LocationPermission.whileInUse)
            ? LocationAccessStatus.granted
            : LocationAccessStatus.denied;
      }

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
      return LocationAccessStatus.error;
    }
  }
}
