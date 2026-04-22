import '../entities/userprofile.dart';
import '../repositories/user_repository.dart';

class UserProfileUseCases {
  const UserProfileUseCases(this._repository);

  final IUserRepository _repository;

  String? getCurrentUserUid() => _repository.getCurrentUserUid();

  Future<UserProfile> getUserProfile(String uid) => _repository.getUserProfile(uid);

  Stream<UserProfile?> getUserProfileStream(String uid) =>
      _repository.getUserProfileStream(uid);

  Future<void> ensureUserDocument({
    required String uid,
    required String email,
  }) => _repository.ensureUserDocument(uid: uid, email: email);

  Future<void> completeInitialProfile({
    required String uid,
    required String email,
    required String username,
    required String displayName,
    required String avatarId,
  }) => _repository.completeInitialProfile(
    uid: uid,
    email: email,
    username: username,
    displayName: displayName,
    avatarId: avatarId,
  );

  Future<void> updateProfileBasics({
    required String uid,
    String? displayName,
    String? avatarId,
  }) => _repository.updateProfileBasics(
    uid: uid,
    displayName: displayName,
    avatarId: avatarId,
  );

  Future<bool> isUsernameAvailable(String username) =>
      _repository.isUsernameAvailable(username);

  Future<void> deleteUserData({required String uid}) =>
      _repository.deleteUserData(uid: uid);
}
