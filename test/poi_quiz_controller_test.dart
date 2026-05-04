import 'package:flutter_test/flutter_test.dart';

import 'package:cesena_remembers/domain/entities/quiz_load_result.dart';
import 'package:cesena_remembers/domain/entities/quiz_question.dart';
import 'package:cesena_remembers/domain/repositories/i_quiz_repository.dart';
import 'package:cesena_remembers/domain/usecases/get_poi_quiz_usecases.dart';
import 'package:cesena_remembers/presentation/controllers/poi_quiz_controller.dart';

class _FakeQuizRepository implements IQuizRepository {
  _FakeQuizRepository(this.result);

  final QuizLoadResult result;

  @override
  Future<QuizLoadResult> getQuizForPoi(String poiId, String poiName, int userXP) async {
    return result;
  }
}

void main() {
  test('initializes personalized quiz correctly', () async {
    final repo = _FakeQuizRepository(
      const QuizLoadResult(
        questions: [
          QuizQuestion(question: 'Q1', options: ['A', 'B'], correctIndex: 0),
        ],
        usesPersonalizedQuestions: true,
      ),
    );

    final controller = PoiQuizController(
      getQuizUseCase: GetPoiQuizUseCase(repo),
    );

    await controller.initQuiz('p1', 'POI', 30);

    expect(controller.totalQuestions, 1);
    expect(controller.usesPersonalizedQuestions, isTrue);
    expect(controller.fallbackNotice, isNull);
  });

  test('exposes fallback metadata when non-personalized quiz is used', () async {
    final repo = _FakeQuizRepository(
      const QuizLoadResult(
        questions: [
          QuizQuestion(question: 'Q1', options: ['A', 'B'], correctIndex: 1),
        ],
        usesPersonalizedQuestions: false,
        fallbackNotice: 'Server offline, fallback locale',
        fallbackDifficultyLabel: 'Difficoltà standard (seed locale)',
      ),
    );

    final controller = PoiQuizController(
      getQuizUseCase: GetPoiQuizUseCase(repo),
    );

    await controller.initQuiz('p1', 'POI', 30);

    expect(controller.usesPersonalizedQuestions, isFalse);
    expect(controller.fallbackNotice, isNotNull);
    expect(controller.fallbackDifficultyLabel, contains('Difficoltà'));
  });
}
