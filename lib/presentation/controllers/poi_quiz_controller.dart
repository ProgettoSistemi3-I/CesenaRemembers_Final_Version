import 'package:flutter/foundation.dart';
import '../../domain/entities/quiz_question.dart';
import '../../domain/usecases/get_poi_quiz_usecases.dart';

class PoiQuizController extends ChangeNotifier {
  final GetPoiQuizUseCase _getQuizUseCase;

  PoiQuizController({required GetPoiQuizUseCase getQuizUseCase})
      : _getQuizUseCase = getQuizUseCase;

  List<QuizQuestion> _questions = [];
  int? _selectedAnswer;
  int _questionIndex = 0;
  int _score = 0;
  bool _quizDone = false;
  bool _lastQuestionAnswered = false;
  bool _isLoading = false;
  String? _error;

  int? get selectedAnswer => _selectedAnswer;
  int get questionIndex => _questionIndex;
  int get score => _score;
  bool get quizDone => _quizDone;
  bool get isLastQuestionAnswered => _lastQuestionAnswered;
  bool get hasMoreQuestions => _questionIndex < _questions.length - 1;
  QuizQuestion? get currentQuestion => _questions.isEmpty ? null : _questions[_questionIndex];
  int get totalQuestions => _questions.length;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initQuiz(String poiId, String poiName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _questions = await _getQuizUseCase(poiId, poiName);
      _questionIndex = 0;
      _score = 0;
      _selectedAnswer = null;
      _quizDone = _questions.isEmpty;
      _lastQuestionAnswered = false;
    } catch (e) {
      _error = "Errore durante la comunicazione con il server.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
    notifyListeners();
  }

  void nextQuestion() {
    if (_quizDone) return;
    if (!hasMoreQuestions) return;
    _questionIndex++;
    _selectedAnswer = null;
    _lastQuestionAnswered = false;
    notifyListeners();
  }

  void completeQuiz() {
    if (_quizDone) return;
    if (_questions.isEmpty) {
      _quizDone = true;
      notifyListeners();
      return;
    }
    if (_selectedAnswer == null) return;
    if (!_lastQuestionAnswered) return;
    _quizDone = true;
    notifyListeners();
  }
}