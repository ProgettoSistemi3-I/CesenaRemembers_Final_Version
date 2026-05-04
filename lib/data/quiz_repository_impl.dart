import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/logging/app_logger.dart';
import '../domain/entities/quiz_load_result.dart';
import '../domain/entities/quiz_question.dart';
import '../domain/repositories/i_quiz_repository.dart';
import 'seeds/historic_places_seed.dart';

class QuizRepositoryImpl implements IQuizRepository {
  static const String _baseUrl = 'https://sharika-matripotestal-ina.ngrok-free.dev';
  static const _fallbackDifficultyLabel = 'Difficoltà standard (seed locale)';
  static const Duration _cacheTtl = Duration(minutes: 10);

  static final Map<String, _CachedQuizResult> _quizCache = {};
  static final Map<String, Future<QuizLoadResult>> _inFlightRequests = {};

  @override
  Future<QuizLoadResult> getQuizForPoi(
    String poiId,
    String poiName,
    int userXp,
  ) async {
    final cacheKey = '$poiId|$userXp';
    final cached = _quizCache[cacheKey];
    if (cached != null && DateTime.now().difference(cached.timestamp) < _cacheTtl) {
      return cached.result;
    }

    final inFlight = _inFlightRequests[cacheKey];
    if (inFlight != null) {
      return inFlight;
    }

    final request = _fetchQuiz(poiId, poiName, userXp, cacheKey);
    _inFlightRequests[cacheKey] = request;
    try {
      return await request;
    } finally {
      _inFlightRequests.remove(cacheKey);
    }
  }

  Future<QuizLoadResult> _fetchQuiz(
    String poiId,
    String poiName,
    int userXp,
    String cacheKey,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/generate-quiz'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'id': poiId,
              'name': poiName,
              'description':
                  'Informazioni storiche generali su $poiName della città di Cesena.',
              'userXp': userXp,
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        throw StateError('HTTP ${response.statusCode}');
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> questionsJson = data['questions'] ?? [];
      final questions = questionsJson.map((q) => QuizQuestion.fromJson(q)).toList();

      final result = QuizLoadResult(
        questions: questions,
        usesPersonalizedQuestions: true,
      );
      _quizCache[cacheKey] = _CachedQuizResult(result, DateTime.now());
      return result;
    } catch (error, stackTrace) {
      AppLogger.error(
        'Quiz API unavailable. Using fallback quiz seed for poi=$poiId',
        error: error,
        stackTrace: stackTrace,
        name: 'QuizRepository',
      );

      final result = QuizLoadResult(
        questions: _fallbackQuestions(poiId),
        usesPersonalizedQuestions: false,
        fallbackNotice:
            'Per un errore del server le domande non sono personalizzate e usano una difficoltà locale specifica.',
        fallbackDifficultyLabel: _fallbackDifficultyLabel,
      );
      _quizCache[cacheKey] = _CachedQuizResult(result, DateTime.now());
      return result;
    }
  }

  List<QuizQuestion> _fallbackQuestions(String poiId) {
    for (final place in HistoricPlacesSeed.items) {
      if (place.id == poiId) {
        return place.questions;
      }
    }

    // Ultimo fallback di sicurezza: restituiamo sempre un set locale valido.
    if (HistoricPlacesSeed.items.isNotEmpty) {
      return HistoricPlacesSeed.items.first.questions;
    }
    return const <QuizQuestion>[];
  }
}

class _CachedQuizResult {
  const _CachedQuizResult(this.result, this.timestamp);

  final QuizLoadResult result;
  final DateTime timestamp;
}
