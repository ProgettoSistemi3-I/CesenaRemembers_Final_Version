import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_palette.dart';

enum GlassSnackType { success, error, info, xp }

/// Mostra una snackbar glassmorphism coerente con il tema dell'app.
/// Dark mode: vetro scuro. Light mode: vetro chiaro.
void showGlassSnackBar(
  BuildContext context, {
  required String message,
  GlassSnackType type = GlassSnackType.info,
  IconData? icon,
  Duration duration = const Duration(seconds: 3),
  EdgeInsetsGeometry? margin,
  VoidCallback? onTap,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  Color accentColor;
  IconData effectiveIcon;
  switch (type) {
    case GlassSnackType.success:
      accentColor = const Color(0xFF7ED957);
      effectiveIcon = icon ?? Icons.check_circle_outline_rounded;
      break;
    case GlassSnackType.error:
      accentColor = AppPalette.danger;
      effectiveIcon = icon ?? Icons.error_outline_rounded;
      break;
    case GlassSnackType.xp:
      accentColor = const Color(0xFFFFC857);
      effectiveIcon = icon ?? Icons.bolt_rounded;
      break;
    case GlassSnackType.info:
      accentColor = AppPalette.moss;
      effectiveIcon = icon ?? Icons.place_rounded;
      break;
  }

  final content = _GlassSnackContent(
    message: message,
    accentColor: accentColor,
    icon: effectiveIcon,
    isDark: isDark,
    isHighlighted:
        type == GlassSnackType.xp || type == GlassSnackType.success,
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        dismissDirection: margin != null
            ? DismissDirection.up
            : DismissDirection.down,
        duration: duration,
        margin: margin ?? const EdgeInsets.fromLTRB(16, 0, 16, 80),
        padding: EdgeInsets.zero,
        content: onTap != null
            ? GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  onTap();
                },
                child: content,
              )
            : content,
      ),
    );
}

class _GlassSnackContent extends StatelessWidget {
  const _GlassSnackContent({
    required this.message,
    required this.accentColor,
    required this.icon,
    required this.isDark,
    required this.isHighlighted,
  });

  final String message;
  final Color accentColor;
  final IconData icon;
  final bool isDark;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: isHighlighted ? 0.72 : 0.58)
                : Colors.white.withValues(alpha: isHighlighted ? 0.82 : 0.65),
            gradient: isHighlighted
                ? LinearGradient(
                    colors: [
                      accentColor.withValues(alpha: isDark ? 0.30 : 0.24),
                      (isDark ? Colors.black : Colors.white).withValues(
                        alpha: isDark ? 0.70 : 0.78,
                      ),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isHighlighted
                  ? accentColor.withValues(alpha: 0.72)
                  : isDark
                  ? Colors.white.withValues(alpha: 0.13)
                  : Colors.white.withValues(alpha: 0.9),
              width: isHighlighted ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(
                  alpha: isHighlighted ? 0.46 : 0.22,
                ),
                blurRadius: isHighlighted ? 28 : 18,
                spreadRadius: isHighlighted ? 1 : 0,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon capsule
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: accentColor.withValues(
                    alpha: isHighlighted
                        ? (isDark ? 0.34 : 0.22)
                        : (isDark ? 0.22 : 0.1),
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor.withValues(
                      alpha: isHighlighted ? 0.72 : (isDark ? 0.5 : 0.28),
                    ),
                    width: isHighlighted ? 1.2 : 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: isHighlighted ? 19 : 17,
                ),
              ),
              const SizedBox(width: 12),
              // Message
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.95)
                        : const Color(0xFF1A1A1A),
                    letterSpacing: 0.1,
                    height: 1.3,
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
