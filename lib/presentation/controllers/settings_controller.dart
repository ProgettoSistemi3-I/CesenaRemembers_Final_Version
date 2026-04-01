import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Deroga al DDD per via del merge

import '../../domain/usecases/auth_use_cases.dart';
import '../../domain/usecases/user_use_cases.dart';

class SettingsController extends ChangeNotifier {
  final SignOutUseCase _signOutUseCase;
  final UserUseCases _userUseCases;

  // --- STATO DELLE PREFERENZE (Salvate su Firebase) ---
  bool notifiche = true;
  bool modalitaNotte = false;
  bool posizione = true;

  // --- STATO DELLA UI ---
  bool isLoading = true;
  bool isLoggingOut = false;
  String? errorMessage;

  SettingsController({
    required SignOutUseCase signOutUseCase,
    required UserUseCases userUseCases,
  }) : _signOutUseCase = signOutUseCase,
       _userUseCases = userUseCases {
    loadUserPreferences();
  }

  // Usiamo direttamente FirebaseAuth per recuperare l'UID visto che manca l'UseCase
  String get _currentUid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Errore critico: utente non loggato.");
    return user.uid;
  }

  Future<void> loadUserPreferences() async {
    try {
      final profile = await _userUseCases.getUserProfile(_currentUid);

      notifiche = profile.notificheEnabled;
      modalitaNotte = profile.darkModeEnabled;
      posizione = profile.gpsEnabled;
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Errore nel caricamento preferenze: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePreference({
    bool? newNotifiche,
    bool? newModalitaNotte,
    bool? newPosizione,
  }) async {
    // 1. Aggiornamento Immediato sulla UI (Ottimistico)
    if (newNotifiche != null) notifiche = newNotifiche;
    if (newModalitaNotte != null) modalitaNotte = newModalitaNotte;
    if (newPosizione != null) posizione = newPosizione;
    notifyListeners();

    try {
      // 2. Salvataggio su Firestore
      await _userUseCases.updatePreferences(
        uid: _currentUid,
        notifiche: newNotifiche,
        darkMode: newModalitaNotte,
        gps: newPosizione,
      );
    } catch (e) {
      // 3. Rollback in caso di errore di connessione
      errorMessage = 'Errore di connessione. Modifica annullata.';
      await loadUserPreferences();
    }
  }

  Future<bool> handleLogout() async {
    isLoggingOut = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _signOutUseCase();
      return true;
    } catch (e) {
      errorMessage = 'Logout fallito: $e';
      isLoggingOut = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    errorMessage = null;
  }
}
