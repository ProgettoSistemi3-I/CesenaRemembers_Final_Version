import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../theme/app_palette.dart';
import '../../../../l10n/app_localizations.dart';

class TourCompletionAnimation extends StatefulWidget {
  final VoidCallback onDismiss;

  const TourCompletionAnimation({
    super.key,
    required this.onDismiss,
  });

  @override
  State<TourCompletionAnimation> createState() => _TourCompletionAnimationState();
}

class _TourCompletionAnimationState extends State<TourCompletionAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  
  late final Animation<double> _glassOpacity;
  late final Animation<double> _chestScale;
  late final Animation<double> _chestShake;
  late final Animation<double> _explosionScale;
  late final Animation<double> _particlesOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textOffset;

  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _generateParticles();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    // 1. Fade in glass (0.0 to 0.1)
    _glassOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.1)),
    );

    // 2. Chest drops in with spring (0.1 to 0.35)
    _chestScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.1, 0.35, curve: Curves.elasticOut),
      ),
    );

    // 3. Chest shakes/anticipates (0.35 to 0.6)
    _chestShake = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.05), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.05, end: 0.05), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.05, end: -0.05), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.05, end: 0.05), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.05, end: 0.0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.35, 0.6)),
    );

    // 4. Explosion/Burst (0.6 to 0.8)
    _explosionScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.6, 0.8, curve: Curves.easeOutCirc),
      ),
    );
    _particlesOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.6, 1.0)),
    );

    // 5. Final text reveal (0.7 to 0.9)
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.7, 0.9)),
    );
    _textOffset = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.7, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _mainController.forward();
  }

  void _generateParticles() {
    final colors = [
      AppPalette.olive,
      AppPalette.tan,
      AppPalette.moss,
      Colors.white,
    ];
    for (int i = 0; i < 40; i++) {
      final angle = _random.nextDouble() * 2 * math.pi;
      final distance = 100.0 + _random.nextDouble() * 150.0;
      _particles.add(_Particle(
        color: colors[_random.nextInt(colors.length)],
        angle: angle,
        distance: distance,
        size: 6.0 + _random.nextDouble() * 12.0,
      ));
    }
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
              // 1. Liquid Glass Backdrop
              Opacity(
                opacity: _glassOpacity.value,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.6),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Main Content
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 300,
                      width: 300,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          // Particles explosion
                          ..._particles.map((p) {
                            final currentDistance = p.distance * _explosionScale.value;
                            return Transform.translate(
                              offset: Offset(
                                math.cos(p.angle) * currentDistance,
                                math.sin(p.angle) * currentDistance,
                              ),
                              child: Opacity(
                                opacity: _particlesOpacity.value,
                                child: Transform.rotate(
                                  angle: _explosionScale.value * math.pi * 2,
                                  child: Container(
                                    width: p.size,
                                    height: p.size,
                                    decoration: BoxDecoration(
                                      color: p.color,
                                      shape: _random.nextBool()
                                          ? BoxShape.circle
                                          : BoxShape.rectangle,
                                      borderRadius: _random.nextBool()
                                          ? BorderRadius.circular(2)
                                          : null,
                                      boxShadow: [
                                        BoxShadow(
                                          color: p.color.withOpacity(0.5),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),

                          // The Chest
                          Transform.scale(
                            scale: _chestScale.value,
                            child: Transform.rotate(
                              angle: _chestShake.value,
                              child: Transform.scale(
                                // After explosion, scale down slightly or hide if desired.
                                // We'll make it pop bigger during explosion then settle.
                                scale: 1.0 + (_explosionScale.value * 0.2),
                                child: Container(
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        AppPalette.tan.withOpacity(0.4),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.2, 1.0],
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.redeem_rounded,
                                    size: 120,
                                    color: theme.colorScheme.onSurface,
                                    shadows: [
                                      BoxShadow(
                                        color: AppPalette.olive.withOpacity(0.5),
                                        blurRadius: 24,
                                        spreadRadius: 4,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 3. Text Reveal (Asymmetric & High-End Typography)
                    const SizedBox(height: 32),
                    SlideTransition(
                      position: _textOffset,
                      child: Opacity(
                        opacity: _textOpacity.value,
                        child: Column(
                          children: [
                            Text(
                              l10n?.tourCompleted ?? 'Tour Completed!',
                              style: theme.textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.5,
                                color: theme.colorScheme.onSurface,
                                shadows: [
                                  Shadow(
                                    color: theme.colorScheme.surface,
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '+ XP Gained!',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppPalette.tan,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 48),
                            // Magnetic-feel button (Scale effect on tap)
                            AnimatedScale(
                              scale: 1.0, // Can add hover/active state here if needed
                              duration: const Duration(milliseconds: 150),
                              child: FilledButton.tonal(
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 48,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  backgroundColor: theme.colorScheme.onSurface,
                                  foregroundColor: theme.colorScheme.surface,
                                ),
                                onPressed: widget.onDismiss,
                                child: Text(
                                  l10n?.buttonClose ?? 'Close',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Particle {
  final Color color;
  final double angle;
  final double distance;
  final double size;

  _Particle({
    required this.color,
    required this.angle,
    required this.distance,
    required this.size,
  });
}
