import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/userprofile.dart';
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
      tx.update(_users.doc(currentUid), {
        'receivedFriendRequests': FieldValue.arrayRemove([requesterUid]),
        'friends': FieldValue.arrayUnion([requesterUid]),
      });
      tx.update(_users.doc(requesterUid), {
        'sentFriendRequests': FieldValue.arrayRemove([currentUid]),
        'friends': FieldValue.arrayUnion([currentUid]),
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
