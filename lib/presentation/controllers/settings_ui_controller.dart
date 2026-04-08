import 'package:flutter/foundation.dart';

class SettingsUiController extends ChangeNotifier {
  String selectedLanguage = 'Italiano';
  String notificationType = 'Solo eventi e progressi';
  String consents = 'Minimi necessari';
  bool offlineDownloadsEnabled = true;

  void setLanguage(String value) {
    if (selectedLanguage == value) return;
    selectedLanguage = value;
    notifyListeners();
  }

  void setNotificationType(String value) {
    if (notificationType == value) return;
    notificationType = value;
    notifyListeners();
  }

  void setConsents(String value) {
    if (consents == value) return;
    consents = value;
    notifyListeners();
  }

  void setOfflineDownloadsEnabled(bool value) {
    if (offlineDownloadsEnabled == value) return;
    offlineDownloadsEnabled = value;
    notifyListeners();
  }
}
