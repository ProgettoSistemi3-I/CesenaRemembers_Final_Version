class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  // NUOVO: Questo costruttore "fabbrica" un oggetto partendo dal JSON del server
  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] ?? '',
      // Mappiamo la lista generica dal JSON in una lista di Stringhe Dart
      options: List<String>.from(json['options'] ?? []),
      correctIndex: json['correctIndex'] ?? 0,
    );
  }
}
