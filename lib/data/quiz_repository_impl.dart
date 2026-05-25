import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/logging/app_logger.dart';
import '../domain/entities/quiz_load_result.dart';
import '../domain/entities/quiz_question.dart';
import '../domain/repositories/i_quiz_repository.dart';
import 'seeds/historic_places_seed.dart';

class QuizRepositoryImpl implements IQuizRepository {
  QuizRepositoryImpl({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  static const String _defaultBaseUrl = 'https://saggy-film-raven.ngrok-free.dev';
  static const _fallbackDifficultyLabel = 'quiz_fallback_name';
  static const _requestTimeout = Duration(seconds: 12);
  static final Map<String, QuizLoadResult> _memoryCache = <String, QuizLoadResult>{};

  @override
  Future<QuizLoadResult> getQuizForPoi(
    String poiId,
    String poiName,
    int userXp,
  ) async {
    final cacheKey = '$poiId::$userXp';
    final cached = _memoryCache[cacheKey];
    if (cached != null) {
      return cached;
    }

    final baseUrl = const String.fromEnvironment(
      'QUIZ_API_BASE_URL',
      defaultValue: _defaultBaseUrl,
    );

    try {
      final response = await _httpClient
          .post(
            Uri.parse('$baseUrl/api/generate-quiz'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'id': poiId,
              'name': poiName,
              'description':
                  'General historical information about $poiName in the city of Cesena.',
              'userXp': userXp,
            }),
          )
          .timeout(_requestTimeout);

      if (response.statusCode != 200) {
        throw StateError('HTTP ${response.statusCode}');
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> questionsJson = data['questions'] ?? [];
      final questions = questionsJson
          .map((q) => QuizQuestion.fromJson(q))
          .toList();

      final result = QuizLoadResult(
        questions: questions,
        usesPersonalizedQuestions: true,
      );
      _memoryCache[cacheKey] = result;
      return result;
    } catch (error, stackTrace) {
      AppLogger.error(
        'Quiz API unavailable. Using fallback quiz seed for poi=$poiId',
        error: error,
        stackTrace: stackTrace,
        name: 'QuizRepository',
      );

      final fallbackResult = QuizLoadResult(
        questions: _fallbackQuestions(poiId),
        usesPersonalizedQuestions: false,
        fallbackNotice: 'quiz_fallback_desc',
        fallbackDifficultyLabel: _fallbackDifficultyLabel,
      );
      _memoryCache[cacheKey] = fallbackResult;
      return fallbackResult;
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
