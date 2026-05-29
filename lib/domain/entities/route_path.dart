import 'tour_stop.dart';

class RoutePath {
  const RoutePath({required this.points});

  const RoutePath.empty() : points = const [];

  factory RoutePath.straight({
    required GeoPoint origin,
    required GeoPoint destination,
  }) {
    return RoutePath(points: [origin, destination]);
  }

  final List<GeoPoint> points;

  bool get isDrawable => points.length >= 2;
}
