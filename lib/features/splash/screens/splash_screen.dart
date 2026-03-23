import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

// ============================================================
// 🌸 SPLASH SCREEN — Light Warm Theme
//
// Background: warm off-white (#FDF8F9) — matches bgScaffold
// Brand pink (#F23B5F) as the primary visual element
//
// Animation sequence (~3.2s):
//   0.3s — rings fade + scale in
//   0.7s — logo scales in
//   1.1s — app name slides up
//   1.5s — tagline fades in
//   2.0s — dots appear
//   3.2s — navigate to /login
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

  late final AnimationController _ringCtrl;
  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _taglineCtrl;
  late final AnimationController _dotsCtrl;
  late final AnimationController _rotateCtrl;

  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset>  _textSlide;
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset>  _taglineSlide;
  late final Animation<double> _dotsOpacity;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // dark icons on light bg
      systemNavigationBarColor: Color(0xFFFDF8F9),
    ));
    _initControllers();
    _initAnimations();
    _startSequence();
  }

  void _initControllers() {
    _ringCtrl    = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _logoCtrl    = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _textCtrl    = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _taglineCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _dotsCtrl    = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _rotateCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 16))..repeat();
  }

  void _initAnimations() {
    _ringScale = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOutBack));
    _ringOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut));

    _logoScale = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut));

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeOut));
    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeOutCubic));

    _dotsOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _dotsCtrl, curve: Curves.easeOut));
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _ringCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 380));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 340));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 320));
    _taglineCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 320));
    _dotsCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 900));
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
    _dotsCtrl.dispose();
    _rotateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F9), // warm off-white
      body: Stack(
        children: [
          _buildBackground(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                const SizedBox(height: 30),
                _buildAppName(),
                const SizedBox(height: 10),
                _buildTagline(),
              ],
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottom(),
          ),
        ],
      ),
    );
  }

  // ── Background — soft pink blobs on warm white ────────────
  Widget _buildBackground() {
    return Stack(
      children: [
        // Top-right bloom
        Positioned(
          top: -80, right: -80,
          child: AnimatedBuilder(
            animation: _ringCtrl,
            builder: (_, __) => Opacity(
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
            builder: (_, __) => Opacity(
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
        // Center radial — very subtle
        Center(
          child: AnimatedBuilder(
            animation: _logoCtrl,
            builder: (_, __) => Opacity(
              opacity: _logoOpacity.value * 0.5,
              child: Container(
                width: 400, height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.brandPrimary.withValues(alpha: 0.07),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Dot pattern — top area
        Positioned(
          top: 0, left: 0, right: 0,
          child: SizedBox(
            height: 200,
            child: CustomPaint(painter: _DotPatternPainter()),
          ),
        ),
      ],
    );
  }

  // ── Logo ──────────────────────────────────────────────────
  Widget _buildLogo() {
    return SizedBox(
      width: 168, height: 168,
      child: Stack(
        alignment: Alignment.center,
        children: [

          // Slow-rotating dashed ring
          AnimatedBuilder(
            animation: _rotateCtrl,
            builder: (_, __) => Transform.rotate(
              angle: _rotateCtrl.value * 2 * math.pi,
              child: AnimatedBuilder(
                animation: _ringCtrl,
                builder: (_, __) => Opacity(
                  opacity: _ringOpacity.value * 0.25,
                  child: CustomPaint(
                    size: const Size(168, 168),
                    painter: _DashedRingPainter(
                      color: AppTheme.brandPrimary,
                      strokeWidth: 1.2,
                      dashCount: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Outer ring
          AnimatedBuilder(
            animation: _ringCtrl,
            builder: (_, __) => Transform.scale(
              scale: _ringScale.value,
              child: Opacity(
                opacity: _ringOpacity.value,
                child: Container(
                  width: 140, height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.brandPrimary.withValues(alpha: 0.14),
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
            builder: (_, __) => Transform.scale(
              scale: _ringScale.value,
              child: Opacity(
                opacity: _ringOpacity.value,
                child: Container(
                  width: 114, height: 114,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.brandPrimary.withValues(alpha: 0.22),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Soft shadow halo
          AnimatedBuilder(
            animation: _logoCtrl,
            builder: (_, __) => Opacity(
              opacity: _logoOpacity.value * 0.6,
              child: Container(
                width: 92, height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.primaryGlow,
                ),
              ),
            ),
          ),

          // Logo circle
          AnimatedBuilder(
            animation: _logoCtrl,
            builder: (_, __) => Transform.scale(
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
                  child: const Center(
                    child: Icon(
                      Icons.spa_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── App name ──────────────────────────────────────────────
  Widget _buildAppName() {
    return AnimatedBuilder(
      animation: _textCtrl,
      builder: (_, __) => FadeTransition(
        opacity: _textOpacity,
        child: SlideTransition(
          position: _textSlide,
          child: Column(
            children: [
              const Text(
                'Banjara Vivah',
                style: TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.brandDark,
                  letterSpacing: 0.3,
                  height: 1,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48, height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.transparent,
                        AppTheme.brandPrimary.withValues(alpha: 0.45),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                      color: AppTheme.brandPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 48, height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        AppTheme.brandPrimary.withValues(alpha: 0.45),
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

  // ── Tagline ───────────────────────────────────────────────
  Widget _buildTagline() {
    return AnimatedBuilder(
      animation: _taglineCtrl,
      builder: (_, __) => FadeTransition(
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
              const SizedBox(height: 4),
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

  // ── Bottom ────────────────────────────────────────────────
  Widget _buildBottom() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 36),
        child: AnimatedBuilder(
          animation: _dotsCtrl,
          builder: (_, __) => FadeTransition(
            opacity: _dotsOpacity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _BouncingDots(controller: _dotsCtrl),
                const SizedBox(height: 16),
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


// ── Helpers ───────────────────────────────────────────────────

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.brandPrimary.withValues(alpha: 0.055)
      ..style = PaintingStyle.fill;
    const s = 26.0;
    final cols = (size.width / s).ceil() + 1;
    final rows = (size.height / s).ceil() + 1;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        canvas.drawCircle(
          Offset(c * s + (r.isOdd ? s / 2 : 0), r * s * 0.88),
          1.3, paint,
        );
      }
    }
  }
  @override bool shouldRepaint(_DotPatternPainter _) => false;
}

class _DashedRingPainter extends CustomPainter {
  const _DashedRingPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashCount,
  });
  final Color color;
  final double strokeWidth;
  final int dashCount;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth;
    final dashAngle = (2 * math.pi) / dashCount;
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * dashAngle,
        dashAngle * 0.55,
        false,
        paint,
      );
    }
  }
  @override bool shouldRepaint(_DashedRingPainter _) => false;
}

class _BouncingDots extends StatefulWidget {
  const _BouncingDots({required this.controller});
  final AnimationController controller;

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
          builder: (_, __) {
            final t = (_bounce.value - i * 0.22).clamp(0.0, 1.0);
            final dy = math.sin(t * math.pi);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.translate(
                offset: Offset(0, -7 * dy),
                child: Container(
                  width: i == 1 ? 9 : 6,
                  height: i == 1 ? 9 : 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.brandPrimary.withValues(
                      alpha: i == 1
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