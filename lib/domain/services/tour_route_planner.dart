import 'package:latlong2/latlong.dart';

import '../entities/tour_stop.dart';

class TourRoutePlanner {
  const TourRoutePlanner();

  /// Ordina le tappe con l'algoritmo nearest-neighbor (greedy).
  /// Complessità: O(n²) — sufficiente per il numero di POI dell'app.
  /// Rispetto alla versione precedente, si evita il sort O(n log n) ad ogni
  /// iterazione: si cerca semplicemente il minimo in un singolo passaggio lineare.
  List<TourStop> sortNearestNeighbor({
    required GeoPoint origin,
    required List<TourStop> stops,
  }) {
    final remaining = List<TourStop>.from(stops);
    final sorted = <TourStop>[];
    var current = origin;
    const distance = Distance();

    while (remaining.isNotEmpty) {
      var minDist = double.infinity;
      var minIdx = 0;
      for (var i = 0; i < remaining.length; i++) {
        final d = distance.as(
          LengthUnit.Meter,
          _toLatLng(current),
          _toLatLng(remaining[i].position),
        );
        if (d < minDist) {
          minDist = d;
          minIdx = i;
        }
      }
      final next = remaining.removeAt(minIdx);
      sorted.add(next);
      current = next.position;
    }

    return sorted;
  }

  LatLng _toLatLng(GeoPoint point) => LatLng(point.latitude, point.longitude);
}
