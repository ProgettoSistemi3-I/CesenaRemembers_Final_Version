import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SettingsUiController extends ChangeNotifier {
  SettingsUiController(this._localeNotifier)
    : selectedLanguage = _localeNotifier.value.languageCode == 'en'
          ? 'English'
          : 'Italiano';

  final ValueNotifier<Locale> _localeNotifier;
  String selectedLanguage;

  void setLanguage(String value) {
    if (selectedLanguage == value) return;
    selectedLanguage = value;
    _localeNotifier.value = Locale(value == 'English' ? 'en' : 'it');
    notifyListeners();
  }
}
