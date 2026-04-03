import 'package:latlong2/latlong.dart';

import '../../data/seeds/historic_places_seed.dart';
import '../../domain/entities/poi.dart';
import '../../domain/entities/tour_stop.dart';

class TourStopMapper {
  const TourStopMapper();

  List<TourStop> fromPois(List<Poi> pois) {
    final metadataById = {
      for (final item in HistoricPlacesSeed.items) item.id: item,
    };

    return pois
        .map((poi) {
          final metadata = metadataById[poi.id];
          if (metadata == null) {
            return null;
          }

          return TourStop(
            id: poi.id,
            name: poi.name,
            period: metadata.period,
            description: metadata.description,
            position: LatLng(poi.latitude, poi.longitude),
            questions: metadata.questions,
          );
        })
        .whereType<TourStop>()
        .toList(growable: false);
  }
}
