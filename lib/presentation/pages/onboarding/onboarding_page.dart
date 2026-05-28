import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_palette.dart';
import '../../../l10n/app_localizations.dart';
import '../../../injection_container.dart';
import '../../../domain/usecases/user_profile_use_cases.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  OnboardingPage — mostrata UNA SOLA VOLTA al primo accesso
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.uid});
  final String uid;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  int _page = 0;
  bool _completing = false;

  late final AnimationController _bgCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4400),
  )..repeat(reverse: true);

  late final AnimationController _floatCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);

  late final AnimationController _pulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  late AnimationController _staggerCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 540),
  )..forward();

  late Animation<double> _tagAnim;
  late Animation<double> _titleAnim;
  late Animation<double> _descAnim;

  @override
  void initState() {
    super.initState();
    _buildStagger();
  }

  void _buildStagger() {
    _tagAnim = CurvedAnimation(
      parent: _staggerCtrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
    );
    _titleAnim = CurvedAnimation(
      parent: _staggerCtrl,
      curve: const Interval(0.18, 0.72, curve: Curves.easeOutCubic),
    );
    _descAnim = CurvedAnimation(
      parent: _staggerCtrl,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
    );
  }

  Future<void> _goTo(int index) async {
    final l10n = AppLocalizations.of(context)!;
    final slides = _buildSlides(l10n);
    if (index >= slides.length) {
      await _complete();
      return;
    }
    setState(() => _page = index);
    _staggerCtrl.dispose();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 540),
    )..forward();
    _buildStagger();
  }

  Future<void> _complete() async {
    if (_completing) return;
    setState(() => _completing = true);
    try {
      await sl<UserProfileUseCases>().markOnboardingCompleted(widget.uid);
    } catch (_) {
      setState(() => _completing = false);
    }
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _floatCtrl.dispose();
    _pulseCtrl.dispose();
    _staggerCtrl.dispose();
    super.dispose();
  }

  List<_SlideData> _buildSlides(AppLocalizations l10n) => [
    _SlideData(
      tag: l10n.onboardingSlide0Tag,
      title: l10n.onboardingSlide0Title,
      description: l10n.onboardingSlide0Desc,
      accent: AppPalette.olive,
      visualType: _VisualType.welcome,
    ),
    _SlideData(
      tag: l10n.onboardingSlide1Tag,
      title: l10n.onboardingSlide1Title,
      description: l10n.onboardingSlide1Desc,
      accent: AppPalette.moss,
      visualType: _VisualType.tour,
    ),
    _SlideData(
      tag: l10n.onboardingSlide2Tag,
      title: l10n.onboardingSlide2Title,
      description: l10n.onboardingSlide2Desc,
      accent: AppPalette.tan,
      visualType: _VisualType.quiz,
    ),
    _SlideData(
      tag: l10n.onboardingSlide3Tag,
      title: l10n.onboardingSlide3Title,
      description: l10n.onboardingSlide3Desc,
      accent: AppPalette.olive,
      visualType: _VisualType.leaderboard,
    ),
    _SlideData(
      tag: l10n.onboardingSlide4Tag,
      title: l10n.onboardingSlide4Title,
      description: l10n.onboardingSlide4Desc,
      accent: AppPalette.tan,
      visualType: _VisualType.achievements,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final slides = _buildSlides(l10n);
    final slide = slides[_page];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0C0F0D)
          : const Color(0xFFF5F1EB),
      body: Stack(
        children: [
          _AnimatedBackground(ctrl: _bgCtrl, slide: _page, isDark: isDark),
          SafeArea(
            child: Column(
              children: [
                // Skip row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_page < slides.length - 1)
                        GestureDetector(
                          onTap: _completing ? null : _complete,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              l10n.onboardingSkip,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.40)
                                    : Colors.black.withValues(alpha: 0.30),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Visual area
                Expanded(
                  flex: 58,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: _buildVisual(slide, isDark, key: ValueKey(_page)),
                  ),
                ),

                // Glass bottom panel
                _GlassBottomPanel(
                  slide: slide,
                  page: _page,
                  total: slides.length,
                  isDark: isDark,
                  tagAnim: _tagAnim,
                  titleAnim: _titleAnim,
                  descAnim: _descAnim,
                  completing: _completing,
                  onNext: () => _goTo(_page + 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisual(_SlideData slide, bool isDark, {required Key key}) {
    switch (slide.visualType) {
      case _VisualType.welcome:
        return _WelcomeVisual(
          key: key,
          floatCtrl: _floatCtrl,
          pulseCtrl: _pulseCtrl,
          isDark: isDark,
        );
      case _VisualType.tour:
        return _PhoneMockupWrapper(
          key: key,
          floatCtrl: _floatCtrl,
          accent: slide.accent,
          isDark: isDark,
          child: _TourMockup(pulseCtrl: _pulseCtrl, isDark: isDark),
        );
      case _VisualType.quiz:
        return _PhoneMockupWrapper(
          key: key,
          floatCtrl: _floatCtrl,
          accent: slide.accent,
          isDark: isDark,
          child: _QuizMockup(isDark: isDark),
        );
      case _VisualType.leaderboard:
        return _PhoneMockupWrapper(
          key: key,
          floatCtrl: _floatCtrl,
          accent: slide.accent,
          isDark: isDark,
          child: _LeaderboardMockup(isDark: isDark),
        );
      case _VisualType.achievements:
        return _PhoneMockupWrapper(
          key: key,
          floatCtrl: _floatCtrl,
          accent: slide.accent,
          isDark: isDark,
          child: _AchievementsMockup(pulseCtrl: _pulseCtrl, isDark: isDark),
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Data model
// ─────────────────────────────────────────────────────────────────────────────

enum _VisualType { welcome, tour, quiz, leaderboard, achievements }

class _SlideData {
  const _SlideData({
    required this.tag,
    required this.title,
    required this.description,
    required this.accent,
    required this.visualType,
  });
  final String tag;
  final String title;
  final String description;
  final Color accent;
  final _VisualType visualType;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Animated background blobs
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedBackground extends StatelessWidget {
  const _AnimatedBackground({
    required this.ctrl,
    required this.slide,
    required this.isDark,
  });
  final AnimationController ctrl;
  final int slide;
  final bool isDark;

  static const _accents = [
    AppPalette.olive,
    AppPalette.moss,
    AppPalette.tan,
    AppPalette.olive,
    AppPalette.tan,
  ];

  @override
  Widget build(BuildContext context) {
    final accent = _accents[slide];
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, child) {
        final t = ctrl.value;
        return Stack(
          children: [
            Positioned(
              top: -130 + t * 30,
              left: -90 + t * 20,
              child: _Blob(
                size: 360 + t * 40,
                color: accent.withValues(alpha: isDark ? 0.13 : 0.09),
              ),
            ),
            Positioned(
              bottom: -110 + t * 25,
              right: -70 + t * 18,
              child: _Blob(
                size: 310 + t * 50,
                color: AppPalette.tan.withValues(alpha: isDark ? 0.08 : 0.07),
              ),
            ),
            Positioned(
              top: 170 + t * 20,
              left: MediaQuery.of(context).size.width * 0.45,
              child: _Blob(
                size: 200 + t * 30,
                color: AppPalette.moss.withValues(alpha: isDark ? 0.06 : 0.05),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SLIDE 0 — Welcome visual (logo + glow ring)
// ─────────────────────────────────────────────────────────────────────────────

class _WelcomeVisual extends StatelessWidget {
  const _WelcomeVisual({
    super.key,
    required this.floatCtrl,
    required this.pulseCtrl,
    required this.isDark,
  });
  final AnimationController floatCtrl;
  final AnimationController pulseCtrl;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([floatCtrl, pulseCtrl]),
        builder: (_, child) {
          final floatT = floatCtrl.value;
          final pulseT = pulseCtrl.value;
          final floatOffset = math.sin(floatT * math.pi) * 10.0;
          final pulseScale = 0.94 + pulseT * 0.06;
          return Transform.translate(
            offset: Offset(0, -floatOffset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulse ring
                    Transform.scale(
                      scale: pulseScale,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppPalette.olive.withValues(
                            alpha: isDark ? 0.08 : 0.06,
                          ),
                        ),
                      ),
                    ),
                    // Mid ring
                    Container(
                      width: 172,
                      height: 172,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppPalette.olive.withValues(
                          alpha: isDark ? 0.12 : 0.09,
                        ),
                        border: Border.all(
                          color: AppPalette.olive.withValues(
                            alpha: isDark ? 0.22 : 0.18,
                          ),
                          width: 1,
                        ),
                      ),
                    ),
                    // Logo
                    ClipOval(
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        width: 136,
                        height: 136,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  'CESENA REMEMBERS',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3.0,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.55)
                        : const Color(0xFF3A3A3A).withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Phone mockup wrapper (float animation + glass frame)
// ─────────────────────────────────────────────────────────────────────────────

class _PhoneMockupWrapper extends StatelessWidget {
  const _PhoneMockupWrapper({
    super.key,
    required this.floatCtrl,
    required this.accent,
    required this.isDark,
    required this.child,
  });
  final AnimationController floatCtrl;
  final Color accent;
  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: floatCtrl,
        builder: (_, ch) {
          final t = floatCtrl.value;
          final floatOffset = math.sin(t * math.pi) * 8.0;
          return Transform.translate(
            offset: Offset(0, -floatOffset),
            child: ch,
          );
        },
        child: _PhoneFrame(isDark: isDark, accent: accent, child: child),
      ),
    );
  }
}

class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({
    required this.isDark,
    required this.accent,
    required this.child,
  });
  final bool isDark;
  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 188,
      height: 360,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: isDark ? const Color(0xFF171A18) : Colors.white,
        border: Border.all(
          color: accent.withValues(alpha: isDark ? 0.28 : 0.20),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.18 : 0.12),
            blurRadius: 36,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.5),
        child: Column(
          children: [
            // Status bar notch
            Container(
              height: 28,
              color: isDark ? const Color(0xFF0F1110) : const Color(0xFFF0EDE8),
              child: Center(
                child: Container(
                  width: 60,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.10),
                  ),
                ),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SLIDE 1 — Tour mockup  (mappa + marker teardrop + bottom bar)
// ─────────────────────────────────────────────────────────────────────────────

class _TourMockup extends StatelessWidget {
  const _TourMockup({required this.pulseCtrl, required this.isDark});
  final AnimationController pulseCtrl;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseCtrl,
      builder: (_, child) {
        final pt = pulseCtrl.value;
        return Stack(
          children: [
            // Map background
            Container(
              color: isDark ? const Color(0xFF1B2020) : const Color(0xFFE8F0E4),
            ),
            // Grid lines (street simulation)
            CustomPaint(
              size: Size.infinite,
              painter: _MapGridPainter(isDark: isDark),
            ),
            // Markers
            Positioned(
              left: 60,
              top: 52,
              child: _TearDropMarker(
                color: AppPalette.moss,
                isDark: isDark,
                label: 'Rocca',
                pulse: 0,
              ),
            ),
            Positioned(
              left: 112,
              top: 80,
              child: _TearDropMarker(
                color: AppPalette.tan,
                isDark: isDark,
                label: 'Cattedrale',
                pulse: 0,
              ),
            ),
            Positioned(
              left: 42,
              top: 130,
              child: _TearDropMarker(
                color: AppPalette.olive,
                isDark: isDark,
                label: 'Piazza',
                pulse: pt,
                isActive: true,
              ),
            ),
            Positioned(
              left: 128,
              top: 148,
              child: _TearDropMarker(
                color: AppPalette.moss,
                isDark: isDark,
                label: 'Teatro',
                pulse: 0,
              ),
            ),
            // GPS dot
            Positioned(
              left: 84,
              top: 165,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 28 + pt * 14,
                    height: 28 + pt * 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(
                        0xFF4A90D9,
                      ).withValues(alpha: 0.15 * (1 - pt)),
                    ),
                  ),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF4A90D9),
                    ),
                  ),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Bottom info strip
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.55)
                          : Colors.white.withValues(alpha: 0.85),
                      border: Border(
                        top: BorderSide(
                          color: AppPalette.olive.withValues(alpha: 0.18),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppPalette.olive.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.route_rounded,
                            size: 16,
                            color: AppPalette.olive,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tour Storico',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1C1C1C),
                                ),
                              ),
                              Text(
                                'Tappa 3 di 5 • 12 min',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.50)
                                      : Colors.black.withValues(alpha: 0.45),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppPalette.olive,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Vai',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MapGridPainter extends CustomPainter {
  const _MapGridPainter({required this.isDark});
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06)
      ..strokeWidth = 1;
    // Horizontal roads
    for (final y in [55.0, 95.0, 140.0, 190.0, 230.0]) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Vertical roads
    for (final x in [40.0, 80.0, 120.0, 155.0]) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    // Block fills
    final blockPaint = Paint()
      ..color = (isDark ? const Color(0xFF2A3028) : const Color(0xFFD8E4D2))
          .withValues(alpha: 0.5);
    canvas.drawRect(const Rect.fromLTWH(42, 57, 36, 36), blockPaint);
    canvas.drawRect(const Rect.fromLTWH(82, 57, 36, 36), blockPaint);
    canvas.drawRect(const Rect.fromLTWH(42, 97, 36, 41), blockPaint);
    canvas.drawRect(const Rect.fromLTWH(122, 97, 31, 41), blockPaint);
  }

  @override
  bool shouldRepaint(_MapGridPainter old) => old.isDark != isDark;
}

class _TearDropMarker extends StatelessWidget {
  const _TearDropMarker({
    required this.color,
    required this.isDark,
    required this.label,
    required this.pulse,
    this.isActive = false,
  });
  final Color color;
  final bool isDark;
  final String label;
  final double pulse;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isActive)
          Container(
            width: 24 + pulse * 12,
            height: 24 + pulse * 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.20 * (1 - pulse)),
            ),
          ),
        Container(
          width: 18,
          height: 22,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(9),
              topRight: Radius.circular(9),
              bottomLeft: Radius.circular(1),
              bottomRight: Radius.circular(1),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            Icons.location_on_rounded,
            size: 10,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        // Label
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: 0.55)
                : Colors.white.withValues(alpha: 0.80),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 6.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1C1C1C),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SLIDE 2 — Quiz mockup
// ─────────────────────────────────────────────────────────────────────────────

class _QuizMockup extends StatelessWidget {
  const _QuizMockup({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? const Color(0xFF0F1110) : const Color(0xFFF7F3EE),
      child: Column(
        children: [
          // Map thumbnail top
          Expanded(
            flex: 2,
            child: Container(
              color: isDark ? const Color(0xFF1B2020) : const Color(0xFFE8F0E4),
              child: Center(
                child: Icon(
                  Icons.map_rounded,
                  size: 28,
                  color: AppPalette.moss.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
          // Bottom sheet quiz
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF171A18) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 28,
                    height: 3,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: 0.6,
                    minHeight: 3,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.10)
                        : Colors.black.withValues(alpha: 0.08),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppPalette.olive,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Question
                Text(
                  'In quale anno fu costruita\nla Rocca Malatestiana?',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.92)
                        : const Color(0xFF1C1C1C),
                  ),
                ),
                const SizedBox(height: 8),
                // Answers
                _QuizOption(
                  text: '1350',
                  isDark: isDark,
                  state: _OptionState.normal,
                ),
                _QuizOption(
                  text: '1377',
                  isDark: isDark,
                  state: _OptionState.correct,
                ),
                _QuizOption(
                  text: '1412',
                  isDark: isDark,
                  state: _OptionState.normal,
                ),
                _QuizOption(
                  text: '1290',
                  isDark: isDark,
                  state: _OptionState.normal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _OptionState { normal, correct, wrong }

class _QuizOption extends StatelessWidget {
  const _QuizOption({
    required this.text,
    required this.isDark,
    required this.state,
  });
  final String text;
  final bool isDark;
  final _OptionState state;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color textColor;
    Widget? trailing;

    if (state == _OptionState.correct) {
      bg = AppPalette.moss.withValues(alpha: 0.15);
      border = AppPalette.moss;
      textColor = AppPalette.moss;
      trailing = const Icon(
        Icons.check_circle_outline,
        size: 10,
        color: AppPalette.moss,
      );
    } else if (state == _OptionState.wrong) {
      bg = AppPalette.danger.withValues(alpha: 0.12);
      border = AppPalette.danger;
      textColor = AppPalette.danger;
      trailing = const Icon(
        Icons.cancel_outlined,
        size: 10,
        color: AppPalette.danger,
      );
    } else {
      bg = isDark
          ? Colors.white.withValues(alpha: 0.04)
          : Colors.black.withValues(alpha: 0.03);
      border = isDark
          ? Colors.white.withValues(alpha: 0.10)
          : Colors.black.withValues(alpha: 0.08);
      textColor = isDark
          ? Colors.white.withValues(alpha: 0.75)
          : const Color(0xFF3A3A3A);
      trailing = null;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SLIDE 3 — Leaderboard mockup
// ─────────────────────────────────────────────────────────────────────────────

class _LeaderboardMockup extends StatelessWidget {
  const _LeaderboardMockup({required this.isDark});
  final bool isDark;

  static const _entries = [
    ('Eleonora V.', 3240),
    ('Marco R.', 2880),
    ('Sofia C.', 2415),
    ('Luca B.', 1990),
    ('Giulia M.', 1650),
  ];

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF0F1110) : const Color(0xFFF7F3EE);
    return Container(
      color: bg,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Row(
              children: [
                Text(
                  'Classifica',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1C1C1C),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.emoji_events_rounded,
                  size: 16,
                  color: AppPalette.tan,
                ),
              ],
            ),
          ),
          // Top 3 podium strip
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PodiumPlace(rank: 2, name: 'Marco', xp: 2880, isDark: isDark),
                _PodiumPlace(
                  rank: 1,
                  name: 'Eleonora',
                  xp: 3240,
                  isDark: isDark,
                  isFirst: true,
                ),
                _PodiumPlace(rank: 3, name: 'Sofia', xp: 2415, isDark: isDark),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // List entries
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (_, i) {
                final e = _entries[i];
                final isTop3 = i < 3;
                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isTop3
                        ? AppPalette.olive.withValues(
                            alpha: isDark ? 0.10 : 0.06,
                          )
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: i == 0
                                ? AppPalette.tan
                                : isDark
                                ? Colors.white.withValues(alpha: 0.45)
                                : Colors.black.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                      CircleAvatar(
                        radius: 9,
                        backgroundColor: AppPalette.olive.withValues(
                          alpha: 0.25,
                        ),
                        child: Text(
                          e.$1[0],
                          style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.w700,
                            color: AppPalette.olive,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          e.$1,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.85)
                                : const Color(0xFF1C1C1C),
                          ),
                        ),
                      ),
                      Text(
                        '${e.$2} XP',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.olive,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumPlace extends StatelessWidget {
  const _PodiumPlace({
    required this.rank,
    required this.name,
    required this.xp,
    required this.isDark,
    this.isFirst = false,
  });
  final int rank;
  final String name;
  final int xp;
  final bool isDark;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final color = rank == 1
        ? AppPalette.tan
        : rank == 2
        ? const Color(0xFF9AABB5)
        : const Color(0xFFB08060);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isFirst) const SizedBox(height: 0) else const SizedBox(height: 10),
        CircleAvatar(
          radius: isFirst ? 18 : 14,
          backgroundColor: color.withValues(alpha: 0.20),
          child: Text(
            name[0],
            style: TextStyle(
              fontSize: isFirst ? 14 : 10,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: TextStyle(
            fontSize: 7.5,
            fontWeight: FontWeight.w600,
            color: isDark
                ? Colors.white.withValues(alpha: 0.8)
                : const Color(0xFF1C1C1C),
          ),
        ),
        Text(
          '$xp XP',
          style: TextStyle(
            fontSize: 7,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SLIDE 4 — Achievements mockup
// ─────────────────────────────────────────────────────────────────────────────

class _AchievementsMockup extends StatelessWidget {
  const _AchievementsMockup({required this.pulseCtrl, required this.isDark});
  final AnimationController pulseCtrl;
  final bool isDark;

  static const _achievements = [
    (Icons.explore_rounded, AppPalette.olive, true, 'Primo passo'),
    (Icons.quiz_rounded, AppPalette.tan, true, 'Prima risposta'),
    (Icons.route_rounded, AppPalette.moss, true, 'Primo tour'),
    (Icons.military_tech_rounded, AppPalette.tan, false, '???'),
    (Icons.emoji_events_rounded, AppPalette.olive, false, '???'),
    (Icons.people_rounded, AppPalette.moss, false, '???'),
    (Icons.speed_rounded, AppPalette.tan, false, '???'),
    (Icons.star_rounded, AppPalette.olive, false, '???'),
    (Icons.workspace_premium_rounded, AppPalette.tan, false, '???'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? const Color(0xFF0F1110) : const Color(0xFFF7F3EE),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Row(
              children: [
                Text(
                  'Achievement',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1C1C1C),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppPalette.olive.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '3 / 9',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.olive,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Grid
          Expanded(
            child: AnimatedBuilder(
              animation: pulseCtrl,
              builder: (_, child) {
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _achievements.length,
                  itemBuilder: (_, i) {
                    final a = _achievements[i];
                    return _AchievementCell(
                      icon: a.$1,
                      color: a.$2,
                      unlocked: a.$3,
                      label: a.$4,
                      isDark: isDark,
                      pulse: i < 3 ? pulseCtrl.value : 0,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCell extends StatelessWidget {
  const _AchievementCell({
    required this.icon,
    required this.color,
    required this.unlocked,
    required this.label,
    required this.isDark,
    required this.pulse,
  });
  final IconData icon;
  final Color color;
  final bool unlocked;
  final String label;
  final bool isDark;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: unlocked
                ? color.withValues(alpha: 0.18 + pulse * 0.06)
                : isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
            border: Border.all(
              color: unlocked
                  ? color.withValues(alpha: 0.45)
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.08)),
              width: 1.2,
            ),
          ),
          child: Icon(
            unlocked ? icon : Icons.lock_rounded,
            size: 20,
            color: unlocked
                ? color
                : (isDark
                      ? Colors.white.withValues(alpha: 0.22)
                      : Colors.black.withValues(alpha: 0.20)),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 6.5,
            fontWeight: unlocked ? FontWeight.w600 : FontWeight.w400,
            color: unlocked
                ? (isDark
                      ? Colors.white.withValues(alpha: 0.85)
                      : const Color(0xFF2A2A2A))
                : (isDark
                      ? Colors.white.withValues(alpha: 0.28)
                      : Colors.black.withValues(alpha: 0.28)),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Glass bottom panel
// ─────────────────────────────────────────────────────────────────────────────

class _GlassBottomPanel extends StatelessWidget {
  const _GlassBottomPanel({
    required this.slide,
    required this.page,
    required this.total,
    required this.isDark,
    required this.tagAnim,
    required this.titleAnim,
    required this.descAnim,
    required this.completing,
    required this.onNext,
  });
  final _SlideData slide;
  final int page;
  final int total;
  final bool isDark;
  final Animation<double> tagAnim;
  final Animation<double> titleAnim;
  final Animation<double> descAnim;
  final bool completing;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isLast = page == total - 1;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.white.withValues(alpha: 0.75),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.white,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: slide.accent.withValues(alpha: isDark ? 0.07 : 0.05),
                blurRadius: 36,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(28, 22, 28, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tag
              FadeTransition(
                opacity: tagAnim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.28),
                    end: Offset.zero,
                  ).animate(tagAnim),
                  child: Text(
                    slide.tag,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                      color: slide.accent.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Title
              FadeTransition(
                opacity: titleAnim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.22),
                    end: Offset.zero,
                  ).animate(titleAnim),
                  child: Text(
                    slide.title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.08,
                      letterSpacing: -0.5,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.95)
                          : const Color(0xFF1C1C1C),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Description
              FadeTransition(
                opacity: descAnim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.20),
                    end: Offset.zero,
                  ).animate(descAnim),
                  child: Text(
                    slide.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.55,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.52)
                          : const Color(0xFF6A6A6A),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Progress segments
              _ProgressSegments(
                page: page,
                total: total,
                accent: slide.accent,
                isDark: isDark,
              ),
              const SizedBox(height: 20),
              // Button
              _NextButton(
                isLast: isLast,
                accent: slide.accent,
                isDark: isDark,
                completing: completing,
                onTap: onNext,
                nextLabel: AppLocalizations.of(context)!.onboardingNext,
                startLabel: AppLocalizations.of(context)!.onboardingStart,
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Progress segments
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressSegments extends StatelessWidget {
  const _ProgressSegments({
    required this.page,
    required this.total,
    required this.accent,
    required this.isDark,
  });
  final int page;
  final int total;
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final isActive = i == page;
        return Expanded(
          flex: isActive ? 3 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.only(right: 5),
            height: 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: isActive
                  ? accent
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.14)
                        : Colors.black.withValues(alpha: 0.10)),
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Next button with press physics
// ─────────────────────────────────────────────────────────────────────────────

class _NextButton extends StatefulWidget {
  const _NextButton({
    required this.isLast,
    required this.accent,
    required this.isDark,
    required this.completing,
    required this.onTap,
    required this.nextLabel,
    required this.startLabel,
  });
  final bool isLast;
  final Color accent;
  final bool isDark;
  final bool completing;
  final VoidCallback onTap;
  final String nextLabel;
  final String startLabel;

  @override
  State<_NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<_NextButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 90),
    reverseDuration: const Duration(milliseconds: 160),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: 0.96,
  ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        if (!widget.completing) widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: widget.accent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.accent.withValues(alpha: 0.28),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: widget.completing
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.isLast ? widget.startLabel : widget.nextLabel,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      widget.isLast
                          ? Icons.explore_rounded
                          : Icons.arrow_forward_rounded,
                      color: Colors.white.withValues(alpha: 0.82),
                      size: 17,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
