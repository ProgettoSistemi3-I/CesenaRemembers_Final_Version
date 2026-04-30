import '../entities/quiz_question.dart';
import '../repositories/i_quiz_repository.dart';

class GetPoiQuizUseCase {
  final IQuizRepository repository;

  const GetPoiQuizUseCase(this.repository);

  Future<List<QuizQuestion>> call(String poiId, String poiName) async {
    return await repository.getQuizForPoi(poiId, poiName);
  }
}