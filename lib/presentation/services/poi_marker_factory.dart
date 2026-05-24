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
              _GlassPoiPin(
                color: _colorFromType(poi.type),
                icon: _iconFromType(poi.type),
              ),
              const SizedBox(height: 5),
              _GlassPoiLabel(
                text: poi.name,
                accentColor: _colorFromType(poi.type),
              ),
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
        return const Color(0xFF7B6AA5); // soft purple
      case 'monument':
        return AppPalette.olive;
      case 'square':
        return AppPalette.tan;
      case 'school':
        return const Color(0xFF3D7ABF); // steel blue
      case 'bridge':
        return const Color(0xFF6B8E77); // muted sage
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

// ── Glass Teardrop Pin ────────────────────────────────────────────────────────

class _GlassPoiPin extends StatelessWidget {
  const _GlassPoiPin({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  static const double _pinW = 44.0;
  static const double _pinH = 58.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: _pinW,
      height: _pinH,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // 1. Colored glow shadow
          CustomPaint(
            size: const Size(_pinW, _pinH),
            painter: _PinGlowPainter(color: color),
          ),

          // 2. Glass fill — clips to teardrop, blurs the map behind
          ClipPath(
            clipper: const _TearDropClipper(_pinW, _pinH),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                width: _pinW,
                height: _pinH,
                color: isDark
                    ? Colors.black.withOpacity(0.52)
                    : Colors.white.withOpacity(0.48),
              ),
            ),
          ),

          // 3. Accent border + glass refraction highlight
          CustomPaint(
            size: const Size(_pinW, _pinH),
            painter: _PinBorderPainter(color: color, isDark: isDark),
          ),

          // 4. Icon circle
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
        color: color.withOpacity(isDark ? 0.28 : 0.15),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.85 : 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 7,
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

// ── Glass Label ───────────────────────────────────────────────────────────────

class _GlassPoiLabel extends StatelessWidget {
  const _GlassPoiLabel({required this.text, required this.accentColor});

  final String text;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 155),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withOpacity(0.55)
                : Colors.white.withOpacity(0.62),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.13)
                  : Colors.white.withOpacity(0.85),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.14),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Accent dot
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.65),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
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
                    shadows: isDark
                        ? [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 3,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Painters ─────────────────────────────────────────────────────────────────

/// Colored glow + drop shadow beneath the teardrop
class _PinGlowPainter extends CustomPainter {
  const _PinGlowPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _tearDropPath(size);
    // Color glow
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withOpacity(0.38)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );
    // Dark shadow (depth)
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withOpacity(0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  @override
  bool shouldRepaint(_PinGlowPainter old) => old.color != color;
}

/// Accent border + inner glass-edge refraction
class _PinBorderPainter extends CustomPainter {
  const _PinBorderPainter({required this.color, required this.isDark});
  final Color color;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _tearDropPath(size);

    // Outer colored accent border
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withOpacity(isDark ? 0.72 : 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Inner white refraction line (glass edge simulation)
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withOpacity(isDark ? 0.18 : 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  @override
  bool shouldRepaint(_PinBorderPainter old) =>
      old.color != color || old.isDark != isDark;
}

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
