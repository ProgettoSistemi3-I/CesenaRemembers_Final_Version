import '../entities/userprofile.dart';

abstract class IUserRepository {
  // Recupera il profilo utente (singola chiamata).
  Future<UserProfile> getUserProfile(String uid);

  // NUOVO: Stream in tempo reale del profilo utente (Clean Architecture)
  Stream<UserProfile?> getUserProfileStream(String uid);

  // NUOVO: Ottiene l'UID corrente senza esporre FirebaseAuth alla UI
  String? getCurrentUserUid();

  // Assicura che il documento utente esista e sincronizza i dati auth base.
  Future<void> ensureUserDocument({required String uid, required String email});

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

  // Ricerca utenti globale
  Future<List<UserProfile>> searchUsers(String query);

  // Stream della classifica globale
  Stream<List<Map<String, dynamic>>> getLeaderboardStream({int limit = 50});

  //social
  Future<void> sendFriendRequest(String currentUid, String targetUid);
  Future<void> cancelFriendRequest(String currentUid, String targetUid);
  Future<void> acceptFriendRequest(String currentUid, String requesterUid);
  Future<void> rejectFriendRequest(String currentUid, String requesterUid);
  Future<void> removeFriend(String currentUid, String friendUid);
  Future<List<UserProfile>> getUsersByIds(List<String> uids);
}
