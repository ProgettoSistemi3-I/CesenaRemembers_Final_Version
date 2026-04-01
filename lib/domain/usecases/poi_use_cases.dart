import '../entities/poi.dart';
import '../repositories/i_poi_repository.dart';

class GetPoisUseCase {
  final IPoiRepository repository;

  GetPoisUseCase(this.repository);

  Future<List<Poi>> call() => repository.getPois();
}