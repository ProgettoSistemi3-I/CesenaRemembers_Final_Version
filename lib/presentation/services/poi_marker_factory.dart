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
      width: 160,
      height: 110,
      child: Transform.rotate(
        angle: _degreesToRadians(-counterRotationDegrees),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LiquidGlassPin(
              accentColor: _colorFromType(poi.type),
              icon: _iconFromType(poi.type),
            ),
            const SizedBox(height: 6),
            _LiquidGlassLabel(text: poi.name),
          ],
        ),
      ),
    );
  }

  double _degreesToRadians(double value) => value * (math.pi / 180);

  Color _colorFromType(String type) {
    switch (type.toLowerCase()) {
      case 'church':
        // ANTI-LILA BAN: Sostituito il viola con un Tan architettonico più sobrio
        return AppPalette.tan;
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
        // Neutro elegante di fallback (Zinc-400)
        return const Color(0xFFA1A1AA);
    }
  }

  IconData _iconFromType(String type) {
    // ENFORCEMENT: Utilizzo esclusivo di varianti 'outlined' o a tratto fine
    switch (type.toLowerCase()) {
      case 'church':
        return Icons.church_outlined;
      case 'monument':
        return Icons.account_balance_outlined;
      case 'square':
        return Icons.location_city_outlined;
      case 'school':
        return Icons.school_outlined;
      case 'bridge':
        return Icons.architecture;
      case 'library':
        return Icons.local_library_outlined;
      default:
        return Icons.place_outlined;
    }
  }
}

/// [MOTION_INTENSITY: 6] - Genera un micro-movimento continuo (breathing)
/// per mantenere la mappa viva, utilizzando solo trasformazioni scalari
/// per sfruttare l'accelerazione hardware senza ricalcoli onerosi del layout.
class _LiquidGlassPin extends StatefulWidget {
  final Color accentColor;
  final IconData icon;

  const _LiquidGlassPin({required this.accentColor, required this.icon});

  @override
  State<_LiquidGlassPin> createState() => _LiquidGlassPinState();
}

class _LiquidGlassPinState extends State<_LiquidGlassPin>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Perpetual Loop: breathing effect dolce e organico
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: ClipOval(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Base: Zinc-950 traslucido (NO nero assoluto)
              color: const Color(0xFF09090B).withValues(alpha: 0.65),
              border: Border.all(
                // Rifrazione fisica sui bordi
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.2,
              ),
              boxShadow: [
                // Bagliore di profondità legato all'accent color
                BoxShadow(
                  color: widget.accentColor.withValues(alpha: 0.15),
                  blurRadius: 12,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Center(
              child: Icon(widget.icon, color: widget.accentColor, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

/// [VISUAL_DENSITY: 4] - Etichetta minimalista, font incisivo e contenimento elegante
class _LiquidGlassLabel extends StatelessWidget {
  final String text;

  const _LiquidGlassLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 140),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF09090B).withValues(alpha: 0.75), // Deep Zinc
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFAFAFA), // Zinc-50
              letterSpacing: -0.3, // Typography determinism: tighter tracking
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
