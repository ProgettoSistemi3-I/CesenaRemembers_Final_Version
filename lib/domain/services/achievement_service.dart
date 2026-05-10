import 'package:flutter/material.dart';

/// Definizione statica di tutti gli achievement disponibili nell'app.
class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
}

class AchievementService {
  const AchievementService._();

  // ── Catalogue ────────────────────────────────────────────────────────────

  static const List<AchievementDefinition> all = [
    AchievementDefinition(
      id: 'first_visit',
      title: 'Primo passo',
      description: 'Visita il tuo primo sito storico',
      icon: Icons.place_rounded,
    ),
    AchievementDefinition(
      id: 'first_quiz',
      title: 'Studente',
      description: 'Completa il tuo primo quiz',
      icon: Icons.quiz_rounded,
    ),
    AchievementDefinition(
      id: 'first_tour',
      title: 'Pioniere',
      description: 'Finisci il tuo primo tour completo',
      icon: Icons.flag_rounded,
    ),
    AchievementDefinition(
      id: 'quiz_15',
      title: 'Veterano',
      description: 'Completa 15 quiz',
      icon: Icons.workspace_premium_rounded,
    ),
    AchievementDefinition(
      id: 'perfect_tour',
      title: 'Infallibile',
      description: 'Rispondi correttamente a tutte le domande in un tour',
      icon: Icons.stars_rounded,
    ),
    AchievementDefinition(
      id: 'xp_500',
      title: 'Collezionista',
      description: 'Raggiungi 500 XP totali',
      icon: Icons.bolt_rounded,
    ),
    AchievementDefinition(
      id: 'tour_under_1h',
      title: 'In marcia',
      description: 'Completa un tour in meno di 1 ora',
      icon: Icons.timer_outlined,
    ),
    AchievementDefinition(
      id: 'tour_under_30m',
      title: 'Fulmine',
      description: 'Completa un tour in meno di 30 minuti',
      icon: Icons.electric_bolt_rounded,
    ),
    AchievementDefinition(
      id: 'friend_1',
      title: 'Cittadino',
      description: 'Aggiungi il tuo primo amico',
      icon: Icons.person_add_rounded,
    ),
    AchievementDefinition(
      id: 'friend_5',
      title: 'Circolo storico',
      description: 'Raggiungi 5 amici',
      icon: Icons.group_rounded,
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

  /// Chiamato dentro la transazione di registerQuizCompletion.
  /// Riceve i valori DOPO l'aggiornamento e gli achievement già sbloccati.
  /// Restituisce la lista degli id da aggiungere a unlockedAchievements.
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
      if (condition && !alreadyUnlocked.contains(id) && !newUnlocks.contains(id)) {
        newUnlocks.add(id);
      }
    }

    // Visita 1 posto
    maybeUnlock('first_visit', visitedPoiIds.isNotEmpty);

    // Completa 1 quiz
    maybeUnlock('first_quiz', totalQuizCompleted >= 1);

    // Primo tour completo
    maybeUnlock('first_tour', totalToursCompleted >= 1);

    // 15 quiz
    maybeUnlock('quiz_15', totalQuizCompleted >= 15);

    // Tutte corrette in un tour intero
    if (isTourComplete && totalQuestions > 0) {
      maybeUnlock('perfect_tour', correctAnswers == totalQuestions);
    }

    // 500 XP totali
    maybeUnlock('xp_500', totalXp >= 500);

    // Tour < 1h (3600s)
    if (isTourComplete && tourElapsedSeconds > 0) {
      maybeUnlock('tour_under_1h', tourElapsedSeconds < 3600);
    }

    // Tour < 30m (1800s)
    if (isTourComplete && tourElapsedSeconds > 0) {
      maybeUnlock('tour_under_30m', tourElapsedSeconds < 1800);
    }

    return newUnlocks;
  }

  // ── Evaluation on social changes ─────────────────────────────────────────

  /// Chiamato dopo acceptFriendRequest.
  /// friendCount = numero di amici DOPO l'accettazione.
  static List<String> evaluateOnFriendAdded({
    required List<String> alreadyUnlocked,
    required int friendCount,
  }) {
    final newUnlocks = <String>[];

    void maybeUnlock(String id, bool condition) {
      if (condition && !alreadyUnlocked.contains(id) && !newUnlocks.contains(id)) {
        newUnlocks.add(id);
      }
    }

    maybeUnlock('friend_1', friendCount >= 1);
    maybeUnlock('friend_5', friendCount >= 5);

    return newUnlocks;
  }
}
