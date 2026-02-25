import 'package:flutter_test/flutter_test.dart';

import 'package:cesena_remembers/domain/entities/app_user.dart';

void main() {
  test('AppUser stores values correctly', () {
    const user = AppUser(
      id: 'uid-123',
      email: 'utente@example.com',
      displayName: 'Mario Rossi',
    );

    expect(user.id, 'uid-123');
    expect(user.email, 'utente@example.com');
    expect(user.displayName, 'Mario Rossi');
  });
}
