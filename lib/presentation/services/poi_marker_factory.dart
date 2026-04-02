import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/poi.dart';
import '../theme/app_palette.dart';

class PoiMarkerFactory {
  const PoiMarkerFactory();

  Marker fromPoi(
    Poi poi, {
    double counterRotationDegrees = 0,
  }) {
    return Marker(
      point: LatLng(poi.latitude, poi.longitude),
      width: 180,
      height: 92,
      child: Transform.rotate(
        angle: _degreesToRadians(-counterRotationDegrees),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemedPoiPin(color: _colorFromType(poi.type)),
            const SizedBox(height: 4),
            _PoiLabel(text: poi.name),
          ],
        ),
      ),
    );
  }

  double _degreesToRadians(double value) => value * (math.pi / 180);

  Color _colorFromType(String type) {
    switch (type) {
      case 'school':
        return AppPalette.tan;
      case 'bridge':
        return AppPalette.olive;
      case 'library':
        return AppPalette.moss;
      default:
        return AppPalette.textMid;
    }
  }
}

class _ThemedPoiPin extends StatelessWidget {
  const _ThemedPoiPin({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: AppPalette.warmWhite, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Icon(
        Icons.place_rounded,
        color: AppPalette.warmWhite,
        size: 20,
      ),
    );
  }
}

class _PoiLabel extends StatelessWidget {
  const _PoiLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 170),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppPalette.warmWhite.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppPalette.tanLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppPalette.textDark,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
