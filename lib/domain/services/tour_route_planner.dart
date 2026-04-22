import 'package:latlong2/latlong.dart';

import '../entities/tour_stop.dart';

class TourRoutePlanner {
  const TourRoutePlanner();

  List<TourStop> sortNearestNeighbor({
    required GeoPoint origin,
    required List<TourStop> stops,
  }) {
    final remaining = List<TourStop>.from(stops);
    final sorted = <TourStop>[];
    var current = origin;
    const distance = Distance();

    while (remaining.isNotEmpty) {
      remaining.sort(
        (a, b) => distance
            .as(LengthUnit.Meter, _toLatLng(current), _toLatLng(a.position))
            .compareTo(
              distance.as(LengthUnit.Meter, _toLatLng(current), _toLatLng(b.position)),
            ),
      );
      final next = remaining.removeAt(0);
      sorted.add(next);
      current = next.position;
    }

    return sorted;
  }

  LatLng _toLatLng(GeoPoint point) => LatLng(point.latitude, point.longitude);
}
