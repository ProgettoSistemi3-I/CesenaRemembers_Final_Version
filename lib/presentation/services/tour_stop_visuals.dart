import 'package:flutter/material.dart';

import '../../data/seeds/historic_places_seed.dart';
import '../../domain/entities/tour_stop.dart';
import '../theme/app_palette.dart';

class TourStopVisualData {
  const TourStopVisualData({required this.icon, required this.iconBackground});

  final IconData icon;
  final Color iconBackground;
}

class TourStopVisuals {
  const TourStopVisuals();

  static final Map<String, TourStopVisualData> _byId = {
    for (final item in HistoricPlacesSeed.items)
      item.id: TourStopVisualData(
        icon: item.icon,
        iconBackground: item.iconBackground,
      ),
  };

  TourStopVisualData forStop(TourStop stop) {
    return _byId[stop.id] ?? _fallback;
  }

  static const TourStopVisualData _fallback = TourStopVisualData(
    icon: Icons.place_outlined,
    iconBackground: AppPalette.tan,
  );
}
