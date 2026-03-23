import 'package:get_it/get_it.dart';

import 'data/firebase_auth_repository.dart';
import 'data/poi_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/i_poi_repository.dart';
import 'domain/usecases/auth_use_cases.dart';
import 'domain/usecases/poi_use_cases.dart';

final sl = GetIt.instance;

Future<void> init() async {
  if (!sl.isRegistered<IPoiRepository>()) {
    sl.registerLazySingleton<IPoiRepository>(() => PoiRepositoryImpl());
  }
  if (!sl.isRegistered<GetPoisUseCase>()) {
    sl.registerLazySingleton(() => GetPoisUseCase(sl()));
  }

  // Registra i use case
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));

  // Assicurati che il repository usi il nuovo impl
  sl.registerLazySingleton<AuthRepository>(() => FirebaseAuthRepository());
}
