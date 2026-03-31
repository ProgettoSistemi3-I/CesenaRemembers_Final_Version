import 'package:latlong2/latlong.dart';

import '../../domain/entities/tour_stop.dart';

class TourRoutePlanner {
  const TourRoutePlanner();

  List<TourStop> sortNearestNeighbor({
    required LatLng origin,
    required List<TourStop> stops,
  }) {
    final remaining = List<TourStop>.from(stops);
    final sorted = <TourStop>[];
    var current = origin;
    const distance = Distance();

    while (remaining.isNotEmpty) {
      remaining.sort(
        (a, b) => distance
            .as(LengthUnit.Meter, current, a.position)
            .compareTo(distance.as(LengthUnit.Meter, current, b.position)),
      );
      final next = remaining.removeAt(0);
      sorted.add(next);
      current = next.position;
    }

    return sorted;
  }
}
