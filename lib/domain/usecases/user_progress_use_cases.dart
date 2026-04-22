import '../repositories/user_repository.dart';

class UserProgressUseCases {
  const UserProgressUseCases(this._repository);

  final IUserRepository _repository;

  Stream<List<Map<String, dynamic>>> getLeaderboardStream({int limit = 50}) =>
      _repository.getLeaderboardStream(limit: limit);

  Future<void> registerQuizCompletion({
    required String uid,
    required String poiId,
    required int xpGained,
    required int correctAnswers,
    required int totalQuestions,
    required int tourElapsedSeconds,
  }) => _repository.registerQuizCompletion(
    uid: uid,
    poiId: poiId,
    xpGained: xpGained,
    correctAnswers: correctAnswers,
    totalQuestions: totalQuestions,
    tourElapsedSeconds: tourElapsedSeconds,
  );
}
