import 'package:flutter/foundation.dart';

import '../../domain/usecases/auth_use_cases.dart';
import '../../domain/usecases/user_preferences_use_cases.dart';
import '../../domain/usecases/user_profile_use_cases.dart';
import '../../core/logging/app_logger.dart';
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

  // Stato preferenze (persistite su Firebase + cache locale)
  bool notifiche = true;
  bool modalitaNotte = false;
  bool posizione = true;

  // Stato UI
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
      posizione = hasRealPermission;
      LocationPreferenceStore.setGpsEnabled(posizione);

      if (hasRealPermission && !profile.gpsEnabled) {
        await _preferencesUseCases.updatePreferences(uid: _currentUid, gps: true);
      }

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
    if (newPosizione == true) {
      final status = await _locationService.ensureLocationAccess();
      if (status != LocationAccessStatus.granted) {
        errorMessage =
            'Permesso negato o GPS disattivato. Controlla le impostazioni del telefono.';
        posizione = false;
        LocationPreferenceStore.setGpsEnabled(false);
        _safeNotifyListeners();
        return;
      }
    }

    // 1) Aggiornamento ottimistico
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
      // 2) Persistenza remota
      await _preferencesUseCases.updatePreferences(
        uid: _currentUid,
        notifiche: newNotifiche,
        darkMode: newModalitaNotte,
        gps: newPosizione,
      );
    } catch (e) {
      // 3) Rollback
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

    try {
      await _profileUseCases.deleteUserData(uid: uid);
    } catch (e) {
      AppLogger.error(
        'Delete account failed at Firestore cleanup',
        error: e,
        name: 'SettingsController',
      );
      errorMessage = 'Impossibile eliminare i dati: $e';
      isDeletingAccount = false;
      _safeNotifyListeners();
      return false;
    }

    try {
      await _deleteCurrentUserUseCase();
      return true;
    } catch (e) {
      AppLogger.error(
        'Delete account failed at Auth deletion after Firestore cleanup',
        error: e,
        name: 'SettingsController',
      );
      errorMessage =
          'Account non eliminato completamente. I dati app sono stati rimossi, ma la cancellazione auth è fallita. Verrai disconnesso per sicurezza.';
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
