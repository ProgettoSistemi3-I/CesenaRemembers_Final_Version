import '../entities/userprofile.dart';

abstract class IUserRepository {
  Future<UserProfile> getUserProfile(String uid);
  Stream<UserProfile?> getUserProfileStream(String uid);
  String? getCurrentUserUid();
  Future<void> ensureUserDocument({required String uid, required String email});
  Future<void> completeInitialProfile({
    required String uid,
    required String email,
    required String username,
    required String displayName,
    required String avatarId,
  });
  Future<void> updateProfileBasics({
    required String uid,
    String? displayName,
    String? avatarId,
  });
  Future<bool> isUsernameAvailable(String username);
  Future<void> updatePreferences({
    required String uid,
    bool? notifiche,
    bool? darkMode,
    bool? gps,
  });
  Future<void> registerQuizCompletion({
    required String uid,
    required String poiId,
    required int xpGained,
    required int correctAnswers,
    required int totalQuestions,
    required int tourElapsedSeconds,
    bool isTourComplete = false,
  });
  Future<void> unlockPendingAchievement(String uid, String achievementId);
  Future<void> deleteUserData({required String uid});
  Future<List<UserProfile>> searchUsers(String query);
  Stream<List<Map<String, dynamic>>> getLeaderboardStream({int limit = 50});

  // Social
  Future<void> sendFriendRequest(String currentUid, String targetUid);
  Future<void> cancelFriendRequest(String currentUid, String targetUid);
  Future<void> acceptFriendRequest(String currentUid, String requesterUid);
  Future<void> rejectFriendRequest(String currentUid, String requesterUid);
  Future<void> removeFriend(String currentUid, String friendUid);
  Future<List<UserProfile>> getUsersByIds(List<String> uids);
  Future<bool> checkAreFriends(String currentUid, String targetUid);
  Future<void> saveFcmToken(String uid, String token);

  // Ban
  Future<bool> isUserBanned(String uid);

  // Onboarding
  Future<void> markOnboardingCompleted(String uid);
}
