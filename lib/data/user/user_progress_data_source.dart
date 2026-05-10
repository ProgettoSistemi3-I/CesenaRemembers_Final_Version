import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/services/achievement_service.dart';

class UserProgressDataSource {
  UserProgressDataSource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

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

  /// [isTourComplete] deve essere true solo sull'ultima tappa del tour,
  /// quando si vuole registrare il tempo totale e valutare gli achievement
  /// legati al completamento del tour intero.
  Future<void> registerQuizCompletion({
    required String uid,
    required String poiId,
    required int xpGained,
    required int correctAnswers,
    required int totalQuestions,
    required int tourElapsedSeconds,
    bool isTourComplete = false,
  }) async {
    final userRef = _users.doc(uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final data = snapshot.data() ?? <String, dynamic>{};

      // ── Visited POIs ───────────────────────────────────────────────────
      final visitedPoiIds = List<String>.from(
        data['visitedPoiIds'] ?? const [],
      );
      final isFirstVisit = !visitedPoiIds.contains(poiId);
      if (isFirstVisit) visitedPoiIds.add(poiId);

      // ── XP ────────────────────────────────────────────────────────────
      final currentXp = (data['xp'] as num?)?.toInt() ?? 0;
      final nextXp = currentXp + xpGained;

      // ── Max XP in un singolo tour ─────────────────────────────────────
      final currentMaxSingleTourXp =
          (data['maxSingleTourXp'] as num?)?.toInt() ?? 0;
      final nextMaxSingleTourXp = isTourComplete && xpGained > currentMaxSingleTourXp
          ? xpGained
          : currentMaxSingleTourXp;

      // ── Quiz stats ────────────────────────────────────────────────────
      final currentMaxQuizScore = (data['maxQuizScore'] as num?)?.toInt() ?? 0;
      final currentQuizCompleted =
          (data['totalQuizCompleted'] as num?)?.toInt() ?? 0;
      final currentToursCompleted =
          (data['totalToursCompleted'] as num?)?.toInt() ?? 0;
      final currentCorrectAnswers =
          (data['totalCorrectAnswers'] as num?)?.toInt() ?? 0;
      final nextQuizCompleted = currentQuizCompleted + 1;
      final nextToursCompleted = isTourComplete ? currentToursCompleted + 1 : currentToursCompleted;
      final nextCorrectAnswers = currentCorrectAnswers + correctAnswers;
      final quizScorePercent = totalQuestions <= 0
          ? 0
          : ((correctAnswers / totalQuestions) * 100).round();

      // ── Best tour time ─────────────────────────────────────────────────
      final currentBestTourTime =
          (data['bestTourTimeSeconds'] as num?)?.toInt() ?? 0;
      final nextBestTourTime = isTourComplete && tourElapsedSeconds > 0
          ? (currentBestTourTime == 0 || tourElapsedSeconds < currentBestTourTime
              ? tourElapsedSeconds
              : currentBestTourTime)
          : currentBestTourTime;

      // ── Achievements ───────────────────────────────────────────────────
      final alreadyUnlocked = List<String>.from(
        data['unlockedAchievements'] ?? const [],
      );
      final newUnlocks = AchievementService.evaluateOnQuizCompletion(
        alreadyUnlocked: alreadyUnlocked,
        visitedPoiIds: visitedPoiIds,
        totalQuizCompleted: nextQuizCompleted,
        totalToursCompleted: nextToursCompleted,
        totalXp: nextXp,
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        tourElapsedSeconds: tourElapsedSeconds,
        isTourComplete: isTourComplete,
      );
      final nextUnlocked = [...alreadyUnlocked, ...newUnlocks];

      // ── Write ─────────────────────────────────────────────────────────
      transaction.set(userRef, {
        'visitedPoiIds': visitedPoiIds,
        'xp': nextXp,
        'leaderboardScore': nextXp,
        'maxSingleTourXp': nextMaxSingleTourXp,
        'maxQuizScore': quizScorePercent > currentMaxQuizScore
            ? quizScorePercent
            : currentMaxQuizScore,
        'totalQuizCompleted': nextQuizCompleted,
        'totalToursCompleted': nextToursCompleted,
        'totalCorrectAnswers': nextCorrectAnswers,
        'bestTourTimeSeconds': nextBestTourTime,
        'unlockedAchievements': nextUnlocked,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }
}
