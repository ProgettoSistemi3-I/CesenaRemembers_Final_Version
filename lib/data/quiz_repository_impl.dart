import 'dart:convert';
import 'package:http/http.dart' as http;

import '../domain/entities/quiz_question.dart';
import '../domain/repositories/i_quiz_repository.dart';

class QuizRepositoryImpl implements IQuizRepository {
  // TODO: Incolla qui il tuo URL di NGROK
  final String baseUrl = 'https://sharika-matripotestal-ina.ngrok-free.dev';

  @override
  // NOTA: Ho aggiunto il parametro int userXp
  Future<List<QuizQuestion>> getQuizForPoi(
    String poiId,
    String poiName,
    int userXp,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/generate-quiz'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': poiId,
          'name': poiName,
          'description':
              'Informazioni storiche generali su $poiName della città di Cesena.',
          'userXp': userXp, // Passiamo gli XP dell'utente al backend
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> questionsJson = data['questions'];
        return questionsJson.map((q) => QuizQuestion.fromJson(q)).toList();
      } else {
        throw Exception('Errore dal server: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Errore Quiz API: $e');
      return [
        QuizQuestion(
          question:
              'Connessione al server IA fallita per $poiName. Controlla Ngrok!',
          options: ['Ok, riprovo', 'Server Offline', 'Mannaggia'],
          correctIndex: 0,
        ),
      ];
    }
  }
}
