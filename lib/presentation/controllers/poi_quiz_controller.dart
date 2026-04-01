import '../../domain/entities/quiz_question.dart';

class PoiQuizController {
  PoiQuizController({required List<QuizQuestion> questions})
    : _questions = List.unmodifiable(questions);

  final List<QuizQuestion> _questions;

  int? _selectedAnswer;
  int _questionIndex = 0;
  int _score = 0;
  bool _quizDone = false;

  int? get selectedAnswer => _selectedAnswer;
  int get questionIndex => _questionIndex;
  int get score => _score;
  bool get quizDone => _quizDone;
  bool get hasMoreQuestions => _questionIndex < _questions.length - 1;
  QuizQuestion get currentQuestion => _questions[_questionIndex];
  int get totalQuestions => _questions.length;

  void selectAnswer(int index) {
    if (_selectedAnswer != null) return;

    final isCorrect = index == currentQuestion.correctIndex;
    _selectedAnswer = index;
    if (isCorrect) {
      _score++;
    }
    if (!hasMoreQuestions) {
      _quizDone = true;
    }
  }

  void nextQuestion() {
    if (!hasMoreQuestions) return;
    _questionIndex++;
    _selectedAnswer = null;
  }
}
