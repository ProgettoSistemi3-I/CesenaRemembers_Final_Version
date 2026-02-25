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

  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(() => FirebaseAuthRepository());
  }
  if (!sl.isRegistered<LoginWithEmailUseCase>()) {
    sl.registerLazySingleton(() => LoginWithEmailUseCase(sl()));
  }
  if (!sl.isRegistered<RegisterUseCase>()) {
    sl.registerLazySingleton(() => RegisterUseCase(sl()));
  }
  if (!sl.isRegistered<GoogleLoginUseCase>()) {
    sl.registerLazySingleton(() => GoogleLoginUseCase(sl()));
  }
  if (!sl.isRegistered<UpdateProfileUseCase>()) {
    sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  }
  if (!sl.isRegistered<LogoutUseCase>()) {
    sl.registerLazySingleton(() => LogoutUseCase(sl()));
  }
  if (!sl.isRegistered<ResetPasswordUseCase>()) {
    sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  }
}
