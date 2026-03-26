import 'package:flutter/material.dart';

import '../../core/constants/auth_constants.dart';
import '../../core/theme/app_theme.dart';
import '../painters/dot_grid_painter.dart';

/// Warm-white background with soft coloured orbs and a dot-grid texture.
///
/// Used on **every** auth screen (login, OTP, future screens).
/// All sizes, positions and opacities are driven by [AuthConstants]
/// so every screen looks identical.
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base warm white
        Container(color: AuthConstants.scaffoldBg),

        // Top-right large bloom
        Positioned(
          top: -120,
          right: -100,
          child: _Orb(
            size: AuthConstants.orbTopRightSize,
            color: AppTheme.brandPrimary
                .withValues(alpha: AuthConstants.orbTopRightAlpha),
          ),
        ),

        // Mid-left secondary bloom
        Positioned(
          top: 180,
          left: -90,
          child: _Orb(
            size: AuthConstants.orbMidLeftSize,
            color: AppTheme.brandPrimary
                .withValues(alpha: AuthConstants.orbMidLeftAlpha),
          ),
        ),

        // Top-left tiny gold accent
        Positioned(
          top: 60,
          left: 20,
          child: _Orb(
            size: AuthConstants.orbTopLeftSize,
            color: AppTheme.goldPrimary
                .withValues(alpha: AuthConstants.orbTopLeftAlpha),
          ),
        ),

        // Bottom-right gold bloom
        Positioned(
          bottom: 120,
          right: -50,
          child: _Orb(
            size: AuthConstants.orbBotRightSize,
            color: AppTheme.goldPrimary
                .withValues(alpha: AuthConstants.orbBotRightAlpha),
          ),
        ),

        // Bottom-left subtle bloom
        Positioned(
          bottom: 80,
          left: -40,
          child: _Orb(
            size: AuthConstants.orbBotLeftSize,
            color: AppTheme.brandPrimary
                .withValues(alpha: AuthConstants.orbBotLeftAlpha),
          ),
        ),

        // Dot grid — top region
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: AuthConstants.dotGridHeight,
            child: CustomPaint(painter: DotGridPainter()),
          ),
        ),
      ],
    );
  }
}

/// A simple circular coloured blob.
class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});
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