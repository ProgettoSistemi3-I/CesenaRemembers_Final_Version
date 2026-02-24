import 'package:get_it/get_it.dart';
import 'data/poi_repository_impl.dart';
import 'domain/repositories/i_poi_repository.dart';
import 'domain/usecases/poi_usecases.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Use Cases
  sl.registerLazySingleton(() => GetPoisUseCase(sl()));

  // Repository
  sl.registerLazySingleton<IPoiRepository>(() => PoiRepositoryImpl());
}