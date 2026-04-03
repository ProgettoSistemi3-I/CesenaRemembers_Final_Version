import 'package:latlong2/latlong.dart';

import 'quiz_question.dart';

class TourStop {
  final String id;
  final String name;
  final String period;
  final String description;
  final LatLng position;
  final List<QuizQuestion> questions;

  const TourStop({
    required this.id,
    required this.name,
    required this.period,
    required this.description,
    required this.position,
    required this.questions,
  });
}
