import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/poi.dart';
import '../theme/app_palette.dart';

class PoiMarkerFactory {
  const PoiMarkerFactory();

  Marker fromPoi(Poi poi, {double counterRotationDegrees = 0}) {
    return Marker(
      point: LatLng(poi.latitude, poi.longitude),
      width: 180,
      height: 100,
      child: Transform.rotate(
        angle: _degreesToRadians(-counterRotationDegrees),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemedPoiPin(
              color: _colorFromType(poi.type),
              icon: _iconFromType(poi.type),
            ),
            const SizedBox(height: 4),
            _PoiLabel(text: poi.name),
          ],
        ),
      ),
    );
  }

  double _degreesToRadians(double value) => value * (math.pi / 180);

  Color _colorFromType(String type) {
    switch (type.toLowerCase()) {
      case 'church':
        return const Color(0xFF7B6AA5);
      case 'monument':
        return AppPalette.olive;
      case 'square':
        return AppPalette.tan;
      case 'school':
        return AppPalette.tan;
      case 'bridge':
        return AppPalette.olive;
      case 'library':
        return AppPalette.moss;
      default:
        // Sostituito textMid con olive come fallback di sistema
        return AppPalette.olive;
    }
  }

  IconData _iconFromType(String type) {
    switch (type.toLowerCase()) {
      case 'church':
        return Icons.church_outlined;
      case 'monument':
        return Icons.account_balance_outlined;
      case 'square':
        return Icons.location_city_outlined;
      case 'school':
        return Icons.school;
      case 'bridge':
        return Icons.architecture;
      case 'library':
        return Icons.local_library;
      default:
        return Icons.castle;
    }
  }
}

class _ThemedPoiPin extends StatelessWidget {
  const _ThemedPoiPin({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    const double pinWidth = 40;
    const double pinHeight = 52;

    return SizedBox(
      width: pinWidth,
      height: pinHeight,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          CustomPaint(
            size: const Size(pinWidth, pinHeight),
            painter: _DropPinPainter(color: color),
          ),
          Positioned(
            top: 5,
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropPinPainter extends CustomPainter {
  const _DropPinPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final double w = size.width;
    final double h = size.height;
    final double r = w / 2;
    final double cx = w / 2;
    final double cy = r;

    final path = ui.Path();
    path.addArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      math.pi * 0.75,
      math.pi * 1.5,
    );
    path.lineTo(cx, h);
    path.close();

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(_DropPinPainter oldDelegate) => oldDelegate.color != color;
}

class _PoiLabel extends StatelessWidget {
  const _PoiLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(maxWidth: 170),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.94),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.surfaceContainerHighest,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
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
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.onSurface,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
