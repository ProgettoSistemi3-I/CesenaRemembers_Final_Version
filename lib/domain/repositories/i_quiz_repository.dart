import '../entities/quiz_question.dart';

abstract class IQuizRepository {
  Future<List<QuizQuestion>> getQuizForPoi(
    String poiId,
    String poiName,
    int userXP,
  );
}
