import 'package:flutter/material.dart';
import '../../domain/usecases/user_use_cases.dart';

class ThemeController extends ChangeNotifier {
  final UserUseCases _userUseCases;
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  ThemeController({required UserUseCases userUseCases})
    : _userUseCases = userUseCases;

  Future<void> initTheme() async {
    await _loadThemeFromFirebase();
  }

  Future<void> _loadThemeFromFirebase() async {
    final uid = _userUseCases.getCurrentUserUid();
    if (uid == null) {
      _themeMode = ThemeMode.light;
      return;
    }
    try {
      final profile = await _userUseCases.getUserProfile(uid);
      _themeMode = profile.darkModeEnabled ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      debugPrint("Errore caricamento tema: $e");
      _themeMode = ThemeMode.light;
    }
  }

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
