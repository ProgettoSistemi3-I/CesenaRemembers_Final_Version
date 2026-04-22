import 'package:flutter/foundation.dart';

class SettingsUiController extends ChangeNotifier {
  String selectedLanguage = 'Italiano';

  void setLanguage(String value) {
    if (selectedLanguage == value) return;
    selectedLanguage = value;
    notifyListeners();
  }
}
