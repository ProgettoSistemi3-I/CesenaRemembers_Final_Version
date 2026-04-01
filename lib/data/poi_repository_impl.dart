import '../domain/entities/poi.dart';
import '../domain/repositories/i_poi_repository.dart';
import '../models/poi_model.dart';

class PoiRepositoryImpl implements IPoiRepository {
  static List<Poi>? _cachedPois;

  @override
  Future<List<Poi>> getPois() async {
    if (_cachedPois != null) {
      return _cachedPois!;
    }

    // Simula una chiamata di rete o query al DB
    await Future.delayed(const Duration(milliseconds: 500));

    _cachedPois = [
      PoiModel(id: '1', name: 'BlaisePascal', latitude: 44.143043, longitude: 12.253486, type: 'school'),
      PoiModel(id: '2', name: 'Ponte di Ruffio', latitude: 44.150864, longitude: 12.309236, type: 'bridge'),
      PoiModel(id: '3', name: 'Malatestiana', latitude: 44.136194, longitude: 12.239886, type: 'library'),
    ];
    return _cachedPois!;
  }
}
