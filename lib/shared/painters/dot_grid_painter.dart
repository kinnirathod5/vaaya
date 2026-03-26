import 'package:flutter/material.dart';

import '../../core/constants/auth_constants.dart';
import '../../core/theme/app_theme.dart';

/// Honeycomb-style dot grid used as a subtle texture in auth backgrounds.
///
/// Reads spacing, radius, opacity and vertical compression from
/// [AuthConstants] so every screen renders the identical pattern.
class DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.brandPrimary
          .withValues(alpha: AuthConstants.dotAlpha)
      ..style = PaintingStyle.fill;

    const s = AuthConstants.dotSpacing;
    final cols = (size.width / s).ceil() + 1;
    final rows = (size.height / s).ceil() + 1;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        canvas.drawCircle(
          Offset(
            c * s + (r.isOdd ? s / 2 : 0),
            r * s * AuthConstants.dotVertFactor,
          ),
          AuthConstants.dotRadius,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(DotGridPainter _) => false;
}