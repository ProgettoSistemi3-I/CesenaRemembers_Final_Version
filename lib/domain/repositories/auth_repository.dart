import '../entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get userStream;
  Future<AppUser?> signInWithGoogle();
  Future<void> signOut();
  Future<void> deleteCurrentUser();
}
