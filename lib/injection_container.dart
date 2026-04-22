import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import 'data/firebase_auth_repository.dart';
import 'data/offline/offline_map_repository.dart';
import 'data/poi_repository_impl.dart';
import 'data/user_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/i_poi_repository.dart';
import 'domain/repositories/offline_map_repository.dart';
import 'domain/repositories/user_repository.dart';
import 'domain/usecases/auth_use_cases.dart';
import 'domain/usecases/offline_map_use_cases.dart';
import 'domain/usecases/poi_use_cases.dart';
import 'domain/usecases/user_preferences_use_cases.dart';
import 'domain/usecases/user_profile_use_cases.dart';
import 'domain/usecases/user_progress_use_cases.dart';
import 'domain/usecases/user_social_use_cases.dart';
import 'presentation/controllers/social_controller.dart';
import 'presentation/theme/theme_controller.dart';

final sl = GetIt.instance;

Future<void> init() async {
  if (!sl.isRegistered<FirebaseFirestore>()) {
    sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  }

  if (!sl.isRegistered<IOfflineMapRepository>()) {
    final repository = OfflineMapRepository();
    await repository.init();
    sl.registerLazySingleton<IOfflineMapRepository>(() => repository);
  }

  if (!sl.isRegistered<IPoiRepository>()) {
    sl.registerLazySingleton<IPoiRepository>(() => PoiRepositoryImpl());
  }
  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(() => FirebaseAuthRepository());
  }
  if (!sl.isRegistered<IUserRepository>()) {
    sl.registerLazySingleton<IUserRepository>(
      () => UserRepositoryImpl(firestore: sl()),
    );
  }

  if (!sl.isRegistered<GetPoisUseCase>()) {
    sl.registerLazySingleton(() => GetPoisUseCase(sl()));
  }
  if (!sl.isRegistered<OfflineMapUseCases>()) {
    sl.registerLazySingleton(() => OfflineMapUseCases(sl()));
  }
  if (!sl.isRegistered<SignInWithGoogleUseCase>()) {
    sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  }
  if (!sl.isRegistered<SignOutUseCase>()) {
    sl.registerLazySingleton(() => SignOutUseCase(sl()));
  }
  if (!sl.isRegistered<DeleteCurrentUserUseCase>()) {
    sl.registerLazySingleton(() => DeleteCurrentUserUseCase(sl()));
  }
  if (!sl.isRegistered<UserProfileUseCases>()) {
    sl.registerLazySingleton(() => UserProfileUseCases(sl()));
  }
  if (!sl.isRegistered<UserPreferencesUseCases>()) {
    sl.registerLazySingleton(() => UserPreferencesUseCases(sl()));
  }
  if (!sl.isRegistered<UserProgressUseCases>()) {
    sl.registerLazySingleton(() => UserProgressUseCases(sl()));
  }
  if (!sl.isRegistered<UserSocialUseCases>()) {
    sl.registerLazySingleton(() => UserSocialUseCases(sl()));
  }

  if (!sl.isRegistered<ThemeController>()) {
    sl.registerLazySingleton(() => ThemeController(profileUseCases: sl()));
  }

  if (!sl.isRegistered<SocialController>()) {
    sl.registerLazySingleton(
      () => SocialController(
        profileUseCases: sl(),
        progressUseCases: sl(),
        socialUseCases: sl(),
      ),
    );
  }
}
