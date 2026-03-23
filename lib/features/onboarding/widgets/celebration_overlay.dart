import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

// ============================================================
// 🎉 CELEBRATION OVERLAY
// Confetti + welcome card — shown on final step completion
// Auto-navigates after 2.6s (handled by parent screen)
// ============================================================
class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({super.key, required this.firstName});
  final String firstName;

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with TickerProviderStateMixin {

  late final AnimationController _fadeCtrl;
  late final AnimationController _scaleCtrl;
  late final AnimationController _confettiCtrl;

  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  final _rng = math.Random();
  late final List<_Particle> _particles;

  static const _colors = [
    Color(0xFFE8395A), Color(0xFFF5C842), Color(0xFF16A34A),
    Color(0xFF7C3AED), Color(0xFF2563EB), Color(0xFFFF6B84),
  ];

  @override
  void initState() {
    super.initState();

    _particles = List.generate(55, (_) => _Particle(
      x: _rng.nextDouble(),
      delay: _rng.nextDouble() * 0.5,
      color: _colors[_rng.nextInt(_colors.length)],
      size: 5 + _rng.nextDouble() * 7,
      rotation: _rng.nextDouble() * 2 * math.pi,
      isCircle: _rng.nextBool(),
    ));

    _fadeCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 350));
    _scaleCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 550));
    _confettiCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 2600));

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
        CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOutBack));

    _fadeCtrl.forward();
    _scaleCtrl.forward();
    _confettiCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scaleCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        color: Colors.black.withValues(alpha: 0.60),
        child: Stack(
          children: [
            // Confetti
            AnimatedBuilder(
              animation: _confettiCtrl,
              builder: (_, __) => CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _ConfettiPainter(
                    particles: _particles, progress: _confettiCtrl.value),
              ),
            ),

            // Card
            Center(
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 36),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(
                      color: Colors.black.withValues(alpha: 0.20),
                      blurRadius: 36, offset: const Offset(0, 14),
                    )],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72, height: 72,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFFC9962A), Color(0xFFF5C842)],
                          ),
                        ),
                        child: const Icon(Icons.workspace_premium_rounded,
                            color: Colors.white, size: 34),
                      ),
                      const SizedBox(height: 18),

                      Text(
                        widget.firstName.isNotEmpty
                            ? 'Welcome, ${widget.firstName}! 🎉'
                            : 'Welcome! 🎉',
                        style: const TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 26, fontWeight: FontWeight.w700,
                          color: AppTheme.brandDark,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'Your profile is ready.\nStep into the VIP Lounge.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins', fontSize: 13,
                          color: Colors.grey.shade500, height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 18),

                      const LinearProgressIndicator(
                        backgroundColor: Color(0xFFF0F0F0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.brandPrimary),
                        minHeight: 3,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Particle {
  const _Particle({
    required this.x, required this.delay, required this.color,
    required this.size, required this.rotation, required this.isCircle,
  });
  final double x, delay, size, rotation;
  final Color color;
  final bool isCircle;
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({required this.particles, required this.progress});
  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = ((progress - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final opacity = t < 0.75 ? 1.0 : (1.0 - t) / 0.25;
      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;
      canvas.save();
      canvas.translate(p.x * size.width, t * size.height * 1.1);
      canvas.rotate(p.rotation + t * 3.5);
      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(Rect.fromCenter(
            center: Offset.zero, width: p.size, height: p.size * 0.45), paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}