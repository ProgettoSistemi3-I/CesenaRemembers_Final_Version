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

  Future<void> acceptFriendRequest(
    String currentUid,
    String requesterUid,
  ) async {
    // Legge solo il documento dell'utente corrente per calcolare gli achievement.
    // NON leggiamo il documento del richiedente in transazione: le Security Rules
    // vietano di scrivere campi al di fuori di
    // ['receivedFriendRequests','sentFriendRequests','friends','updatedAt']
    // sul documento altrui. Scrivere 'unlockedAchievements' sul richiedente
    // viola questa regola e causa il rollback con "Operazione non riuscita".
    final currentSnap = await _users.doc(currentUid).get();
    final currentData = currentSnap.data() ?? <String, dynamic>{};

    final currentFriends = List<String>.from(currentData['friends'] ?? []);
    if (!currentFriends.contains(requesterUid))
      currentFriends.add(requesterUid);

    final currentUnlocked = List<String>.from(
      currentData['unlockedAchievements'] ?? [],
    );
    final newForCurrent = AchievementService.evaluateOnFriendAdded(
      alreadyUnlocked: currentUnlocked,
      friendCount: currentFriends.length,
    );

    // Usa un batch: nessun tx.get sul documento del richiedente,
    // quindi nessuna violazione di rules.
    final batch = _firestore.batch();

    // Aggiorna il documento dell'utente corrente (owner: può scrivere tutto).
    batch.update(_users.doc(currentUid), {
      'receivedFriendRequests': FieldValue.arrayRemove([requesterUid]),
      'friends': currentFriends,
      if (newForCurrent.isNotEmpty)
        'unlockedAchievements': FieldValue.arrayUnion(newForCurrent),
    });

    // Aggiorna il documento del richiedente usando SOLO i campi consentiti
    // dalla regola "non-owner" delle Security Rules:
    // ['receivedFriendRequests', 'sentFriendRequests', 'friends', 'updatedAt'].
    // Gli achievement del richiedente verranno valutati dal suo dispositivo
    // alla prossima sessione tramite getUserProfileStream.
    batch.update(_users.doc(requesterUid), {
      'sentFriendRequests': FieldValue.arrayRemove([currentUid]),
      'friends': FieldValue.arrayUnion([currentUid]),
    });

    await batch.commit();
  }

  Future<void> rejectFriendRequest(
    String currentUid,
    String requesterUid,
  ) async {
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
      final snap = await _users
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      result.addAll(
        snap.docs.map((doc) => UserModel.fromJson(doc.data(), doc.id)),
      );
    }
    return result;
  }
}
