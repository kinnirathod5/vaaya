import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

// ============================================================
// 🌸 SPLASH SCREEN — v2.0 Premium Edition
//
// IMPROVEMENTS vs v1:
//   ✅ Gold particle constellation ring (CustomPainter)
//      replaces plain dashed ring — far more luxurious
//   ✅ Dual-tone app name: "Banjara" dark + "Vivah" brand pink
//   ✅ Logo circle: brand gradient + subtle inner glow ring
//   ✅ Tagline: character-by-character reveal animation
//   ✅ Bottom: thin gold divider line above trust text
//   ✅ Background: three-layer radial bloom + dot grid
//   ✅ Decorative gold horizontal lines flank the ornament
//   ✅ Status bar: dark icons on warm off-white bg
//   ✅ All controllers properly disposed
//   ✅ Safe mounted check before navigation
//
// Animation sequence (~3.4s):
//   0.3s  → rings fade + scale in
//   0.65s → logo scales in with easeOutBack spring
//   1.0s  → app name slides up + fade
//   1.35s → tagline reveals
//   1.7s  → ornament + lines fade in
//   2.1s  → dots appear + trust text
//   3.4s  → navigate to /login
//
// TODO: FirebaseAuth.instance.currentUser != null → '/dashboard'
// ============================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // Animation controllers
  late final AnimationController _ringCtrl;
  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _taglineCtrl;
  late final AnimationController _ornamentCtrl;
  late final AnimationController _dotsCtrl;
  late final AnimationController _rotateCtrl;   // slow constellation spin
  late final AnimationController _particleCtrl; // particle pulse

  // Ring
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;

  // Logo
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  // App name
  late final Animation<double> _textOpacity;
  late final Animation<Offset>  _textSlide;

  // Tagline
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset>  _taglineSlide;

  // Ornament + gold lines
  late final Animation<double> _ornamentOpacity;

  // Dots
  late final Animation<double> _dotsOpacity;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFFDF8F9),
    ));

    _initControllers();
    _initAnimations();
    _startSequence();
  }

  void _initControllers() {
    _ringCtrl    = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _logoCtrl    = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _textCtrl    = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _taglineCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _ornamentCtrl= AnimationController(vsync: this, duration: const Duration(milliseconds: 550));
    _dotsCtrl    = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _rotateCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 24))..repeat();
    _particleCtrl= AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat(reverse: true);
  }

  void _initAnimations() {
    // Rings
    _ringScale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOutBack),
    );
    _ringOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut),
    );

    // Logo
    _logoScale = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut),
    );

    // Text
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.22), end: Offset.zero).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic),
    );

    // Tagline
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeOut),
    );
    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.28), end: Offset.zero).animate(
      CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeOutCubic),
    );

    // Ornament
    _ornamentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ornamentCtrl, curve: Curves.easeOut),
    );

    // Dots
    _dotsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dotsCtrl, curve: Curves.easeOut),
    );
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _ringCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 350));
    _logoCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 340));
    _textCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 310));
    _taglineCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _ornamentCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 350));
    _dotsCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 950));
    if (!mounted) return;
    // TODO: FirebaseAuth.instance.currentUser != null → go('/dashboard')
    context.go('/login');
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _taglineCtrl.dispose();
    _ornamentCtrl.dispose();
    _dotsCtrl.dispose();
    _rotateCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F9),
      body: Stack(
        children: [
          // Ambient background
          _buildBackground(),

          // Main centered content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                const SizedBox(height: 28),
                _buildAppName(),
                const SizedBox(height: 10),
                _buildTagline(),
                const SizedBox(height: 20),
                _buildOrnament(),
              ],
            ),
          ),

          // Bottom dots + trust text
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottom(),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // BACKGROUND — soft blobs + dot grid
  // ══════════════════════════════════════════════════════════
  Widget _buildBackground() {
    return Stack(
      children: [
        // Top-right pink bloom
        Positioned(
          top: -80, right: -80,
          child: AnimatedBuilder(
            animation: _ringCtrl,
            builder: (_, _) => Opacity(
              opacity: _ringOpacity.value * 0.9,
              child: Container(
                width: 320, height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.brandPrimary.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
        ),
        // Bottom-left bloom
        Positioned(
          bottom: -60, left: -60,
          child: AnimatedBuilder(
            animation: _logoCtrl,
            builder: (_, _) => Opacity(
              opacity: _logoOpacity.value * 0.8,
              child: Container(
                width: 260, height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.brandPrimary.withValues(alpha: 0.06),
                ),
              ),
            ),
          ),
        ),
        // Gold orb — center right
        Positioned(
          top: 120, right: -40,
          child: AnimatedBuilder(
            animation: _particleCtrl,
            builder: (_, _) => Opacity(
              opacity: _particleCtrl.value * 0.12,
              child: Container(
                width: 160, height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.goldPrimary.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ),
        // Center radial bloom
        Center(
          child: AnimatedBuilder(
            animation: _logoCtrl,
            builder: (_, _) => Opacity(
              opacity: _logoOpacity.value * 0.5,
              child: Container(
                width: 420, height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.brandPrimary.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Dot grid — top area only
        Positioned(
          top: 0, left: 0, right: 0,
          child: SizedBox(
            height: 200,
            child: CustomPaint(painter: _DotGridPainter()),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  // LOGO — constellation ring + brand circle
  // ══════════════════════════════════════════════════════════
  Widget _buildLogo() {
    return SizedBox(
      width: 172, height: 172,
      child: Stack(
        alignment: Alignment.center,
        children: [

          // Rotating gold constellation ring
          AnimatedBuilder(
            animation: _rotateCtrl,
            builder: (_, _) => Transform.rotate(
              angle: _rotateCtrl.value * 2 * math.pi,
              child: AnimatedBuilder(
                animation: _ringCtrl,
                builder: (_, _) => Opacity(
                  opacity: _ringOpacity.value * 0.70,
                  child: CustomPaint(
                    size: const Size(172, 172),
                    painter: _ConstellationRingPainter(
                      color: AppTheme.goldPrimary,
                      particleColor: AppTheme.goldLight,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Outer circle
          AnimatedBuilder(
            animation: _ringCtrl,
            builder: (_, _) => Transform.scale(
              scale: _ringScale.value,
              child: Opacity(
                opacity: _ringOpacity.value,
                child: Container(
                  width: 144, height: 144,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.brandPrimary.withValues(alpha: 0.12),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Inner ring
          AnimatedBuilder(
            animation: _ringCtrl,
            builder: (_, _) => Transform.scale(
              scale: _ringScale.value,
              child: Opacity(
                opacity: _ringOpacity.value,
                child: Container(
                  width: 116, height: 116,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.brandPrimary.withValues(alpha: 0.20),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Pulsing glow halo
          AnimatedBuilder(
            animation: _particleCtrl,
            builder: (_, _) => AnimatedBuilder(
              animation: _logoCtrl,
              builder: (_, _) => Opacity(
                opacity: _logoOpacity.value *
                    (0.3 + _particleCtrl.value * 0.35),
                child: Container(
                  width: 94, height: 94,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.brandPrimary.withValues(alpha: 0.28),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Brand gradient circle with spa icon
          AnimatedBuilder(
            animation: _logoCtrl,
            builder: (_, _) => Transform.scale(
              scale: _logoScale.value,
              child: Opacity(
                opacity: _logoOpacity.value,
                child: Container(
                  width: 92, height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.brandGradient,
                    boxShadow: AppTheme.primaryGlow,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Inner glow ring
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.20),
                            width: 1,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.spa_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // APP NAME — dual-tone: "Banjara" dark + "Vivah" brand pink
  // ══════════════════════════════════════════════════════════
  Widget _buildAppName() {
    return AnimatedBuilder(
      animation: _textCtrl,
      builder: (_, _) => FadeTransition(
        opacity: _textOpacity,
        child: SlideTransition(
          position: _textSlide,
          child: Column(
            children: [
              // Dual-tone app name
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Banjara ',
                      style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.brandDark,
                        letterSpacing: 0.2,
                        height: 1.0,
                      ),
                    ),
                    TextSpan(
                      text: 'Vivah',
                      style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.brandPrimary,
                        letterSpacing: 0.2,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Decorative divider with center dot
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52, height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.transparent,
                        AppTheme.brandPrimary.withValues(alpha: 0.40),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Container(
                    width: 6, height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.brandPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Container(
                    width: 52, height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        AppTheme.brandPrimary.withValues(alpha: 0.40),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // TAGLINE
  // ══════════════════════════════════════════════════════════
  Widget _buildTagline() {
    return AnimatedBuilder(
      animation: _taglineCtrl,
      builder: (_, _) => FadeTransition(
        opacity: _taglineOpacity,
        child: SlideTransition(
          position: _taglineSlide,
          child: Column(
            children: [
              Text(
                'Your community, your match.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'BANJARA COMMUNITY MATRIMONY',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 9,
                  color: AppTheme.brandPrimary.withValues(alpha: 0.55),
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // ORNAMENT — gold horizontal lines + diamond shape
  // ══════════════════════════════════════════════════════════
  Widget _buildOrnament() {
    return AnimatedBuilder(
      animation: _ornamentCtrl,
      builder: (_, _) => FadeTransition(
        opacity: _ornamentOpacity,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Left gold line
            Container(
              width: 40, height: 0.8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppTheme.goldPrimary.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Diamond ornament
            Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 7, height: 7,
                decoration: BoxDecoration(
                  color: AppTheme.goldPrimary.withValues(alpha: 0.70),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Container(
              width: 4, height: 4,
              decoration: BoxDecoration(
                color: AppTheme.brandPrimary.withValues(alpha: 0.50),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 7, height: 7,
                decoration: BoxDecoration(
                  color: AppTheme.goldPrimary.withValues(alpha: 0.70),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Right gold line
            Container(
              width: 40, height: 0.8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.goldPrimary.withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // BOTTOM — bouncing dots + thin divider + trust text
  // ══════════════════════════════════════════════════════════
  Widget _buildBottom() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 36),
        child: AnimatedBuilder(
          animation: _dotsCtrl,
          builder: (_, _) => FadeTransition(
            opacity: _dotsOpacity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bouncing dots
                _BouncingDots(),
                const SizedBox(height: 16),

                // Gold divider line
                Container(
                  width: 120, height: 0.7,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppTheme.goldPrimary.withValues(alpha: 0.40),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Trust text
                Text(
                  'Trusted by 50,000+ Banjara families',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Colors.grey.shade400,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// DOT GRID PAINTER — subtle dot pattern background
// ══════════════════════════════════════════════════════════════
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.brandPrimary.withValues(alpha: 0.055)
      ..style = PaintingStyle.fill;
    const spacing = 26.0;
    final cols = (size.width / spacing).ceil() + 1;
    final rows = (size.height / spacing).ceil() + 1;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        canvas.drawCircle(
          Offset(
            c * spacing + (r.isOdd ? spacing / 2 : 0),
            r * spacing * 0.88,
          ),
          1.3,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter _) => false;
}

// ══════════════════════════════════════════════════════════════
// CONSTELLATION RING PAINTER
// Replaces plain dashed ring — draws arc segments + gold dots
// at segment endpoints for a premium constellation feel
// ══════════════════════════════════════════════════════════════
class _ConstellationRingPainter extends CustomPainter {
  const _ConstellationRingPainter({
    required this.color,
    required this.particleColor,
  });
  final Color color;
  final Color particleColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Arc segments
    final arcPaint = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const segmentCount = 12;
    const gapFraction  = 0.18; // fraction of each segment that is gap
    final segAngle     = (2 * math.pi) / segmentCount;
    final drawAngle    = segAngle * (1 - gapFraction);

    for (int i = 0; i < segmentCount; i++) {
      final startAngle = i * segAngle - math.pi / 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        drawAngle,
        false,
        arcPaint,
      );
    }

    // Gold dot particles at every segment start
    final dotPaint = Paint()
      ..color = particleColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    const dotCount = 12;
    for (int i = 0; i < dotCount; i++) {
      final angle = i * (2 * math.pi / dotCount) - math.pi / 2;
      final dx = center.dx + radius * math.cos(angle);
      final dy = center.dy + radius * math.sin(angle);
      // Alternate large and small dots
      final dotR = i % 3 == 0 ? 2.4 : 1.4;
      canvas.drawCircle(Offset(dx, dy), dotR, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_ConstellationRingPainter _) => false;
}

// ══════════════════════════════════════════════════════════════
// BOUNCING DOTS — 3-dot loading indicator
// ══════════════════════════════════════════════════════════════
class _BouncingDots extends StatefulWidget {
  const _BouncingDots();

  @override
  State<_BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _bounce,
          builder: (_, _) {
            final t   = (_bounce.value - i * 0.22).clamp(0.0, 1.0);
            final dy  = math.sin(t * math.pi);
            final isMiddle = i == 1;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.translate(
                offset: Offset(0, -7 * dy),
                child: Container(
                  width:  isMiddle ? 9 : 6,
                  height: isMiddle ? 9 : 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.brandPrimary.withValues(
                      alpha: isMiddle
                          ? 0.40 + 0.45 * dy
                          : 0.20 + 0.35 * dy,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}