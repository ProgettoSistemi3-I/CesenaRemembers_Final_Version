import '../../domain/entities/quiz_question.dart';

class PoiQuizController {
  PoiQuizController({required List<QuizQuestion> questions})
    : _questions = List.unmodifiable(questions),
      _quizDone = questions.isEmpty;

  final List<QuizQuestion> _questions;

  int? _selectedAnswer;
  int _questionIndex = 0;
  int _score = 0;
  bool _quizDone;
  bool _lastQuestionAnswered = false;

  int? get selectedAnswer => _selectedAnswer;
  int get questionIndex => _questionIndex;
  int get score => _score;
  bool get quizDone => _quizDone;
  bool get isLastQuestionAnswered => _lastQuestionAnswered;
  bool get hasMoreQuestions => _questionIndex < _questions.length - 1;
  QuizQuestion? get currentQuestion =>
      _questions.isEmpty ? null : _questions[_questionIndex];
  int get totalQuestions => _questions.length;

  void selectAnswer(int index) {
    final question = currentQuestion;
    if (question == null) return;
    if (_selectedAnswer != null) return;
    if (index < 0 || index >= question.options.length) return;

    final isCorrect = index == question.correctIndex;
    _selectedAnswer = index;
    if (isCorrect) {
      _score++;
    }
    _lastQuestionAnswered = !hasMoreQuestions;
  }

  void nextQuestion() {
    if (_quizDone) return;
    if (!hasMoreQuestions) return;
    _questionIndex++;
    _selectedAnswer = null;
    _lastQuestionAnswered = false;
  }

  void completeQuiz() {
    if (_quizDone) return;
    if (_questions.isEmpty) {
      _quizDone = true;
      return;
    }
    if (_selectedAnswer == null) return;
    if (!_lastQuestionAnswered) return;
    _quizDone = true;
  }
}
