import '../entities/userprofile.dart';
import '../repositories/user_repository.dart';

class UserUseCases {
  final IUserRepository repository;

  const UserUseCases(this.repository);

  // 1. Ottieni il profilo
  Future<UserProfile> getUserProfile(String uid) async {
    return await repository.getUserProfile(uid);
  }

  // 2. Aggiorna le preferenze
  Future<void> updatePreferences({
    required String uid,
    bool? notifiche,
    bool? darkMode,
    bool? gps,
  }) async {
    return await repository.updatePreferences(
      uid: uid,
      notifiche: notifiche,
      darkMode: darkMode,
      gps: gps,
    );
  }

  // 3. Registra il completamento del quiz e aggiorna statistiche
  Future<void> registerQuizCompletion({
    required String uid,
    required String poiId,
    required int xpGained,
    required int correctAnswers,
    required int totalQuestions,
    required int tourElapsedSeconds,
  }) async {
    return await repository.registerQuizCompletion(
      uid: uid,
      poiId: poiId,
      xpGained: xpGained,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      tourElapsedSeconds: tourElapsedSeconds,
    );
  }
  
}
