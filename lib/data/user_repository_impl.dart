import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // LEGALE QUI: DATA LAYER

import '../domain/entities/userprofile.dart';
import '../domain/repositories/user_repository.dart';
import '../domain/validation/profile_validation.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements IUserRepository {
  UserRepositoryImpl({required this.firestore});

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _usernames =>
      firestore.collection('usernames');

  @override
  String? getCurrentUserUid() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Future<UserProfile> getUserProfile(String uid) async {
    final snapshot = await _users.doc(uid).get();

    if (!snapshot.exists || snapshot.data() == null) {
      throw Exception('Profilo utente non trovato per uid: $uid');
    }

    return UserModel.fromJson(snapshot.data()!, snapshot.id);
  }

  @override
  Stream<UserProfile?> getUserProfileStream(String uid) {
    return _users.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromJson(snapshot.data()!, snapshot.id);
      }
      return null;
    });
  }

  @override
  Future<void> ensureUserDocument({
    required String uid,
    required String email,
  }) async {
    final doc = await _users.doc(uid).get();
    if (doc.exists) {
      return;
    }
    await _users.doc(uid).set({
      'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> completeInitialProfile({
    required String uid,
    required String email,
    required String username,
    required String displayName,
    required String avatarId,
  }) async {
    if (!ProfileValidation.isValidDisplayName(displayName)) {
      throw Exception('INVALID_DISPLAY_NAME');
    }
    if (ProfileValidation.hasOffensiveDisplayName(displayName)) {
      throw Exception('OFFENSIVE_DISPLAY_NAME');
    }
    if (!ProfileValidation.isValidUsername(username)) {
      throw Exception('INVALID_USERNAME');
    }
    if (ProfileValidation.hasOffensiveUsername(username)) {
      throw Exception('OFFENSIVE_USERNAME');
    }

    final normalizedUsername = ProfileValidation.normalizeUsername(username);
    final userRef = _users.doc(uid);
    final usernameRef = _usernames.doc(normalizedUsername);

    try {
      await firestore.runTransaction((transaction) async {
        final existingUsername = await transaction.get(usernameRef);
        if (existingUsername.exists) {
          final ownerUid = existingUsername.data()?['uid'];
          if (ownerUid != uid) {
            throw Exception('USERNAME_NOT_AVAILABLE');
          }
        }

        final existingUser = await transaction.get(userRef);
        final existingData = existingUser.data() ?? <String, dynamic>{};

        final alreadyCompleted = existingData['profileCompleted'] == true;
        if (alreadyCompleted) {
          return;
        }

        transaction.set(usernameRef, {
          'uid': uid,
          'username': username.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        transaction.set(
          userRef,
          _buildCompletedProfilePayload(
            existingData: existingData,
            email: email,
            username: username,
            normalizedUsername: normalizedUsername,
            displayName: displayName,
            avatarId: avatarId,
          ),
          SetOptions(merge: true),
        );
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('USERNAME_INDEX_PERMISSION_DENIED');
      }
      rethrow;
    }
  }

  Map<String, dynamic> _buildCompletedProfilePayload({
    required Map<String, dynamic> existingData,
    required String email,
    required String username,
    required String normalizedUsername,
    required String displayName,
    required String avatarId,
  }) {
    final existingPrefs = Map<String, dynamic>.from(
      existingData['preferences'] as Map<String, dynamic>? ?? const {},
    );

    return {
      'email': email,
      'displayName': displayName.trim(),
      'username': username.trim(),
      'usernameNormalized': normalizedUsername,
      'avatarId': avatarId,
      'profileCompleted': true,
      'profileCompletedAt': FieldValue.serverTimestamp(),
      'xp': (existingData['xp'] as num?)?.toInt() ?? 0,
      'visitedPoiIds': List<String>.from(existingData['visitedPoiIds'] ?? []),
      'unlockedAchievements': List<String>.from(
        existingData['unlockedAchievements'] ?? [],
      ),
      'maxQuizScore': (existingData['maxQuizScore'] as num?)?.toInt() ?? 0,
      'totalQuizCompleted':
          (existingData['totalQuizCompleted'] as num?)?.toInt() ?? 0,
      'totalCorrectAnswers':
          (existingData['totalCorrectAnswers'] as num?)?.toInt() ?? 0,
      'bestTourTimeSeconds':
          (existingData['bestTourTimeSeconds'] as num?)?.toInt() ?? 0,
      'leaderboardScore':
          (existingData['leaderboardScore'] as num?)?.toInt() ?? 0,
      'preferences': {
        'notifiche': existingPrefs['notifiche'] ?? true,
        'modalitaNotte': existingPrefs['modalitaNotte'] ?? false,
        'posizioneGps': existingPrefs['posizioneGps'] ?? true,
      },
      'createdAt': existingData['createdAt'] ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  Future<List<UserProfile>> searchUsers(String query) async {
    final cleanQuery = query.trim().toLowerCase();
    // Evita letture Firestore inutili per query troppo corte o vuote.
    if (cleanQuery.length < 2) return [];

    try {
      final snapshot = await _users
          .where('usernameNormalized', isGreaterThanOrEqualTo: cleanQuery)
          .where('usernameNormalized', isLessThanOrEqualTo: '$cleanQuery\uf8ff')
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Errore durante la ricerca utenti: $e');
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> getLeaderboardStream({int limit = 50}) {
    return _users.orderBy('xp', descending: true).limit(limit).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return data;
      }).toList();
    });
  }

  @override
  Future<void> updateProfileBasics({
    required String uid,
    String? displayName,
    String? avatarId,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (displayName != null && displayName.trim().isNotEmpty) {
      if (!ProfileValidation.isValidDisplayName(displayName)) {
        throw Exception('INVALID_DISPLAY_NAME');
      }
      if (ProfileValidation.hasOffensiveDisplayName(displayName)) {
        throw Exception('OFFENSIVE_DISPLAY_NAME');
      }
      updates['displayName'] = displayName.trim();
    }
    if (avatarId != null && avatarId.trim().isNotEmpty) {
      updates['avatarId'] = avatarId.trim();
    }

    await _users.doc(uid).set(updates, SetOptions(merge: true));
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    final normalizedUsername = ProfileValidation.normalizeUsername(username);
    final snapshot = await _usernames.doc(normalizedUsername).get();
    return !snapshot.exists;
  }

  @override
  Future<void> updatePreferences({
    required String uid,
    bool? notifiche,
    bool? darkMode,
    bool? gps,
  }) async {
    final Map<String, dynamic> updates = {
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (notifiche != null) updates['preferences.notifiche'] = notifiche;
    if (darkMode != null) updates['preferences.modalitaNotte'] = darkMode;
    if (gps != null) updates['preferences.posizioneGps'] = gps;

    await _users.doc(uid).set(updates, SetOptions(merge: true));
  }

  @override
  Future<void> registerQuizCompletion({
    required String uid,
    required String poiId,
    required int xpGained,
    required int correctAnswers,
    required int totalQuestions,
    required int tourElapsedSeconds,
  }) async {
    final userRef = _users.doc(uid);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final data = snapshot.data() ?? <String, dynamic>{};
      final visitedPoiIds = List<String>.from(
        data['visitedPoiIds'] ?? const [],
      );

      if (visitedPoiIds.contains(poiId)) {
        return;
      }

      final currentXp = (data['xp'] as num?)?.toInt() ?? 0;
      final nextXp = currentXp + xpGained;
      final currentLeaderboard =
          (data['leaderboardScore'] as num?)?.toInt() ?? 0;
      final currentMaxQuizScore = (data['maxQuizScore'] as num?)?.toInt() ?? 0;
      final currentQuizCompleted =
          (data['totalQuizCompleted'] as num?)?.toInt() ?? 0;
      final currentCorrectAnswers =
          (data['totalCorrectAnswers'] as num?)?.toInt() ?? 0;
      final currentBestTourTime =
          (data['bestTourTimeSeconds'] as num?)?.toInt() ?? 0;
      final quizScorePercent = totalQuestions <= 0
          ? 0
          : ((correctAnswers / totalQuestions) * 100).round();
      visitedPoiIds.add(poiId);

      transaction.set(userRef, {
        'visitedPoiIds': visitedPoiIds,
        'xp': nextXp,
        'leaderboardScore': nextXp > currentLeaderboard
            ? nextXp
            : currentLeaderboard,
        'maxQuizScore': quizScorePercent > currentMaxQuizScore
            ? quizScorePercent
            : currentMaxQuizScore,
        'totalQuizCompleted': currentQuizCompleted + 1,
        'totalCorrectAnswers': currentCorrectAnswers + correctAnswers,
        'bestTourTimeSeconds':
            currentBestTourTime == 0 || tourElapsedSeconds < currentBestTourTime
            ? tourElapsedSeconds
            : currentBestTourTime,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  @override
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

    // 1. Rimuoviamo il nostro UID dagli altri in modo indipendente.
    // Usiamo Future.wait per eseguirli tutti insieme velocemente, ma con .catchError
    // per far sì che se un amico non esiste più, non blocchi gli altri!
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

    // Aspettiamo che Firebase pulisca tutti i documenti degli altri
    await Future.wait(cleanupTasks);

    // 2. Eliminiamo il nostro documento principale
    await userRef.delete();

    // 3. Eliminiamo l'indice dell'username
    if (normalizedUsername != null && normalizedUsername.isNotEmpty) {
      try {
        await _usernames.doc(normalizedUsername).delete();
      } catch (_) {}
    }
  }

  @override
  Future<void> sendFriendRequest(String currentUid, String targetUid) async {
    await firestore.runTransaction((tx) async {
      tx.update(_users.doc(currentUid), {
        'sentFriendRequests': FieldValue.arrayUnion([targetUid]),
      });
      tx.update(_users.doc(targetUid), {
        'receivedFriendRequests': FieldValue.arrayUnion([currentUid]),
      });
    });
  }

  @override
  Future<void> cancelFriendRequest(String currentUid, String targetUid) async {
    await firestore.runTransaction((tx) async {
      tx.update(_users.doc(currentUid), {
        'sentFriendRequests': FieldValue.arrayRemove([targetUid]),
      });
      tx.update(_users.doc(targetUid), {
        'receivedFriendRequests': FieldValue.arrayRemove([currentUid]),
      });
    });
  }

  @override
  Future<void> acceptFriendRequest(
    String currentUid,
    String requesterUid,
  ) async {
    await firestore.runTransaction((tx) async {
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

  @override
  Future<void> rejectFriendRequest(
    String currentUid,
    String requesterUid,
  ) async {
    await firestore.runTransaction((tx) async {
      tx.update(_users.doc(currentUid), {
        'receivedFriendRequests': FieldValue.arrayRemove([requesterUid]),
      });
      tx.update(_users.doc(requesterUid), {
        'sentFriendRequests': FieldValue.arrayRemove([currentUid]),
      });
    });
  }

  @override
  Future<void> removeFriend(String currentUid, String friendUid) async {
    await firestore.runTransaction((tx) async {
      tx.update(_users.doc(currentUid), {
        'friends': FieldValue.arrayRemove([friendUid]),
      });
      tx.update(_users.doc(friendUid), {
        'friends': FieldValue.arrayRemove([currentUid]),
      });
    });
  }

  @override
  Future<List<UserProfile>> getUsersByIds(List<String> uids) async {
    if (uids.isEmpty) return [];
    List<UserProfile> result = [];
    // Firestore accetta query 'in' fino a 10 elementi per volta
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
