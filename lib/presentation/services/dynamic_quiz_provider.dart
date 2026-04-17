import '../../data/repositories/quiz_history_repository.dart';
import '../../data/services/grok_quiz_service.dart';
import '../../domain/entities/quiz_question.dart';
import '../../domain/entities/tour_stop.dart';

class DynamicQuizProvider {
  DynamicQuizProvider({
    required this.grokQuizService,
    required this.quizHistoryRepository,
  });

  final GrokQuizService grokQuizService;
  final QuizHistoryRepository quizHistoryRepository;

  final Map<String, List<QuizQuestion>> _cacheByStopId = {};
  final Map<String, Future<List<QuizQuestion>>> _inFlightByStopId = {};

  Future<List<QuizQuestion>> getQuizForStop({
    required TourStop stop,
    required int userLevel,
    required String? uid,
    int questionCount = 3,
  }) {
    final cacheKey = stop.id;

    final cached = _cacheByStopId[cacheKey];
    if (cached != null && cached.isNotEmpty) {
      return Future.value(cached);
    }

    final inFlight = _inFlightByStopId[cacheKey];
    if (inFlight != null) {
      return inFlight;
    }

    final future = _loadQuiz(
      stop: stop,
      userLevel: userLevel,
      uid: uid,
      questionCount: questionCount,
    );
    _inFlightByStopId[cacheKey] = future;

    return future.whenComplete(() {
      _inFlightByStopId.remove(cacheKey);
    });
  }

  Future<void> prefetchForStop({
    required TourStop stop,
    required int userLevel,
    required String? uid,
  }) async {
    await getQuizForStop(stop: stop, userLevel: userLevel, uid: uid);
  }

  Future<List<QuizQuestion>> _loadQuiz({
    required TourStop stop,
    required int userLevel,
    required String? uid,
    required int questionCount,
  }) async {
    final fallback = _fallbackQuestions(stop, questionCount: questionCount);
    try {
      if (uid == null || uid.isEmpty) {
        _cacheByStopId[stop.id] = fallback;
        return fallback;
      }

      final recentQuestions = await quizHistoryRepository.getRecentQuestions(
        uid: uid,
        poiId: stop.id,
      );

      final generated = await grokQuizService.generateQuiz(
        stop: stop,
        userLevel: userLevel,
        excludedQuestions: recentQuestions,
        questionCount: questionCount,
      );

      if (generated.isEmpty) {
        _cacheByStopId[stop.id] = fallback;
        return fallback;
      }

      final selected = generated.take(questionCount).toList(growable: false);
      _cacheByStopId[stop.id] = selected;

      await quizHistoryRepository.appendQuestions(
        uid: uid,
        poiId: stop.id,
        questions: selected.map((question) => question.question).toList(),
      );

      return selected;
    } catch (_) {
      _cacheByStopId[stop.id] = fallback;
      return fallback;
    }
  }

  List<QuizQuestion> _fallbackQuestions(TourStop stop, {required int questionCount}) {
    if (stop.questions.isEmpty) return const [];
    return stop.questions.take(questionCount).toList(growable: false);
  }
}
