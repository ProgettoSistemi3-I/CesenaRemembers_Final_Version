import 'quiz_question.dart';

class Poi {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String type; // es. 'monument', 'bridge', 'school'
  final String period;
  final String description;
  final List<QuizQuestion> questions;

  Poi({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.period,
    required this.description,
    this.questions = const [],
  });
}
