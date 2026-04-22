import 'package:flutter/material.dart';

import '../../domain/entities/tour_stop.dart';
import '../theme/app_palette.dart';

class TourStopVisualData {
  const TourStopVisualData({required this.icon, required this.iconBackground});

  final IconData icon;
  final Color iconBackground;
}

class TourStopVisuals {
  const TourStopVisuals();

  TourStopVisualData forStop(TourStop stop) {
    switch (stop.type.toLowerCase()) {
      case 'church':
        return const TourStopVisualData(
          icon: Icons.church_outlined,
          iconBackground: Color(0xFFE1BEE7),
        );
      case 'monument':
        return const TourStopVisualData(
          icon: Icons.castle_outlined,
          iconBackground: Color(0xFFC8E6C9),
        );
      case 'square':
        return const TourStopVisualData(
          icon: Icons.account_balance_outlined,
          iconBackground: Color(0xFFBBDEFB),
        );
      case 'school':
        return const TourStopVisualData(
          icon: Icons.school_outlined,
          iconBackground: Color(0xFFFFECB3),
        );
      case 'bridge':
        return const TourStopVisualData(
          icon: Icons.architecture,
          iconBackground: Color(0xFFD7CCC8),
        );
      case 'library':
        return const TourStopVisualData(
          icon: Icons.local_library_outlined,
          iconBackground: Color(0xFFC5CAE9),
        );
      default:
        return _fallback;
    }
  }

  static const TourStopVisualData _fallback = TourStopVisualData(
    icon: Icons.place_outlined,
    iconBackground: AppPalette.tan,
  );
}
