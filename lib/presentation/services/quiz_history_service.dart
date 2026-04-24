import 'package:cloud_firestore/cloud_firestore.dart';

class QuizHistoryService {
  QuizHistoryService({required FirebaseFirestore firestore}) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<List<String>> getPreviousQuestions({
    required String uid,
    required String stopId,
  }) async {
    final doc = await _users
        .doc(uid)
        .collection('quizQuestionHistory')
        .doc(stopId)
        .get();

    final values = List<String>.from(doc.data()?['questions'] ?? const <String>[]);
    return List.unmodifiable(values);
  }

  Future<void> saveQuestions({
    required String uid,
    required String stopId,
    required List<String> questions,
  }) async {
    if (questions.isEmpty) return;

    final normalized = questions
        .map((question) => question.trim())
        .where((question) => question.isNotEmpty)
        .toList(growable: false);

    if (normalized.isEmpty) return;

    final docRef = _users.doc(uid).collection('quizQuestionHistory').doc(stopId);
    final existingDoc = await docRef.get();
    final existing = List<String>.from(existingDoc.data()?['questions'] ?? const <String>[]);

    final merged = <String>[];
    final seen = <String>{};

    for (final value in [...existing, ...normalized]) {
      final key = _normalize(value);
      if (!seen.add(key)) continue;
      merged.add(value);
    }

    final trimmed = merged.length > 60
        ? merged.sublist(merged.length - 60)
        : merged;

    await docRef.set({
      'questions': trimmed,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String _normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
}
