import '../entities/quiz_load_result.dart';

abstract class IQuizRepository {
  Future<QuizLoadResult> getQuizForPoi(String poiId, String poiName, int userXP);
}
