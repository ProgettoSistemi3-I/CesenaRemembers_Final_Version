import 'dart:math' as math;
import 'dart:ui' as ui;

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
    VoidCallback? onTap,
  }) {
    return Marker(
      point: LatLng(poi.latitude, poi.longitude),
      width: 170,
      height: 92,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: Transform.rotate(
          angle: _degreesToRadians(-counterRotationDegrees),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PoiPin(
                color: _colorFromType(poi.type),
                icon: _iconFromType(poi.type),
              ),
              const SizedBox(height: 4),
              _PoiLabel(text: poi.name, accentColor: _colorFromType(poi.type)),
            ],
          ),
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
        return const Color(0xFF3D7ABF);
      case 'bridge':
        return const Color(0xFF6B8E77);
      case 'library':
        return AppPalette.moss;
      case 'shelter':
      case 'rifugi':
        return AppPalette.danger;
      default:
        return AppPalette.olive;
    }
  }

  IconData _iconFromType(String type) {
    switch (type.toLowerCase()) {
      case 'church':
        return Icons.church_rounded;
      case 'monument':
        return Icons.account_balance_rounded;
      case 'square':
        return Icons.location_city_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'bridge':
        return Icons.architecture;
      case 'library':
        return Icons.menu_book_rounded;
      case 'shelter':
      case 'rifugi':
        return Icons.security_rounded;
      default:
        return Icons.place_rounded;
    }
  }
}

// ── Minimal teardrop pin ─────────────────────────────────────────────────────

class _PoiPin extends StatelessWidget {
  const _PoiPin({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  static const double _pinW = 40.0;
  static const double _pinH = 52.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _pinW,
      height: _pinH,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: const Size(_pinW, _pinH),
            painter: _PinFillPainter(accentColor: color),
          ),
          Positioned(
            top: 7,
            child: _PinIconCircle(icon: icon, color: color),
          ),
        ],
      ),
    );
  }
}

// ── Icon Circle ───────────────────────────────────────────────────────────────

class _PinIconCircle extends StatelessWidget {
  const _PinIconCircle({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 27,
      height: 27,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: color, width: 1.4),
      ),
      child: Icon(icon, color: color, size: 15),
    );
  }
}

// ── Minimal label ────────────────────────────────────────────────────────────

class _PoiLabel extends StatelessWidget {
  const _PoiLabel({required this.text, required this.accentColor});

  final String text;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: accentColor.withOpacity(0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF232323),
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Painter: clean fill + accent border ──────────────────────────────────────

class _PinFillPainter extends CustomPainter {
  const _PinFillPainter({required this.accentColor});

  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _tearDropPath(size);

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
  }

  @override
  bool shouldRepaint(_PinFillPainter old) => old.accentColor != accentColor;
}

// ── Shared path helper ────────────────────────────────────────────────────────

ui.Path _tearDropPath(Size size) {
  final double r = size.width / 2;
  final double cx = size.width / 2;
  final double cy = r;

  final path = ui.Path();
  path.addArc(
    Rect.fromCircle(center: Offset(cx, cy), radius: r),
    math.pi * 0.75,
    math.pi * 1.5,
  );
  path.lineTo(cx, size.height);
  path.close();
  return path;
}
