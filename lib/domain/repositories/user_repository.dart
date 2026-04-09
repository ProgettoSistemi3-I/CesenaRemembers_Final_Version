import '../entities/userprofile.dart';

abstract class IUserRepository {
  // Recupera il profilo utente.
  Future<UserProfile> getUserProfile(String uid);

  // Assicura che il documento utente esista e sincronizza i dati auth base.
  Future<void> ensureUserDocument({
    required String uid,
    required String email,
    String? authDisplayName,
  });

  // Crea il profilo iniziale con username univoco.
  Future<void> completeInitialProfile({
    required String uid,
    required String email,
    required String username,
    required String displayName,
    required String avatarId,
  });

  // Aggiorna nome/avatar (username immutabile).
  Future<void> updateProfileBasics({
    required String uid,
    String? displayName,
    String? avatarId,
  });

  // Verifica disponibilità username.
  Future<bool> isUsernameAvailable(String username);
  
  // Aggiorna le preferenze dalla pagina Settings
  Future<void> updatePreferences({
    required String uid,
    bool? notifiche,
    bool? darkMode,
    bool? gps,
  });

  // Registra il completamento del quiz per una tappa e aggiorna le statistiche.
  Future<void> registerQuizCompletion({
    required String uid,
    required String poiId,
    required int xpGained,
    required int correctAnswers,
    required int totalQuestions,
    required int tourElapsedSeconds,
  });

  // Elimina tutti i dati utente persistiti (profilo e indice username).
  Future<void> deleteUserData({required String uid});
}
