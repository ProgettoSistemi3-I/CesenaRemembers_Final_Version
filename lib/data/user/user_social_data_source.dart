import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/userprofile.dart';
import '../../domain/services/achievement_service.dart';
import '../../models/user_model.dart';

class UserSocialDataSource {
  UserSocialDataSource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<void> sendFriendRequest(String currentUid, String targetUid) async {
    await _firestore.runTransaction((tx) async {
      tx.update(_users.doc(currentUid), {
        'sentFriendRequests': FieldValue.arrayUnion([targetUid]),
      });
      tx.update(_users.doc(targetUid), {
        'receivedFriendRequests': FieldValue.arrayUnion([currentUid]),
      });
    });
  }

  Future<void> cancelFriendRequest(String currentUid, String targetUid) async {
    await _firestore.runTransaction((tx) async {
      tx.update(_users.doc(currentUid), {
        'sentFriendRequests': FieldValue.arrayRemove([targetUid]),
      });
      tx.update(_users.doc(targetUid), {
        'receivedFriendRequests': FieldValue.arrayRemove([currentUid]),
      });
    });
  }

  Future<void> acceptFriendRequest(String currentUid, String requesterUid) async {
    await _firestore.runTransaction((tx) async {
      final currentSnap = await tx.get(_users.doc(currentUid));
      final requesterSnap = await tx.get(_users.doc(requesterUid));

      final currentData = currentSnap.data() ?? <String, dynamic>{};
      final requesterData = requesterSnap.data() ?? <String, dynamic>{};

      // Calcola il conteggio amici DOPO l'accettazione
      final currentFriends = List<String>.from(currentData['friends'] ?? []);
      final requesterFriends = List<String>.from(requesterData['friends'] ?? []);
      if (!currentFriends.contains(requesterUid)) currentFriends.add(requesterUid);
      if (!requesterFriends.contains(currentUid)) requesterFriends.add(currentUid);

      // Valuta achievement per entrambi
      final currentUnlocked = List<String>.from(
        currentData['unlockedAchievements'] ?? [],
      );
      final requesterUnlocked = List<String>.from(
        requesterData['unlockedAchievements'] ?? [],
      );

      final newForCurrent = AchievementService.evaluateOnFriendAdded(
        alreadyUnlocked: currentUnlocked,
        friendCount: currentFriends.length,
      );
      final newForRequester = AchievementService.evaluateOnFriendAdded(
        alreadyUnlocked: requesterUnlocked,
        friendCount: requesterFriends.length,
      );

      tx.update(_users.doc(currentUid), {
        'receivedFriendRequests': FieldValue.arrayRemove([requesterUid]),
        'friends': currentFriends,
        if (newForCurrent.isNotEmpty)
          'unlockedAchievements': [...currentUnlocked, ...newForCurrent],
      });
      tx.update(_users.doc(requesterUid), {
        'sentFriendRequests': FieldValue.arrayRemove([currentUid]),
        'friends': requesterFriends,
        if (newForRequester.isNotEmpty)
          'unlockedAchievements': [...requesterUnlocked, ...newForRequester],
      });
    });
  }

  Future<void> rejectFriendRequest(String currentUid, String requesterUid) async {
    await _firestore.runTransaction((tx) async {
      tx.update(_users.doc(currentUid), {
        'receivedFriendRequests': FieldValue.arrayRemove([requesterUid]),
      });
      tx.update(_users.doc(requesterUid), {
        'sentFriendRequests': FieldValue.arrayRemove([currentUid]),
      });
    });
  }

  Future<void> removeFriend(String currentUid, String friendUid) async {
    await _firestore.runTransaction((tx) async {
      tx.update(_users.doc(currentUid), {
        'friends': FieldValue.arrayRemove([friendUid]),
      });
      tx.update(_users.doc(friendUid), {
        'friends': FieldValue.arrayRemove([currentUid]),
      });
    });
  }

  Future<List<UserProfile>> getUsersByIds(List<String> uids) async {
    if (uids.isEmpty) return [];
    final result = <UserProfile>[];

    for (var i = 0; i < uids.length; i += 10) {
      final chunk = uids.sublist(
        i,
        i + 10 > uids.length ? uids.length : i + 10,
      );
      final snap = await _users.where(FieldPath.documentId, whereIn: chunk).get();
      result.addAll(
        snap.docs.map((doc) => UserModel.fromJson(doc.data(), doc.id)),
      );
    }
    return result;
  }
}
