import 'package:flutter_test/flutter_test.dart';

import 'package:cesena_remembers/presentation/controllers/social_controller.dart';

void main() {
  test('LeaderboardEntry.fromMap applies defaults', () {
    final entry = LeaderboardEntry.fromMap({'uid': 'u1', 'xp': 10}, 3);

    expect(entry.uid, 'u1');
    expect(entry.displayName, 'Utente');
    expect(entry.avatarId, 'military_tech');
    expect(entry.rank, 3);
  });
}
