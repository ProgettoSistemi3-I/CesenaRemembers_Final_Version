import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/usecases/auth_use_cases.dart';
import '../../domain/usecases/user_use_cases.dart';
import '../theme/theme_controller.dart';
import '../services/location_permission_service.dart'; // IMPORTANTE: Aggiunto per il GPS
import '../services/location_preference_store.dart';

class SettingsController extends ChangeNotifier {
  final SignOutUseCase _signOutUseCase;
  final UserUseCases _userUseCases;
  final ThemeController _themeController;
  final LocationPermissionService _locationService; // AGGIUNTO

  // --- STATO DELLE PREFERENZE (Salvate su Firebase e Locali) ---
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
    required ThemeController themeController,
  }) : _signOutUseCase = signOutUseCase,
       _userUseCases = userUseCases,
       _themeController = themeController,
       _locationService = const LocationPermissionService() {
    // Inizializzato
    loadUserPreferences();
  }

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

      // Controllo INCROCIATO per il GPS:
      // Verifichiamo se il permesso è DAVVERO attivo sul telefono
      final hasRealPermission = await _checkRealGpsPermission();
      posizione = profile.gpsEnabled && hasRealPermission;
      LocationPreferenceStore.setGpsEnabled(posizione);

      errorMessage = null;

      _themeController.toggleTheme(modalitaNotte);
    } catch (e) {
      errorMessage = 'Errore nel caricamento preferenze: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Nuova funzione per verificare il permesso reale
  Future<bool> _checkRealGpsPermission() async {
    if (kIsWeb) return false;
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> updatePreference({
    bool? newNotifiche,
    bool? newModalitaNotte,
    bool? newPosizione,
  }) async {
    // --- GESTIONE SPECIALE PER IL GPS ---
    if (newPosizione != null) {
      if (newPosizione == true) {
        // Se l'utente vuole ATTIVARE il GPS, chiediamo il permesso al sistema
        final status = await _locationService.ensureLocationAccess();
        if (status != LocationAccessStatus.granted) {
          // Se rifiuta, blocchiamo lo switch su FALSE
          errorMessage =
              'Permesso negato o GPS disattivato. Controlla le impostazioni del telefono.';
          posizione = false;
          notifyListeners();
          return; // Interrompiamo qui, non salviamo su DB
        }
      } else {
        // Se l'utente SPEGNE il GPS dall'app, non possiamo spegnerlo dal telefono (è vietato da Android/iOS),
        // ma possiamo smettere di usarlo nell'app e salvarlo su DB.
      }
    }

    // 1. Aggiornamento Immediato
    if (newNotifiche != null) notifiche = newNotifiche;
    if (newModalitaNotte != null) {
      modalitaNotte = newModalitaNotte;
      _themeController.toggleTheme(newModalitaNotte);
    }
    if (newPosizione != null) posizione = newPosizione;
    if (newPosizione != null) {
      LocationPreferenceStore.setGpsEnabled(newPosizione);
    }
    notifyListeners();

    try {
      // 2. Salvataggio su Firestore
      await _userUseCases.updatePreferences(
        uid: _currentUid,
        notifiche: newNotifiche,
        darkMode: newModalitaNotte,
        gps: newPosizione, // Verrà salvato solo se il permesso è stato concesso
      );
    } catch (e) {
      // 3. Rollback
      errorMessage = 'Errore di connessione. Modifica annullata.';
      await loadUserPreferences();
      _themeController.toggleTheme(modalitaNotte);
      LocationPreferenceStore.setGpsEnabled(posizione);
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
