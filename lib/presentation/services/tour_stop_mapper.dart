import '../../domain/entities/poi.dart';
import '../../domain/entities/tour_stop.dart';

class TourStopMapper {
  const TourStopMapper();

  List<TourStop> fromPois(List<Poi> pois) {
    return pois
        .map(
          (poi) => TourStop(
            id: poi.id,
            name: poi.name,
            type: poi.type,
            period: poi.period,
            description: poi.description,
            position: GeoPoint(latitude: poi.latitude, longitude: poi.longitude),
            questions: poi.questions,
          ),
        )
        .toList(growable: false);
  }
}
