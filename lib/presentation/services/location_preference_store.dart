import 'package:flutter/foundation.dart';

class LocationPreferenceStore {
  LocationPreferenceStore._();

  static final ValueNotifier<bool> gpsEnabled = ValueNotifier<bool>(true);

  static void setGpsEnabled(bool value) {
    if (gpsEnabled.value != value) {
      gpsEnabled.value = value;
    }
  }
}
