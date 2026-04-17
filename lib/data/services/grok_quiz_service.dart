import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/quiz_question.dart';
import '../../domain/entities/tour_stop.dart';

class GrokQuizService {
  GrokQuizService({
    http.Client? client,
    String? apiKey,
    String? model,
  }) : _client = client ?? http.Client(),
       _apiKey =
           apiKey ??
           const String.fromEnvironment('GROK_API_KEY', defaultValue: ''),
       _model =
           model ??
           const String.fromEnvironment(
             'GROK_MODEL',
             defaultValue: 'grok-3-mini-latest',
           );

  final http.Client _client;
  final String _apiKey;
  final String _model;

  bool get isConfigured => _apiKey.trim().isNotEmpty;

  Future<List<QuizQuestion>> generateQuiz({
    required TourStop stop,
    required int userLevel,
    required List<String> excludedQuestions,
    int questionCount = 3,
  }) async {
    if (!isConfigured) return const [];

    final payload = {
      'model': _model,
      'temperature': 0.7,
      'max_tokens': 700,
      'messages': [
        {
          'role': 'system',
          'content':
              'Sei un autore di quiz storici. Rispondi SOLO con JSON valido.',
        },
        {
          'role': 'user',
          'content': _buildPrompt(
            stop: stop,
            userLevel: userLevel,
            excludedQuestions: excludedQuestions,
            questionCount: questionCount,
          ),
        },
      ],
    };

    try {
      final response = await _client.post(
        Uri.parse('https://api.x.ai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return const [];
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = decoded['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) return const [];

      final message = choices.first['message'] as Map<String, dynamic>?;
      final content = message?['content']?.toString() ?? '';
      if (content.isEmpty) return const [];

      final jsonText = _extractJson(content);
      final parsed = jsonDecode(jsonText) as Map<String, dynamic>;
      final questionsRaw = parsed['questions'] as List<dynamic>?;
      if (questionsRaw == null) return const [];

      final normalizedExclusions = excludedQuestions
          .map(_normalizeQuestionText)
          .toSet();

      final generated = <QuizQuestion>[];
      for (final item in questionsRaw) {
        if (item is! Map<String, dynamic>) continue;
        final question = item['question']?.toString().trim() ?? '';
        final optionsDynamic = item['options'] as List<dynamic>?;
        final correctIndex = (item['correctIndex'] as num?)?.toInt() ?? -1;

        if (question.isEmpty || optionsDynamic == null || optionsDynamic.length != 3) {
          continue;
        }

        final options = optionsDynamic
            .map((option) => option.toString().trim())
            .where((option) => option.isNotEmpty)
            .toList(growable: false);

        if (options.length != 3) continue;
        if (correctIndex < 0 || correctIndex >= options.length) continue;

        final normalizedQuestion = _normalizeQuestionText(question);
        if (normalizedExclusions.contains(normalizedQuestion)) continue;
        if (generated.any(
          (existing) => _normalizeQuestionText(existing.question) == normalizedQuestion,
        )) {
          continue;
        }

        generated.add(
          QuizQuestion(
            question: question,
            options: options,
            correctIndex: correctIndex,
          ),
        );
      }

      return generated;
    } catch (error, stackTrace) {
      debugPrint('GrokQuizService.generateQuiz error: $error\n$stackTrace');
      return const [];
    }
  }

  String _buildPrompt({
    required TourStop stop,
    required int userLevel,
    required List<String> excludedQuestions,
    required int questionCount,
  }) {
    final difficulty = _difficultyFromLevel(userLevel);
    final exclusions = excludedQuestions.take(12).join(' | ');

    return '''
Genera un quiz in italiano con $questionCount domande su questo luogo storico.

LUOGO:
- Nome: ${stop.name}
- Periodo: ${stop.period}
- Descrizione: ${stop.description}

VINCOLI:
- Difficoltà: $difficulty (livello utente $userLevel)
- Ogni domanda deve avere esattamente 3 opzioni
- Solo 1 opzione corretta
- Evita domande già usate (o molto simili): $exclusions
- Le domande devono verificare comprensione storica, non dettagli casuali
- Mantieni testi brevi e chiari per mobile

Output richiesto (SOLO JSON, nessun markdown):
{
  "questions": [
    {
      "question": "...",
      "options": ["...", "...", "..."],
      "correctIndex": 0
    }
  ]
}
''';
  }

  String _extractJson(String content) {
    final trimmed = content.trim();
    if (trimmed.startsWith('{')) return trimmed;

    final start = trimmed.indexOf('{');
    final end = trimmed.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) {
      throw const FormatException('Missing JSON object in model output');
    }
    return trimmed.substring(start, end + 1);
  }

  String _difficultyFromLevel(int level) {
    if (level <= 2) return 'facile';
    if (level <= 5) return 'medio';
    return 'avanzato';
  }

  String _normalizeQuestionText(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }
}
