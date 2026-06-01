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
      width: 180,
      height: 110,
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
              const SizedBox(height: 5),
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

// ── Teardrop Pin (no BackdropFilter) ─────────────────────────────────────────

class _PoiPin extends StatelessWidget {
  const _PoiPin({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  static const double _pinW = 44.0;
  static const double _pinH = 58.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor = isDark
        ? Color.lerp(Colors.black, color, 0.22)!
        : Color.lerp(Colors.white, color, 0.12)!;

    return SizedBox(
      width: _pinW,
      height: _pinH,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // 1. Solid teardrop fill (replaces BackdropFilter+blur)
          CustomPaint(
            size: const Size(_pinW, _pinH),
            painter: _PinFillPainter(
              fillColor: fillColor,
              accentColor: color,
              isDark: isDark,
            ),
          ),

          // 2. Icon circle
          Positioned(
            top: 8,
            child: _PinIconCircle(icon: icon, color: color, isDark: isDark),
          ),
        ],
      ),
    );
  }
}

// ── Icon Circle ───────────────────────────────────────────────────────────────

class _PinIconCircle extends StatelessWidget {
  const _PinIconCircle({
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(isDark ? 0.30 : 0.18),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.85 : 0.65),
          width: 1.5,
        ),
        // Single subtle shadow — no spread, small blur
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.30),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: isDark ? Colors.white.withOpacity(0.95) : color,
        size: 15,
      ),
    );
  }
}

// ── Label (no BackdropFilter) ─────────────────────────────────────────────────

class _PoiLabel extends StatelessWidget {
  const _PoiLabel({required this.text, required this.accentColor});

  final String text;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      constraints: const BoxConstraints(maxWidth: 155),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        // Solid opaque background — no blur needed
        color: isDark ? const Color(0xDD1A1A2E) : const Color(0xF5FFFFFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.12)
              : accentColor.withOpacity(0.25),
          width: 1,
        ),
        // Single lightweight shadow
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.40 : 0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
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
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? Colors.white.withOpacity(0.95)
                    : const Color(0xFF1A1A1A),
                letterSpacing: 0.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Painter: fills teardrop with solid color + accent border ──────────────────

class _PinFillPainter extends CustomPainter {
  const _PinFillPainter({
    required this.fillColor,
    required this.accentColor,
    required this.isDark,
  });

  final Color fillColor;
  final Color accentColor;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _tearDropPath(size);

    // Solid fill
    canvas.drawPath(
      path,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );

    // Subtle drop shadow (one pass only, small blur)
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withOpacity(0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Accent border
    canvas.drawPath(
      path,
      Paint()
        ..color = accentColor.withOpacity(isDark ? 0.72 : 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Inner highlight line (glass-edge look without blur)
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withOpacity(isDark ? 0.16 : 0.50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  @override
  bool shouldRepaint(_PinFillPainter old) =>
      old.fillColor != fillColor ||
      old.accentColor != accentColor ||
      old.isDark != isDark;
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

class _TearDropClipper extends CustomClipper<ui.Path> {
  const _TearDropClipper(this.width, this.height);
  final double width;
  final double height;

  @override
  ui.Path getClip(Size size) => _tearDropPath(Size(width, height));

  @override
  bool shouldReclip(_TearDropClipper old) =>
      old.width != width || old.height != height;
}
