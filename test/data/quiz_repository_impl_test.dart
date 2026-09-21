import 'dart:convert';

import 'package:cesena_remembers/data/quiz_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const poiId = 'rocca';
  const poiName = 'Rocca Malatestiana';
  const poiDescription = 'Una fortificazione storica di Cesena.';

  test('uses personalized questions returned by the quiz API', () async {
    final client = MockClient((http.Request request) async {
      expect(request.url.path, '/api/generate-quiz');
      expect(jsonDecode(request.body)['languageCode'], 'it');
      return http.Response(
        jsonEncode({
          'questions': [
            {
              'question': 'Domanda personalizzata?',
              'options': ['Sì', 'No', 'Forse'],
              'correctIndex': 0,
            },
          ],
        }),
        200,
      );
    });
    final repository = QuizRepositoryImpl(
      httpClient: client,
      baseUrl: 'http://quiz.example.test:8000/',
    );

    final result = await repository.getQuizForPoi(
      poiId,
      poiName,
      100,
      languageCode: 'it',
      poiDescription: poiDescription,
    );

    expect(result.usesPersonalizedQuestions, isTrue);
    expect(result.questions.single.question, 'Domanda personalizzata?');
  });

  test('retries the API after a fallback instead of caching local questions', () async {
    var callCount = 0;
    final client = MockClient((_) async {
      callCount++;
      if (callCount == 1) return http.Response('temporary error', 503);
      return http.Response(
        jsonEncode({
          'questions': [
            {
              'question': 'Il server è tornato disponibile?',
              'options': ['Sì', 'No', 'Forse'],
              'correctIndex': 0,
            },
          ],
        }),
        200,
      );
    });
    final repository = QuizRepositoryImpl(
      httpClient: client,
      baseUrl: 'http://quiz.example.test:8000',
    );

    final fallback = await repository.getQuizForPoi(
      poiId,
      poiName,
      100,
      languageCode: 'it',
      poiDescription: poiDescription,
    );
    final recovered = await repository.getQuizForPoi(
      poiId,
      poiName,
      100,
      languageCode: 'it',
      poiDescription: poiDescription,
    );

    expect(fallback.usesPersonalizedQuestions, isFalse);
    expect(recovered.usesPersonalizedQuestions, isTrue);
    expect(recovered.questions.single.question, 'Il server è tornato disponibile?');
    expect(callCount, 2);
  });
}
