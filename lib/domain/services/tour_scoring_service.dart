class TourScoreBreakdown {
  const TourScoreBreakdown({
    required this.baseXp,
    required this.timeMultiplier,
    required this.totalXp,
  });

  final int baseXp;
  final double timeMultiplier;
  final int totalXp;
}

class TourScoringService {
  const TourScoringService({
    this.xpPerCorrectAnswer = 20,
    this.maxTimeMultiplier = 1.25,
  });

  final int xpPerCorrectAnswer;
  final double maxTimeMultiplier;

  TourScoreBreakdown calculate({
    required int correctAnswers,
    required int totalElapsedSeconds,
  }) {
    final safeCorrectAnswers = correctAnswers < 0 ? 0 : correctAnswers;
    final baseXp = safeCorrectAnswers * xpPerCorrectAnswer;
    final multiplier = _resolveMultiplier(totalElapsedSeconds);
    final totalXp = (baseXp * multiplier).round();

    return TourScoreBreakdown(
      baseXp: baseXp,
      timeMultiplier: multiplier,
      totalXp: totalXp,
    );
  }

  double _resolveMultiplier(int elapsedSeconds) {
    if (elapsedSeconds <= 0) return maxTimeMultiplier;
    if (elapsedSeconds <= 5 * 60) return maxTimeMultiplier;
    if (elapsedSeconds <= 10 * 60) return 1.15;
    if (elapsedSeconds <= 15 * 60) return 1.08;
    return 1.00;
  }
}
