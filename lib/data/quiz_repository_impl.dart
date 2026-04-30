import 'dart:convert';
import 'package:http/http.dart' as http;

import '../domain/entities/quiz_question.dart';
import '../domain/repositories/i_quiz_repository.dart';

class QuizRepositoryImpl implements IQuizRepository {
  // TODO: Incolla qui il tuo URL di NGROK (assicurati che NON finisca con la barra '/')
  final String baseUrl = 'https://sharika-matripotestal-ina.ngrok-free.dev';

  @override
  Future<List<QuizQuestion>> getQuizForPoi(String poiId, String poiName) async {
    try {
      // Facciamo la chiamata POST al server Python
      final response = await http.post(
        Uri.parse('$baseUrl/api/generate-quiz'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': poiId,
          'name': poiName,
          // Per ora passiamo una descrizione generica. In futuro potremmo aggiornare
          // l'interfaccia per passare la descrizione reale del POI dalla mappa.
          'description':
              'Informazioni storiche generali su $poiName della città di Cesena.',
        }),
      );

      // Se il server risponde con OK (200)
      if (response.statusCode == 200) {
        // Convertiamo il testo (JSON) in una Mappa Dart
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Estraiamo la lista "questions"
        final List<dynamic> questionsJson = data['questions'];

        // Trasformiamo ogni pezzo del JSON nel tuo oggetto QuizQuestion
        return questionsJson.map((q) => QuizQuestion.fromJson(q)).toList();
      } else {
        throw Exception('Errore dal server: HTTP ${response.statusCode}');
      }
    } catch (e) {
      // FALLBACK DI SICUREZZA: Se ngrok è spento o non c'è internet, non crashiamo!
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
