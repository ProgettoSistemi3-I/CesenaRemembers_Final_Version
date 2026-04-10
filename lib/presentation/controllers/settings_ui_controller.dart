import 'package:flutter/foundation.dart';

class SettingsUiController extends ChangeNotifier {
  String selectedLanguage = 'Italiano';
  String notificationType = 'Solo eventi e progressi';

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
}
