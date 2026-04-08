import '../entities/userprofile.dart';

abstract class IUserRepository {
  // Recupera il profilo. Se non esiste (primo login), dovrebbe crearlo.
  Future<UserProfile> getUserProfile(String uid);
  
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
}
