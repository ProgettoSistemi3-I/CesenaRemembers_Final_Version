import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/logging/app_logger.dart';
import '../domain/entities/quiz_load_result.dart';
import '../domain/entities/quiz_question.dart';
import '../domain/repositories/i_quiz_repository.dart';
import 'seeds/historic_places_seed.dart';

class QuizRepositoryImpl implements IQuizRepository {
  static const String _baseUrl = 'https://sharika-matripotestal-ina.ngrok-free.dev';
  static const _fallbackDifficultyLabel = 'quiz_fallback_name';

  @override
  Future<QuizLoadResult> getQuizForPoi(
    String poiId,
    String poiName,
    int userXp,
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
                  'General historical information about $poiName in the city of Cesena.',
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

      return QuizLoadResult(
        questions: questions,
        usesPersonalizedQuestions: true,
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'Quiz API unavailable. Using fallback quiz seed for poi=$poiId',
        error: error,
        stackTrace: stackTrace,
        name: 'QuizRepository',
      );

      return QuizLoadResult(
        questions: _fallbackQuestions(poiId),
        usesPersonalizedQuestions: false,
        fallbackNotice:
            'quiz_fallback_desc',
        fallbackDifficultyLabel: _fallbackDifficultyLabel,
      );
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
