import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/haptic_utils.dart';

// ============================================================
// 🔒 PREMIUM LOCK OVERLAY
// Frosted glass overlay for locked premium content.
// Sits on top of any widget to indicate it requires upgrade.
//
// Lock types:
//   LockType.premium → gold lock — premium feature (default)
//   LockType.contact → phone icon — contact number locked
//   LockType.photo   → image icon — photo locked
//
// Usage:
//   Stack(children: [
//     ProfileCard(...),
//     const PremiumLockOverlay(
//       title: 'Premium Feature',
//       subtitle: 'Upgrade to view contact details.',
//       onUnlockTap: () => context.push('/premium'),
//     ),
//   ])
// ============================================================

enum LockType { premium, contact, photo }

class PremiumLockOverlay extends StatelessWidget {
  const PremiumLockOverlay({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onUnlockTap,
    this.lockType = LockType.premium,
    this.useDarkTheme = true,
    this.borderRadius = 20.0,
    this.buttonLabel = 'Unlock Now',
    this.blurSigma = 10.0,
  });

  final String title;
  final String subtitle;
  final VoidCallback onUnlockTap;

  /// Icon and color scheme of the lock badge
  final LockType lockType;

  /// Dark overlay (default) vs light overlay
  final bool useDarkTheme;

  final double borderRadius;

  /// CTA button label (default: 'Unlock Now')
  final String buttonLabel;

  /// Backdrop blur amount (default: 10)
  final double blurSigma;

  // ── Lock config per type ──────────────────────────────────
  IconData get _lockIcon {
    switch (lockType) {
      case LockType.premium: return Icons.diamond_rounded;
      case LockType.contact: return Icons.phone_rounded;
      case LockType.photo:   return Icons.image_rounded;
    }
  }

  List<Color> get _badgeGradient {
    switch (lockType) {
      case LockType.premium:
        return [const Color(0xFFC9962A), const Color(0xFFF5C842)];
      case LockType.contact:
        return [AppTheme.brandPrimary, const Color(0xFFFF6B84)];
      case LockType.photo:
        return [const Color(0xFF2563EB), const Color(0xFF60A5FA)];
    }
  }

  Color get _badgeGlow {
    switch (lockType) {
      case LockType.premium: return const Color(0xFFC9962A);
      case LockType.contact: return AppTheme.brandPrimary;
      case LockType.photo:   return const Color(0xFF2563EB);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            color: useDarkTheme
                ? Colors.black.withValues(alpha: 0.48)
                : Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: useDarkTheme
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.white.withValues(alpha: 0.70),
              width: 1,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // ── Lock badge ──────────────────────────
                  Container(
                    width: 58, height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _badgeGradient,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _badgeGlow.withValues(alpha: 0.40),
                          blurRadius: 18,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _lockIcon,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Title ───────────────────────────────
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: useDarkTheme ? Colors.white : AppTheme.brandDark,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // ── Subtitle ────────────────────────────
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: useDarkTheme
                          ? Colors.white.withValues(alpha: 0.65)
                          : Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Unlock button ───────────────────────
                  GestureDetector(
                    onTap: () {
                      HapticUtils.heavyImpact();
                      onUnlockTap();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: useDarkTheme
                            ? Colors.white
                            : AppTheme.brandPrimary,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: useDarkTheme
                            ? AppTheme.softShadow
                            : AppTheme.primaryGlow,
                      ),
                      child: Text(
                        buttonLabel,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: useDarkTheme
                              ? AppTheme.brandDark
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}