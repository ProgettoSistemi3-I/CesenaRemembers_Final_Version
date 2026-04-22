import 'quiz_question.dart';

class GeoPoint {
  const GeoPoint({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

class TourStop {
  final String id;
  final String name;
  final String type;
  final String period;
  final String description;
  final GeoPoint position;
  final List<QuizQuestion> questions;

  const TourStop({
    required this.id,
    required this.name,
    required this.type,
    required this.period,
    required this.description,
    required this.position,
    required this.questions,
  });
}
