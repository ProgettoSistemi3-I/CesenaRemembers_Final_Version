import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import 'data/firebase_auth_repository.dart';
import 'data/poi_repository_impl.dart';
import 'data/user_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/i_poi_repository.dart';
import 'domain/repositories/user_repository.dart'; // Basato sul tuo import attuale
import 'domain/usecases/auth_use_cases.dart';
import 'domain/usecases/poi_use_cases.dart';
import 'domain/usecases/user_use_cases.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- DIPENDENZE ESTERNE ---
  if (!sl.isRegistered<FirebaseFirestore>()) {
    sl.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );
  }

  // --- REPOSITORY (Dati) ---
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

  // --- USE CASES (Logica) ---
  if (!sl.isRegistered<GetPoisUseCase>()) {
    sl.registerLazySingleton(() => GetPoisUseCase(sl()));
  }
  if (!sl.isRegistered<SignInWithGoogleUseCase>()) {
    sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  }
  if (!sl.isRegistered<SignOutUseCase>()) {
    sl.registerLazySingleton(() => SignOutUseCase(sl()));
  }
  if (!sl.isRegistered<UserUseCases>()) {
    sl.registerLazySingleton(() => UserUseCases(sl()));
  }
}
