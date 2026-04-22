import 'package:flutter/foundation.dart';

import '../../domain/usecases/auth_use_cases.dart';
import '../../domain/usecases/user_preferences_use_cases.dart';
import '../../domain/usecases/user_profile_use_cases.dart';
import '../theme/theme_controller.dart';
import '../services/location_permission_service.dart';
import '../services/location_preference_store.dart';

class SettingsController extends ChangeNotifier {
  bool _isDisposed = false;
  final SignOutUseCase _signOutUseCase;
  final DeleteCurrentUserUseCase _deleteCurrentUserUseCase;
  final UserProfileUseCases _profileUseCases;
  final UserPreferencesUseCases _preferencesUseCases;
  final ThemeController _themeController;
  final LocationPermissionService _locationService;

  // --- STATO DELLE PREFERENZE (Salvate su Firebase e Locali) ---
  bool notifiche = true;
  bool modalitaNotte = false;
  bool posizione = true;

  // --- STATO DELLA UI ---
  bool isLoading = true;
  bool isLoggingOut = false;
  bool isDeletingAccount = false;
  String? errorMessage;

  SettingsController({
    required SignOutUseCase signOutUseCase,
    required DeleteCurrentUserUseCase deleteCurrentUserUseCase,
    required UserProfileUseCases profileUseCases,
    required UserPreferencesUseCases preferencesUseCases,
    required ThemeController themeController,
  }) : _signOutUseCase = signOutUseCase,
       _deleteCurrentUserUseCase = deleteCurrentUserUseCase,
       _profileUseCases = profileUseCases,
       _preferencesUseCases = preferencesUseCases,
       _themeController = themeController,
       _locationService = const LocationPermissionService() {
    loadUserPreferences();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// Chiama notifyListeners() solo se il controller non è stato disposto.
  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  String get _currentUid {
    final uid = _profileUseCases.getCurrentUserUid();
    if (uid == null) throw Exception("Errore critico: utente non loggato.");
    return uid;
  }

  Future<void> loadUserPreferences() async {
    try {
      final profile = await _profileUseCases.getUserProfile(_currentUid);

      notifiche = profile.notificheEnabled;
      modalitaNotte = profile.darkModeEnabled;

      final hasRealPermission = await _locationService.hasActivePermission();
      posizione = profile.gpsEnabled && hasRealPermission;
      LocationPreferenceStore.setGpsEnabled(posizione);

      errorMessage = null;

      _themeController.toggleTheme(modalitaNotte);
    } catch (e) {
      errorMessage = 'Errore nel caricamento preferenze: $e';
    } finally {
      isLoading = false;
      _safeNotifyListeners();
    }
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
          LocationPreferenceStore.setGpsEnabled(false);
          _safeNotifyListeners();
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
    _safeNotifyListeners();

    try {
      // 2. Salvataggio su Firestore
      await _preferencesUseCases.updatePreferences(
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
    _safeNotifyListeners();

    try {
      await _signOutUseCase();
      return true;
    } catch (e) {
      errorMessage = 'Logout fallito: $e';
      isLoggingOut = false;
      _safeNotifyListeners();
      return false;
    }
  }

  Future<bool> handleDeleteAccount() async {
    isDeletingAccount = true;
    errorMessage = null;
    _safeNotifyListeners();

    final uid = _currentUid;

    // ── Step 1: cancella i dati applicativi su Firestore ──
    try {
      await _profileUseCases.deleteUserData(uid: uid);
    } catch (e) {
      // Firestore non ha eliminato nulla → lo stato è intatto, mostriamo errore.
      debugPrint('[DELETE‑ACCOUNT] Errore cancellazione Firestore: $e');
      errorMessage = 'Impossibile eliminare i dati: $e';
      isDeletingAccount = false;
      _safeNotifyListeners();
      return false;
    }

    // ── Step 2: elimina l'utente Firebase Auth ──
    try {
      await _deleteCurrentUserUseCase();
      // Successo: authStateChanges emetterà null → LoginPage
      return true;
    } catch (e) {
      // Auth non eliminato ma i dati Firestore sono già stati rimossi.
      // Forziamo il logout per evitare stati inconsistenti.
      debugPrint('[DELETE‑ACCOUNT] Errore cancellazione auth: $e');
      try {
        await _signOutUseCase();
      } catch (_) {}
      isDeletingAccount = false;
      _safeNotifyListeners();
      return false;
    }
  }

  void clearError() {
    errorMessage = null;
  }
}
