import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../theme/app_palette.dart';
import '../../../../l10n/app_localizations.dart';

class TourCompletionAnimation extends StatefulWidget {
  final VoidCallback onDismiss;
  final int xpGained;

  const TourCompletionAnimation({
    super.key,
    required this.onDismiss,
    required this.xpGained,
  });

  @override
  State<TourCompletionAnimation> createState() => _TourCompletionAnimationState();
}

class _TourCompletionAnimationState extends State<TourCompletionAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final Animation<double> _backdropOpacity;
  late final Animation<double> _cardScale;
  late final Animation<double> _iconScale;
  late final Animation<double> _contentOpacity;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // 1. Fluid Backdrop Blur Fade-in
    _backdropOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.2)),
    );

    // 2. Main Card Spring Reveal
    _cardScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.1, 0.4, curve: Curves.elasticOut),
      ),
    );

    // 3. Icon Overshoot Spring
    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.5, curve: Curves.elasticOut),
      ),
    );

    // 4. Staggered Content Slide-up
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOutCubic),
      ),
    );
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBuilder(
        animation: _mainController,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // ── 1. LIQUID GLASS BACKDROP ──
              Opacity(
                opacity: _backdropOpacity.value,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.55),
                    ),
                  ),
                ),
              ),

              // ── 2. CENTERED CARD ──
              Center(
                child: Opacity(
                  opacity: _backdropOpacity.value, // fade with backdrop
                  child: Transform.scale(
                    scale: _cardScale.value,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
                        child: Container(
                          width: 320,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 48,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppPalette.olive.withOpacity(0.15),
                                blurRadius: 40,
                                spreadRadius: -10,
                                offset: const Offset(0, 20),
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 1,
                                offset: const Offset(0, -1), // Inner top light
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ── 3. GLOWING ICON ──
                              Transform.scale(
                                scale: _iconScale.value,
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: theme.colorScheme.surface,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppPalette.olive.withOpacity(0.3),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.military_tech_rounded,
                                    size: 64,
                                    color: AppPalette.olive,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // ── 4. STAGGERED TEXT & BUTTON ──
                              SlideTransition(
                                position: _contentSlide,
                                child: Opacity(
                                  opacity: _contentOpacity.value,
                                  child: Column(
                                    children: [
                                      Text(
                                        l10n?.tourCompleted ?? 'Tour Completato',
                                        style: theme.textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -1.0,
                                          height: 1.1,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppPalette.olive.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(99),
                                          border: Border.all(
                                            color: AppPalette.olive.withOpacity(0.2),
                                          ),
                                        ),
                                        child: Text(
                                          l10n?.tourCompletionXpGained(widget.xpGained) ??
                                              '+${widget.xpGained} XP',
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppPalette.olive,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 40),
                                      _MagneticButton(
                                        text: l10n?.buttonClose ?? 'Continua',
                                        onTap: widget.onDismiss,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MagneticButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _MagneticButton({required this.text, required this.onTap});

  @override
  State<_MagneticButton> createState() => _MagneticButtonState();
}

class _MagneticButtonState extends State<_MagneticButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = _isPressed ? 0.96 : (_isHovered ? 1.02 : 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutQuart,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.onSurface.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ]
                  : [],
            ),
            alignment: Alignment.center,
            child: Text(
              widget.text,
              style: TextStyle(
                color: theme.colorScheme.surface,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
