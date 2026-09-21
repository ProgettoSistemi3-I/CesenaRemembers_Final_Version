import 'dart:io';

import 'package:cesena_remembers/data/poi_repository_impl.dart';
import 'package:cesena_remembers/data/seeds/historic_places_seed.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every seeded POI exposes an existing image asset', () async {
    final pois = await PoiRepositoryImpl().getPois();

    expect(pois, hasLength(HistoricPlacesSeed.items.length));
    for (final poi in pois) {
      final imagePath = poi.imagePath;

      expect(imagePath, isNotNull, reason: '${poi.id} is missing an image path');
      expect(imagePath, isNotEmpty, reason: '${poi.id} has an empty image path');
      expect(
        File(imagePath!).existsSync(),
        isTrue,
        reason: '${poi.id} refers to a missing image asset: $imagePath',
      );
      await expectLater(
        rootBundle.load(imagePath),
        completes,
        reason: '${poi.id} image is not included in the Flutter asset bundle',
      );
    }
  });
}
