import '../entities/quiz_load_result.dart';
import '../repositories/i_quiz_repository.dart';

class GetPoiQuizUseCase {
  final IQuizRepository repository;

  const GetPoiQuizUseCase(this.repository);

  Future<QuizLoadResult> call(String poiId, String poiName, int userXp) {
    return repository.getQuizForPoi(poiId, poiName, userXp);
  }
}
