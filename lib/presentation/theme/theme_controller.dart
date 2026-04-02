import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/usecases/user_use_cases.dart';
import '../../injection_container.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  ThemeController() {
    _loadThemeFromFirebase();
  }

  Future<void> _loadThemeFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final userUseCases = sl<UserUseCases>();
      final profile = await userUseCases.getUserProfile(user.uid);
      _themeMode = profile.darkModeEnabled ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    } catch (e) {
      debugPrint("Errore caricamento tema: $e");
    }
  }

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
