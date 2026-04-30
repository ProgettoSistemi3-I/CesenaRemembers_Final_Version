import '../domain/entities/quiz_question.dart';
import '../domain/repositories/i_quiz_repository.dart';

class QuizRepositoryImpl implements IQuizRepository {
  @override
  Future<List<QuizQuestion>> getQuizForPoi(String poiId, String poiName) async {
    // Quando avrai Docker, qui farai la chiamata HTTP al server
    // e convertirai il JSON in List<QuizQuestion>.
    
    // MOCK TEMPORANEO:
    await Future.delayed(const Duration(seconds: 2));
    return [
      QuizQuestion(
        question: 'Domanda di test generata dal server per: $poiName',
        options: ['Opzione Sbagliata', 'Opzione Corretta', 'Altra Sbagliata'],
        correctIndex: 1,
      ),
      QuizQuestion(
        question: 'Il server Docker è pronto?',
        options: ['Sì', 'Non ancora ma ci stiamo lavorando'],
        correctIndex: 1,
      ),
    ];
  }
}