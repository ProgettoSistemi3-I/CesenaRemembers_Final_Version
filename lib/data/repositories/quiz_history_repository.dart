import 'package:cloud_firestore/cloud_firestore.dart';

class QuizHistoryRepository {
  QuizHistoryRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<List<String>> getRecentQuestions({
    required String uid,
    required String poiId,
    int limit = 24,
  }) async {
    final snapshot = await _users.doc(uid).get();
    final data = snapshot.data();
    if (data == null) return const [];

    final history = data['quizQuestionHistory'];
    if (history is! Map<String, dynamic>) return const [];

    final forPoi = history[poiId];
    if (forPoi is! List<dynamic>) return const [];

    final items = forPoi
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    if (items.length <= limit) {
      return items;
    }
    return items.sublist(items.length - limit);
  }

  Future<void> appendQuestions({
    required String uid,
    required String poiId,
    required List<String> questions,
    int maxStored = 60,
  }) async {
    if (questions.isEmpty) return;

    final ref = _users.doc(uid);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final data = snapshot.data() ?? <String, dynamic>{};
      final history = Map<String, dynamic>.from(
        data['quizQuestionHistory'] as Map<String, dynamic>? ?? const {},
      );

      final currentItems = List<String>.from(history[poiId] ?? const <String>[]);
      currentItems.addAll(questions.map(_normalizeQuestion));

      final deduped = <String>[];
      final seen = <String>{};
      for (final item in currentItems) {
        if (seen.add(item)) {
          deduped.add(item);
        }
      }

      final nextItems = deduped.length > maxStored
          ? deduped.sublist(deduped.length - maxStored)
          : deduped;

      history[poiId] = nextItems;

      transaction.set(ref, {
        'quizQuestionHistory': history,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  String _normalizeQuestion(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }
}
