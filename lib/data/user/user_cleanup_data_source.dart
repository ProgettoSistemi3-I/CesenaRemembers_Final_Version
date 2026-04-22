import 'package:cloud_firestore/cloud_firestore.dart';

class UserCleanupDataSource {
  UserCleanupDataSource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _usernames =>
      _firestore.collection('usernames');

  Future<void> deleteUserData({required String uid}) async {
    final userRef = _users.doc(uid);
    final snapshot = await userRef.get();

    if (!snapshot.exists) return;

    final data = snapshot.data()!;
    final normalizedUsername = (data['usernameNormalized'] as String?)?.trim();

    final List<String> myFriends = List<String>.from(data['friends'] ?? []);
    final List<String> iSentRequestsTo = List<String>.from(
      data['sentFriendRequests'] ?? [],
    );
    final List<String> theySentRequestsToMe = List<String>.from(
      data['receivedFriendRequests'] ?? [],
    );

    final List<Future> cleanupTasks = [];

    for (String friendUid in myFriends) {
      cleanupTasks.add(
        _users
            .doc(friendUid)
            .update({
              'friends': FieldValue.arrayRemove([uid]),
            })
            .catchError((_) {}),
      );
    }
    for (String targetUid in iSentRequestsTo) {
      cleanupTasks.add(
        _users
            .doc(targetUid)
            .update({
              'receivedFriendRequests': FieldValue.arrayRemove([uid]),
            })
            .catchError((_) {}),
      );
    }
    for (String requesterUid in theySentRequestsToMe) {
      cleanupTasks.add(
        _users
            .doc(requesterUid)
            .update({
              'sentFriendRequests': FieldValue.arrayRemove([uid]),
            })
            .catchError((_) {}),
      );
    }

    await Future.wait(cleanupTasks);

    await userRef.delete();

    if (normalizedUsername != null && normalizedUsername.isNotEmpty) {
      try {
        await _usernames.doc(normalizedUsername).delete();
      } catch (_) {}
    }
  }
}
