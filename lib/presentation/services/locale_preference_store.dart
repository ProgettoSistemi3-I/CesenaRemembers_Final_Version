import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalePreferenceStore {
  const LocalePreferenceStore._();

  static const _localeCodeKey = 'app_locale_code';

  static Future<Locale> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeCodeKey);
    if (code == 'en' || code == 'it') {
      return Locale(code!);
    }
    return const Locale('it');
  }

  static Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeCodeKey, locale.languageCode);
  }
}
