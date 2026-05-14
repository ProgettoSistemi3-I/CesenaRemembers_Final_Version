import 'package:flutter/material.dart';
import '../../domain/usecases/user_profile_use_cases.dart';
import '../../core/logging/app_logger.dart';

class ThemeController extends ChangeNotifier {
  final UserProfileUseCases _profileUseCases;
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  ThemeController({required UserProfileUseCases profileUseCases})
    : _profileUseCases = profileUseCases;

  Future<void> initTheme() async {
    await _loadThemeFromFirebase();
  }

  Future<void> refreshFromProfile() async {
    await _loadThemeFromFirebase();
    notifyListeners();
  }

  Future<void> _loadThemeFromFirebase() async {
    final uid = _profileUseCases.getCurrentUserUid();
    if (uid == null) {
      _themeMode = ThemeMode.light;
      return;
    }
    try {
      final profile = await _profileUseCases.getUserProfile(uid);
      _themeMode = profile.darkModeEnabled ? ThemeMode.dark : ThemeMode.light;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Errore caricamento tema da profilo. Error loading theme from profile',
        error: e,
        stackTrace: stackTrace,
        name: 'ThemeController',
      );
      _themeMode = ThemeMode.light;
    }
  }

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
