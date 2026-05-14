import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/locale_preference_store.dart';

class SettingsUiController extends ChangeNotifier {
  SettingsUiController(this._localeNotifier)
    : selectedLanguage = _localeNotifier.value.languageCode == 'en'
          ? 'English'
          : 'Italiano';

  final ValueNotifier<Locale> _localeNotifier;
  String selectedLanguage;

  Future<void> setLanguage(String value) async {
    if (selectedLanguage == value) return;
    selectedLanguage = value;
    final locale = Locale(value == 'English' ? 'en' : 'it');
    _localeNotifier.value = locale;
    await LocalePreferenceStore.saveLocale(locale);
    notifyListeners();
  }
}
