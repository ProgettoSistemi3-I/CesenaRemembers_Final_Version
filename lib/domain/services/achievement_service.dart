import 'package:flutter/material.dart';

/// Definizione statica di un achievement con asset image.
class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.assetPath,
  });

  final String id;

  /// Path asset immagine badge (es. 'assets/achievements/first_visit.png')
  final String assetPath;
}

class AchievementService {
  const AchievementService._();

  // ── Catalogue ────────────────────────────────────────────────────────────

  static const List<AchievementDefinition> all = [
    AchievementDefinition(
      id: 'first_visit',
      assetPath: 'assets/achievements/first_visit.png',
    ),
    AchievementDefinition(
      id: 'first_quiz',
      assetPath: 'assets/achievements/first_quiz.png',
    ),
    AchievementDefinition(
      id: 'first_tour',
      assetPath: 'assets/achievements/first_tour.png',
    ),
    AchievementDefinition(
      id: 'quiz_15',
      assetPath: 'assets/achievements/quiz_15.png',
    ),
    AchievementDefinition(
      id: 'perfect_tour',
      assetPath: 'assets/achievements/perfect_tour.png',
    ),
    AchievementDefinition(
      id: 'xp_500',
      assetPath: 'assets/achievements/xp_500.png',
    ),
    AchievementDefinition(
      id: 'tour_under_1h',
      assetPath: 'assets/achievements/tour_under_1h.png',
    ),
    AchievementDefinition(
      id: 'tour_under_30m',
      assetPath: 'assets/achievements/tour_under_30m.png',
    ),
    AchievementDefinition(
      id: 'friend_1',
      assetPath: 'assets/achievements/friend_1.png',
    ),
    AchievementDefinition(
      id: 'friend_5',
      assetPath: 'assets/achievements/friend_5.png',
    ),
  ];

  static AchievementDefinition? findById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Evaluation on quiz/tour completion ───────────────────────────────────

  static List<String> evaluateOnQuizCompletion({
    required List<String> alreadyUnlocked,
    required List<String> visitedPoiIds,
    required int totalQuizCompleted,
    required int totalToursCompleted,
    required int totalXp,
    required int correctAnswers,
    required int totalQuestions,
    required int tourElapsedSeconds,
    required bool isTourComplete,
  }) {
    final newUnlocks = <String>[];

    void maybeUnlock(String id, bool condition) {
      if (condition &&
          !alreadyUnlocked.contains(id) &&
          !newUnlocks.contains(id)) {
        newUnlocks.add(id);
      }
    }

    maybeUnlock('first_visit', visitedPoiIds.isNotEmpty);
    maybeUnlock('first_quiz', totalQuizCompleted >= 1);
    maybeUnlock('first_tour', totalToursCompleted >= 1);
    maybeUnlock('quiz_15', totalQuizCompleted >= 15);

    if (isTourComplete && totalQuestions > 0) {
      maybeUnlock('perfect_tour', correctAnswers == totalQuestions);
    }

    maybeUnlock('xp_500', totalXp >= 500);

    if (isTourComplete && tourElapsedSeconds > 0) {
      maybeUnlock('tour_under_1h', tourElapsedSeconds < 3600);
    }

    if (isTourComplete && tourElapsedSeconds > 0) {
      maybeUnlock('tour_under_30m', tourElapsedSeconds < 1800);
    }

    return newUnlocks;
  }

  // ── Evaluation on social changes ─────────────────────────────────────────

  static List<String> evaluateOnFriendAdded({
    required List<String> alreadyUnlocked,
    required int friendCount,
  }) {
    final newUnlocks = <String>[];

    void maybeUnlock(String id, bool condition) {
      if (condition &&
          !alreadyUnlocked.contains(id) &&
          !newUnlocks.contains(id)) {
        newUnlocks.add(id);
      }
    }

    maybeUnlock('friend_1', friendCount >= 1);
    maybeUnlock('friend_5', friendCount >= 5);

    return newUnlocks;
  }
}
