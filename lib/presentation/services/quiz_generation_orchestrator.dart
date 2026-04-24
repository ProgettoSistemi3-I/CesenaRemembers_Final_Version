import '../../domain/entities/quiz_question.dart';
import '../../domain/entities/tour_stop.dart';
import 'grok_quiz_service.dart';
import 'quiz_history_service.dart';

class QuizGenerationOrchestrator {
  QuizGenerationOrchestrator({
    required GrokQuizService grokQuizService,
    required QuizHistoryService historyService,
  }) : _grokQuizService = grokQuizService,
       _historyService = historyService;

  final GrokQuizService _grokQuizService;
  final QuizHistoryService _historyService;

  final Map<String, Future<List<QuizQuestion>>> _inFlightByStop = {};
  final Map<String, List<QuizQuestion>> _cacheByStop = {};

  Future<void> prepareForStop({
    required TourStop stop,
    required String uid,
    required int profileLevel,
  }) async {
    await _ensureGenerated(stop: stop, uid: uid, profileLevel: profileLevel);
  }

  Future<void> prefetchNextStop({
    required TourStop? stop,
    required String uid,
    required int profileLevel,
  }) async {
    if (stop == null) return;
    _ensureGenerated(stop: stop, uid: uid, profileLevel: profileLevel);
  }

  Future<List<QuizQuestion>> getQuestionsForStop({
    required TourStop stop,
    required String uid,
    required int profileLevel,
  }) {
    return _ensureGenerated(stop: stop, uid: uid, profileLevel: profileLevel);
  }

  Future<List<QuizQuestion>> _ensureGenerated({
    required TourStop stop,
    required String uid,
    required int profileLevel,
  }) {
    final cached = _cacheByStop[stop.id];
    if (cached != null) return Future.value(cached);

    final inFlight = _inFlightByStop[stop.id];
    if (inFlight != null) return inFlight;

    final future = _buildQuestions(stop: stop, uid: uid, profileLevel: profileLevel);
    _inFlightByStop[stop.id] = future;

    future.whenComplete(() {
      _inFlightByStop.remove(stop.id);
    });

    return future;
  }

  Future<List<QuizQuestion>> _buildQuestions({
    required TourStop stop,
    required String uid,
    required int profileLevel,
  }) async {
    final history = await _historyService.getPreviousQuestions(uid: uid, stopId: stop.id);
    final questions = await _grokQuizService.generateQuestions(
      stop: stop,
      profileLevel: profileLevel,
      previousQuestions: history,
    );

    await _historyService.saveQuestions(
      uid: uid,
      stopId: stop.id,
      questions: questions.map((question) => question.question).toList(growable: false),
    );

    _cacheByStop[stop.id] = questions;
    return questions;
  }

  void clearSessionCache() {
    _cacheByStop.clear();
    _inFlightByStop.clear();
  }
}
