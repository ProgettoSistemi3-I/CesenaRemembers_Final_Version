import '../domain/entities/poi.dart';
import '../domain/repositories/i_poi_repository.dart';
import '../models/poi_model.dart';
import 'seeds/historic_places_seed.dart';

class PoiRepositoryImpl implements IPoiRepository {
  static final List<PoiModel> _seedPois = HistoricPlacesSeed.items
      .map(
        (item) => PoiModel(
          id: item.id,
          name: item.name,
          latitude: item.latitude,
          longitude: item.longitude,
          type: item.type,
          period: item.period,
          description: item.description,
          questions: item.questions,
        ),
      )
      .toList(growable: false);

  @override
  Future<List<Poi>> getPois() async => List<Poi>.unmodifiable(_seedPois);
}
