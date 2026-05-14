import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import 'data/firebase_auth_repository.dart';
import 'data/poi_repository_impl.dart';
import 'data/user_repository_impl.dart';
import 'data/quiz_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/i_poi_repository.dart';
import 'domain/repositories/user_repository.dart';
import 'domain/repositories/i_quiz_repository.dart';
import 'domain/usecases/auth_use_cases.dart';
import 'domain/usecases/poi_use_cases.dart';
import 'domain/usecases/user_preferences_use_cases.dart';
import 'domain/usecases/user_profile_use_cases.dart';
import 'domain/usecases/user_progress_use_cases.dart';
import 'domain/usecases/user_social_use_cases.dart';
import 'domain/usecases/get_poi_quiz_usecases.dart';
import 'presentation/controllers/social_controller.dart';
import 'presentation/theme/theme_controller.dart';
import 'presentation/controllers/poi_quiz_controller.dart';
// 🔴 IMPORT AGGIUNTO
import 'presentation/controllers/settings_ui_controller.dart'; 

final sl = GetIt.instance;

Future<void> init() async {
  if (!sl.isRegistered<FirebaseFirestore>()) {
    sl.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );
  }

  // --- REPOSITORIES ---
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
  if (!sl.isRegistered<IQuizRepository>()) {
    sl.registerLazySingleton<IQuizRepository>(() => QuizRepositoryImpl());
  }

  // --- USE CASES ---
  if (!sl.isRegistered<GetPoisUseCase>()) {
    sl.registerLazySingleton(() => GetPoisUseCase(sl()));
  }
  if (!sl.isRegistered<GetPoiQuizUseCase>()) {
    sl.registerLazySingleton(() => GetPoiQuizUseCase(sl()));
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

  // --- CONTROLLERS ---
  
  // 1. Prima registriamo il ValueNotifier (perché serve al SettingsUiController)
  if (!sl.isRegistered<ValueNotifier<Locale>>()) {
    sl.registerLazySingleton<ValueNotifier<Locale>>(
      () => ValueNotifier<Locale>(const Locale('it')),
    );
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

  if (!sl.isRegistered<PoiQuizController>()) {
    sl.registerFactory(() => PoiQuizController(getQuizUseCase: sl()));
  }

  // 🔴 2. Ora registriamo il SettingsUiController passandogli sl() (che pescherà in automatico il ValueNotifier)
  if (!sl.isRegistered<SettingsUiController>()) {
    sl.registerLazySingleton(() => SettingsUiController(sl()));
  }
}