import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/app_runtime_config.dart';
import '../../domain/entities/quiz_question.dart';
import '../../domain/entities/tour_stop.dart';

class GrokQuizService {
  GrokQuizService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static final Uri _endpoint = Uri.parse('https://api.x.ai/v1/chat/completions');

  Future<List<QuizQuestion>> generateQuestions({
    required TourStop stop,
    required int profileLevel,
    required List<String> previousQuestions,
  }) async {
    if (AppRuntimeConfig.grokApiKey.trim().isEmpty) {
      throw const QuizGenerationException('GROK_API_KEY non configurata.');
    }

    final response = await _client.post(
      _endpoint,
      headers: {
        'Authorization': 'Bearer ${AppRuntimeConfig.grokApiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': AppRuntimeConfig.grokModel,
        'temperature': 0.65,
        'max_tokens': 700,
        'response_format': {
          'type': 'json_schema',
          'json_schema': {
            'name': 'quiz_questions',
            'schema': {
              'type': 'object',
              'properties': {
                'questions': {
                  'type': 'array',
                  'minItems': 3,
                  'maxItems': 3,
                  'items': {
                    'type': 'object',
                    'properties': {
                      'question': {'type': 'string'},
                      'options': {
                        'type': 'array',
                        'minItems': 4,
                        'maxItems': 4,
                        'items': {'type': 'string'},
                      },
                      'correctIndex': {
                        'type': 'integer',
                        'minimum': 0,
                        'maximum': 3,
                      },
                    },
                    'required': ['question', 'options', 'correctIndex'],
                    'additionalProperties': false,
                  },
                },
              },
              'required': ['questions'],
              'additionalProperties': false,
            },
          },
        },
        'messages': [
          {
            'role': 'system',
            'content':
                'Genera quiz storici in italiano. Usa solo il contesto fornito. Evita fatti inventati. Risposta JSON valida secondo schema.',
          },
          {
            'role': 'user',
            'content': _buildPrompt(
              stop: stop,
              profileLevel: profileLevel,
              previousQuestions: previousQuestions,
            ),
          },
        ],
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw QuizGenerationException(
        'Errore Grok (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = decoded['choices'] as List<dynamic>?;
    final firstChoice = (choices != null && choices.isNotEmpty) ? choices.first : null;
    final message = (firstChoice as Map<String, dynamic>?)?['message'] as Map<String, dynamic>?;
    final content = message?['content'];
    final contentText = switch (content) {
      String value => value,
      List<dynamic> list => list
          .map((entry) => (entry as Map<String, dynamic>)['text'])
          .whereType<String>()
          .join('\n'),
      _ => null,
    };

    if (contentText == null || contentText.trim().isEmpty) {
      throw const QuizGenerationException('Grok non ha restituito contenuti.');
    }

    final parsed = jsonDecode(contentText) as Map<String, dynamic>;
    final questions = (parsed['questions'] as List<dynamic>)
        .map((item) => _toQuestion(item as Map<String, dynamic>))
        .toList(growable: false);

    if (questions.length != 3) {
      throw QuizGenerationException(
        'Numero domande non valido: ${questions.length}.',
      );
    }

    return questions;
  }

  String _buildPrompt({
    required TourStop stop,
    required int profileLevel,
    required List<String> previousQuestions,
  }) {
    final history = previousQuestions
        .take(18)
        .map((question) => '- $question')
        .join('\n');

    final difficulty = switch (profileLevel) {
      <= 2 => 'facile',
      <= 5 => 'media',
      _ => 'medio-difficile',
    };

    return '''
Crea 3 domande a scelta multipla sul luogo indicato.

Luogo: ${stop.name}
Tipo: ${stop.type}
Periodo: ${stop.period}
Descrizione fonte:
${stop.description}

Vincoli:
- lingua italiana.
- difficoltà: $difficulty (livello profilo=$profileLevel).
- 3 domande totali, ognuna con 4 opzioni.
- una sola risposta corretta per domanda.
- corretIndex da 0 a 3.
- NON ripetere o riformulare troppo domande già usate in passato per questo luogo.
- evita domande ambigue o non verificabili dalla descrizione.

Domande già usate:
${history.isEmpty ? '- nessuna' : history}
''';
  }

  QuizQuestion _toQuestion(Map<String, dynamic> item) {
    final question = (item['question'] as String? ?? '').trim();
    final options = (item['options'] as List<dynamic>? ?? const [])
        .map((option) => option.toString().trim())
        .where((option) => option.isNotEmpty)
        .toList(growable: false);
    final correctIndex = (item['correctIndex'] as num?)?.toInt() ?? -1;

    if (question.isEmpty || options.length != 4 || correctIndex < 0 || correctIndex > 3) {
      throw const QuizGenerationException('Formato domanda non valido da Grok.');
    }

    return QuizQuestion(
      question: question,
      options: options,
      correctIndex: correctIndex,
    );
  }
}

class QuizGenerationException implements Exception {
  const QuizGenerationException(this.message);

  final String message;

  @override
  String toString() => message;
}
