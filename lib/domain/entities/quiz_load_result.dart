import 'quiz_question.dart';

class QuizLoadResult {
  const QuizLoadResult({
    required this.questions,
    required this.usesPersonalizedQuestions,
    this.fallbackNotice,
    this.fallbackDifficultyLabel,
  });

  final List<QuizQuestion> questions;
  final bool usesPersonalizedQuestions;
  final String? fallbackNotice;
  final String? fallbackDifficultyLabel;
}
