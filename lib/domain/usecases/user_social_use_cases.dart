import '../entities/userprofile.dart';
import '../repositories/user_repository.dart';

class UserSocialUseCases {
  const UserSocialUseCases(this._repository);

  final IUserRepository _repository;

  Future<List<UserProfile>> searchUsers(String query) =>
      _repository.searchUsers(query);

  Future<void> sendFriendRequest(String currentUid, String targetUid) =>
      _repository.sendFriendRequest(currentUid, targetUid);

  Future<void> cancelFriendRequest(String currentUid, String targetUid) =>
      _repository.cancelFriendRequest(currentUid, targetUid);

  Future<void> acceptFriendRequest(String currentUid, String requesterUid) =>
      _repository.acceptFriendRequest(currentUid, requesterUid);

  Future<void> rejectFriendRequest(String currentUid, String requesterUid) =>
      _repository.rejectFriendRequest(currentUid, requesterUid);

  Future<void> removeFriend(String currentUid, String friendUid) =>
      _repository.removeFriend(currentUid, friendUid);

  Future<List<UserProfile>> getUsersByIds(List<String> uids) =>
      _repository.getUsersByIds(uids);
}
