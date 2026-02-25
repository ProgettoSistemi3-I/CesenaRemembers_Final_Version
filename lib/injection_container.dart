import 'package:get_it/get_it.dart';
import 'data/poi_repository_impl.dart';
import 'domain/repositories/i_poi_repository.dart';
import 'domain/usecases/poi_use_cases.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Use Cases
  sl.registerLazySingleton(() => GetPoisUseCase(sl()));

  // Repository
  sl.registerLazySingleton<IPoiRepository>(() => PoiRepositoryImpl());
}





import 'data/repositories/firebase_auth_repository.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/auth_use_cases.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Use Cases
  sl.registerLazySingleton(() => GetPoisUseCase(sl()));
  if (sl.isRegistered<AuthRepository>()) {
    return;
  }

  // Repository
  sl.registerLazySingleton<IPoiRepository>(() => PoiRepositoryImpl());
}
  sl.registerLazySingleton<AuthRepository>(() => FirebaseAuthRepository());

  sl.registerLazySingleton(() => GetPoisUseCase(sl()));
  sl.registerLazySingleton(() => LoginWithEmailUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GoogleLoginUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
}