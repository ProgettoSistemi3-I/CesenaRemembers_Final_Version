import '../entities/userprofile.dart';
import '../repositories/user_repository.dart';

class UserUseCases {
  final IUserRepository repository;

  const UserUseCases(this.repository);

  // 1. Ottieni il profilo
  Future<UserProfile> getUserProfile(String uid) async {
    return await repository.getUserProfile(uid);
  }

  Future<void> ensureUserDocument({
    required String uid,
    required String email,
    String? authDisplayName,
  }) async {
    return repository.ensureUserDocument(
      uid: uid,
      email: email,
      authDisplayName: authDisplayName,
    );
  }

  Future<void> completeInitialProfile({
    required String uid,
    required String email,
    required String username,
    required String displayName,
    required String avatarId,
  }) async {
    return repository.completeInitialProfile(
      uid: uid,
      email: email,
      username: username,
      displayName: displayName,
      avatarId: avatarId,
    );
  }

  Future<void> updateProfileBasics({
    required String uid,
    String? displayName,
    String? avatarId,
  }) async {
    return repository.updateProfileBasics(
      uid: uid,
      displayName: displayName,
      avatarId: avatarId,
    );
  }

  Future<bool> isUsernameAvailable(String username) async {
    return repository.isUsernameAvailable(username);
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

  Future<void> deleteUserData({required String uid}) async {
    return repository.deleteUserData(uid: uid);
  }
}
