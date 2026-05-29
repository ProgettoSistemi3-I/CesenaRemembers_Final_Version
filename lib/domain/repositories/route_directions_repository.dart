import '../entities/route_path.dart';
import '../entities/tour_stop.dart';

abstract class RouteDirectionsRepository {
  Future<RoutePath> getWalkingRoute({
    required GeoPoint origin,
    required GeoPoint destination,
  });
}
