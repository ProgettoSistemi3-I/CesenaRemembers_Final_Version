import '../repositories/auth_repository.dart';

class LoginWithEmailUseCase {
  LoginWithEmailUseCase(this.repository);

  final AuthRepository repository;

  Future<void> call(String email, String password) {
    return repository.signInWithEmail(email, password);
  }
}

class RegisterUseCase {
  RegisterUseCase(this.repository);

  final AuthRepository repository;

  Future<void> call(String email, String password) {
    return repository.register(email, password);
  }
}

class GoogleLoginUseCase {
  GoogleLoginUseCase(this.repository);

  final AuthRepository repository;

  Future<void> call() {
    return repository.signInWithGoogle();
  }
}

class UpdateProfileUseCase {
  UpdateProfileUseCase(this.repository);

  final AuthRepository repository;

  Future<void> call(String name) {
    return repository.updateDisplayName(name);
  }
}

class LogoutUseCase {
  LogoutUseCase(this.repository);

  final AuthRepository repository;

  Future<void> call() {
    return repository.logout();
  }
}

class ResetPasswordUseCase {
  ResetPasswordUseCase(this.repository);

  final AuthRepository repository;

  Future<void> call(String email) {
    return repository.sendPasswordReset(email);
  }
}
