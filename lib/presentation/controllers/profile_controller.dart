import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/userprofile.dart';
import '../../domain/usecases/user_profile_use_cases.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({required UserProfileUseCases profileUseCases})
    : _profileUseCases = profileUseCases {
    _startProfileListener();
  }

  final UserProfileUseCases _profileUseCases;
  StreamSubscription<UserProfile?>? _profileSub;
  bool _isDisposed = false;

  UserProfile? profile;
  bool isLoading = true;
  String? errorMessage;

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void _startProfileListener() {
    // Otteniamo l'UID tramite lo Use Case
    final uid = _profileUseCases.getCurrentUserUid();

    if (uid == null) {
      isLoading = false;
      errorMessage = 'Utente non autenticato. User not authenticated.';
      _safeNotifyListeners();
      return;
    }

    _profileSub?.cancel();

    // Ascoltiamo lo stream dal Domain Layer
    _profileSub = _profileUseCases
        .getUserProfileStream(uid)
        .listen(
          (userProfile) async {
            if (userProfile != null) {
              profile = userProfile;
              isLoading = false;
              errorMessage = null;
              _safeNotifyListeners();
            } else {
              // Fallback
              await _loadProfileFromUseCase(uid);
            }
          },
          onError: (error) {
            isLoading = false;
            errorMessage = 'Impossibile sincronizzare il profilo. Unable to sync profile.';
            _safeNotifyListeners();
          },
        );
  }

  Future<void> _loadProfileFromUseCase(String uid) async {
    try {
      profile = await _profileUseCases.getUserProfile(uid);
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Impossibile caricare il profilo. Unable to load profile.';
    } finally {
      isLoading = false;
      _safeNotifyListeners();
    }
  }

  /// Imposta un messaggio di errore e notifica i listener.
  /// Evita l'accesso diretto a [errorMessage] e [notifyListeners] dall'esterno.
  void setError(String message) {
    errorMessage = message;
    _safeNotifyListeners();
  }

  Future<void> updateProfileBasics({
    String? displayName,
    String? avatarId,
  }) async {    final uid = _profileUseCases.getCurrentUserUid();
    if (uid == null) return;

    try {
      await _profileUseCases.updateProfileBasics(
        uid: uid,
        displayName: displayName,
        avatarId: avatarId,
      );
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Salvataggio profilo non riuscito. Profile save failed.';
      _safeNotifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _profileSub?.cancel();
    super.dispose();
  }
}
