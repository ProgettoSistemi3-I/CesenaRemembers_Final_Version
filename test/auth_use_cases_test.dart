import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:cesena_remembers/domain/entities/app_user.dart';
import 'package:cesena_remembers/domain/repositories/auth_repository.dart';
import 'package:cesena_remembers/domain/usecases/auth_use_cases.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<void> deleteCurrentUser() async {}

  @override
  Future<AppUser?> signInWithGoogle() async =>
      const AppUser(uid: 'u1', email: 'test@example.com', displayName: 'T');

  @override
  Future<void> signOut() async {}

  @override
  Stream<AppUser?> get userStream => Stream.value(
    const AppUser(uid: 'u1', email: 'test@example.com', displayName: 'T'),
  );
}

void main() {
  test('SignInWithGoogleUseCase returns authenticated user', () async {
    final useCase = SignInWithGoogleUseCase(_FakeAuthRepository());
    final user = await useCase();
    expect(user, isNotNull);
    expect(user!.uid, 'u1');
  });

  test('SignOutUseCase completes', () async {
    final useCase = SignOutUseCase(_FakeAuthRepository());
    await expectLater(useCase(), completes);
  });
}
