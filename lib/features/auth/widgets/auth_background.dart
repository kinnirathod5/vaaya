import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// ============================================================
// 🌸 AUTH BACKGROUND — Light Warm Theme
// Warm off-white base + soft brand pink blobs
// Consistent with app's bgScaffold feel
// ============================================================
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Warm off-white base
        Container(color: const Color(0xFFFDF8F9)),

        // Top-right pink bloom
        Positioned(
          top: -100, right: -80,
          child: Container(
            width: 300, height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.brandPrimary.withValues(alpha: 0.08),
            ),
          ),
        ),

        // Mid-left softer bloom
        Positioned(
          top: 160, left: -80,
          child: Container(
            width: 220, height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.brandPrimary.withValues(alpha: 0.05),
            ),
          ),
        ),

        // Subtle dot pattern — top area
        Positioned(
          top: 0, left: 0, right: 0,
          child: SizedBox(
            height: 220,
            child: CustomPaint(painter: _DotPatternPainter()),
          ),
        ),
      ],
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.brandPrimary.withValues(alpha: 0.05)
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