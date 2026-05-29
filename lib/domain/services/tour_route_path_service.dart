import '../entities/route_path.dart';
import '../entities/tour_stop.dart';
import '../repositories/route_directions_repository.dart';

class TourRoutePathService {
  const TourRoutePathService({required this.directions});

  final RouteDirectionsRepository directions;

  Future<RoutePath> buildCurrentLegPath({
    required GeoPoint origin,
    required TourStop destination,
  }) async {
    try {
      final path = await directions.getWalkingRoute(
        origin: origin,
        destination: destination.position,
      );
      if (path.isDrawable) return path;
    } catch (_) {
      // La mappa deve restare utile anche senza token Mapbox o rete.
    }

    return RoutePath.straight(origin: origin, destination: destination.position);
  }
}
