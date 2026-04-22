import '../domain/entities/poi.dart';
import '../domain/entities/quiz_question.dart';

class PoiModel extends Poi {
  PoiModel({
    required super.id,
    required super.name,
    required super.latitude,
    required super.longitude,
    required super.type,
    required super.period,
    required super.description,
    super.questions,
  });

  factory PoiModel.fromJson(Map<String, dynamic> json) {
    return PoiModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      type: json['type'] ?? 'default',
      period: json['period'] ?? '',
      description: json['description'] ?? '',
      questions: (json['questions'] as List<dynamic>? ?? const [])
          .map(
            (question) => QuizQuestion(
              question: question['question'] as String? ?? '',
              options: List<String>.from(question['options'] as List? ?? const []),
              correctIndex: (question['correctIndex'] as num?)?.toInt() ?? 0,
            ),
          )
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
      'period': period,
      'description': description,
      'questions': questions
          .map(
            (question) => {
              'question': question.question,
              'options': question.options,
              'correctIndex': question.correctIndex,
            },
          )
          .toList(growable: false),
    };
  }
}
