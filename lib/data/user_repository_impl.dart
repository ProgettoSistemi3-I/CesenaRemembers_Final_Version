import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/entities/userprofile.dart';
import '../domain/repositories/user_repository.dart';
import 'user/user_cleanup_data_source.dart';
import 'user/user_profile_data_source.dart';
import 'user/user_progress_data_source.dart';
import 'user/user_social_data_source.dart';

class UserRepositoryImpl implements IUserRepository {
  UserRepositoryImpl({required this.firestore})
    : _profile = UserProfileDataSource(firestore: firestore),
      _progress = UserProgressDataSource(firestore: firestore),
      _social = UserSocialDataSource(firestore: firestore),
      _cleanup = UserCleanupDataSource(firestore: firestore);

  final FirebaseFirestore firestore;
  final UserProfileDataSource _profile;
  final UserProgressDataSource _progress;
  final UserSocialDataSource _social;
  final UserCleanupDataSource _cleanup;

  @override
  String? getCurrentUserUid() => _profile.getCurrentUserUid();

  @override
  Future<UserProfile> getUserProfile(String uid) => _profile.getUserProfile(uid);

  @override
  Stream<UserProfile?> getUserProfileStream(String uid) =>
      _profile.getUserProfileStream(uid);

  @override
  Future<void> ensureUserDocument({required String uid, required String email}) =>
      _profile.ensureUserDocument(uid: uid, email: email);

  @override
  Future<void> completeInitialProfile({
    required String uid,
    required String email,
    required String username,
    required String displayName,
    required String avatarId,
  }) => _profile.completeInitialProfile(
    uid: uid,
    email: email,
    username: username,
    displayName: displayName,
    avatarId: avatarId,
  );

  @override
  Future<void> updateProfileBasics({
    required String uid,
    String? displayName,
    String? avatarId,
  }) => _profile.updateProfileBasics(
    uid: uid,
    displayName: displayName,
    avatarId: avatarId,
  );

  @override
  Future<bool> isUsernameAvailable(String username) =>
      _profile.isUsernameAvailable(username);

  @override
  Future<void> updatePreferences({
    required String uid,
    bool? notifiche,
    bool? darkMode,
    bool? gps,
  }) => _profile.updatePreferences(
    uid: uid,
    notifiche: notifiche,
    darkMode: darkMode,
    gps: gps,
  );

  @override
  Future<void> registerQuizCompletion({
    required String uid,
    required String poiId,
    required int xpGained,
    required int correctAnswers,
    required int totalQuestions,
    required int tourElapsedSeconds,
  }) => _progress.registerQuizCompletion(
    uid: uid,
    poiId: poiId,
    xpGained: xpGained,
    correctAnswers: correctAnswers,
    totalQuestions: totalQuestions,
    tourElapsedSeconds: tourElapsedSeconds,
  );

  @override
  Future<void> deleteUserData({required String uid}) =>
      _cleanup.deleteUserData(uid: uid);

  @override
  Future<List<UserProfile>> searchUsers(String query) => _profile.searchUsers(query);

  @override
  Stream<List<Map<String, dynamic>>> getLeaderboardStream({int limit = 50}) =>
      _progress.getLeaderboardStream(limit: limit);

  @override
  Future<void> sendFriendRequest(String currentUid, String targetUid) =>
      _social.sendFriendRequest(currentUid, targetUid);

  @override
  Future<void> cancelFriendRequest(String currentUid, String targetUid) =>
      _social.cancelFriendRequest(currentUid, targetUid);

  @override
  Future<void> acceptFriendRequest(String currentUid, String requesterUid) =>
      _social.acceptFriendRequest(currentUid, requesterUid);

  @override
  Future<void> rejectFriendRequest(String currentUid, String requesterUid) =>
      _social.rejectFriendRequest(currentUid, requesterUid);

  @override
  Future<void> removeFriend(String currentUid, String friendUid) =>
      _social.removeFriend(currentUid, friendUid);

  @override
  Future<List<UserProfile>> getUsersByIds(List<String> uids) =>
      _social.getUsersByIds(uids);
}
