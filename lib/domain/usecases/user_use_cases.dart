import 'dart:async';
import '../entities/userprofile.dart';
import '../repositories/user_repository.dart';

class UserUseCases {
  final IUserRepository repository;

  const UserUseCases(this.repository);

  // Ottiene l'UID dell'utente loggato senza toccare Firebase
  String? getCurrentUserUid() {
    return repository.getCurrentUserUid();
  }

  // 1. Ottieni il profilo (singola volta)
  Future<UserProfile> getUserProfile(String uid) async {
    return await repository.getUserProfile(uid);
  }

  // Stream in tempo reale del profilo
  Stream<UserProfile?> getUserProfileStream(String uid) {
    return repository.getUserProfileStream(uid);
  }

  Future<void> ensureUserDocument({
    required String uid,
    required String email,
  }) async {
    return repository.ensureUserDocument(uid: uid, email: email);
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

  // 4. Ricerca utenti
  Future<List<UserProfile>> searchUsers(String query) async {
    return await repository.searchUsers(query);
  }

  // Stream classifica
  Stream<List<Map<String, dynamic>>> getLeaderboardStream({int limit = 50}) {
    return repository.getLeaderboardStream(limit: limit);
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

  //social
  Future<void> sendFriendRequest(String cUid, String tUid) =>
      repository.sendFriendRequest(cUid, tUid);
  Future<void> cancelFriendRequest(String cUid, String tUid) =>
      repository.cancelFriendRequest(cUid, tUid);
  Future<void> acceptFriendRequest(String cUid, String rUid) =>
      repository.acceptFriendRequest(cUid, rUid);
  Future<void> rejectFriendRequest(String cUid, String rUid) =>
      repository.rejectFriendRequest(cUid, rUid);
  Future<void> removeFriend(String cUid, String fUid) =>
      repository.removeFriend(cUid, fUid);
  Future<List<UserProfile>> getUsersByIds(List<String> uids) =>
      repository.getUsersByIds(uids);
}
