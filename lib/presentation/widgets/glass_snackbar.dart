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
      accentColor = AppPalette.olive;
      effectiveIcon = icon ?? Icons.check_circle_outline_rounded;
      break;
    case GlassSnackType.error:
      accentColor = AppPalette.danger;
      effectiveIcon = icon ?? Icons.error_outline_rounded;
      break;
    case GlassSnackType.xp:
      accentColor = AppPalette.tan;
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
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        dismissDirection: margin != null ? DismissDirection.up : DismissDirection.down,
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
  });

  final String message;
  final Color accentColor;
  final IconData icon;
  final bool isDark;

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
                ? Colors.black.withOpacity(0.58)
                : Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.13)
                  : Colors.white.withOpacity(0.9),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.22),
                blurRadius: 18,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.35 : 0.06),
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
                  color: accentColor.withOpacity(isDark ? 0.22 : 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor.withOpacity(isDark ? 0.5 : 0.28),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: accentColor, size: 17),
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
                        ? Colors.white.withOpacity(0.95)
                        : const Color(0xFF1A1A1A),
                    letterSpacing: 0.1,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Accent glow dot
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.65),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
