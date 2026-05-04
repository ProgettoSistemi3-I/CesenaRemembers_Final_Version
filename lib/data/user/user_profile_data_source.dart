import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/userprofile.dart';
import '../../domain/validation/profile_validation.dart';
import '../../models/user_model.dart';

class UserProfileDataSource {
  UserProfileDataSource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _usernames =>
      _firestore.collection('usernames');

  String? getCurrentUserUid() => FirebaseAuth.instance.currentUser?.uid;

  Future<UserProfile> getUserProfile(String uid) async {
    final snapshot = await _users.doc(uid).get();

    if (!snapshot.exists || snapshot.data() == null) {
      throw Exception('Profilo utente non trovato per uid: $uid');
    }

    return UserModel.fromJson(snapshot.data()!, snapshot.id);
  }

  Stream<UserProfile?> getUserProfileStream(String uid) {
    return _users.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromJson(snapshot.data()!, snapshot.id);
      }
      return null;
    });
  }

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
      await _firestore.runTransaction((transaction) async {
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

  Future<bool> isUsernameAvailable(String username) async {
    final normalizedUsername = ProfileValidation.normalizeUsername(username);
    final snapshot = await _usernames.doc(normalizedUsername).get();
    return !snapshot.exists;
  }

  Future<void> updatePreferences({
    required String uid,
    bool? notifiche,
    bool? darkMode,
    bool? gps,
  }) async {
    // 1. Creiamo la mappa interna per le preferenze
    final Map<String, dynamic> prefsUpdate = {};
    if (notifiche != null) prefsUpdate['notifiche'] = notifiche;
    if (darkMode != null) prefsUpdate['modalitaNotte'] = darkMode;
    if (gps != null) prefsUpdate['posizioneGps'] = gps;

    // 2. Creiamo l'aggiornamento principale
    final Map<String, dynamic> updates = {
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // 3. Inseriamo la mappa interna dentro l'aggiornamento principale (se c'è qualcosa da aggiornare)
    if (prefsUpdate.isNotEmpty) {
      updates['preferences'] = prefsUpdate;
    }

    // 4. Ora il merge: true capirà che deve unire i dati DENTRO la mappa 'preferences'
    await _users.doc(uid).set(updates, SetOptions(merge: true));
  }

  Future<List<UserProfile>> searchUsers(String query) async {
    final cleanQuery = query.trim().toLowerCase();
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
}
