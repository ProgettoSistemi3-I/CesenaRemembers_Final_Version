import 'package:flutter_test/flutter_test.dart';

import 'package:cesena_remembers/domain/validation/profile_validation.dart';

void main() {
  test('valid display name length is accepted', () {
    expect(ProfileValidation.isValidDisplayName('Mario'), isTrue);
  });

  test('too short display name is rejected', () {
    expect(ProfileValidation.isValidDisplayName('A'), isFalse);
  });

  test('username normalization strips invalid chars', () {
    expect(ProfileValidation.normalizeUsername(' Mario!@#_Rossi '), 'mario_rossi');
  });
}
