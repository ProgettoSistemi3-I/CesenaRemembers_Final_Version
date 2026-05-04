import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future<void> registerQuizCompletion({
    required String uid,
    required String poiId,
    required int xpGained,
    required int correctAnswers,
    required int totalQuestions,
    required int tourElapsedSeconds,
  }) async {
    final userRef = _users.doc(uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final data = snapshot.data() ?? <String, dynamic>{};
      final visitedPoiIds = List<String>.from(
        data['visitedPoiIds'] ?? const [],
      );

      final isFirstVisit = !visitedPoiIds.contains(poiId);

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
      if (isFirstVisit) visitedPoiIds.add(poiId);

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
}
