import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/haptic_utils.dart';

// ============================================================
// 🔒 GUEST LOCK WIDGET
// Freemium gate — shown after the 3 free profile views.
//
// Two components:
//   GuestLockOverlay  → full-screen lock (replaces list/grid)
//   GuestLockedCard   → blur overlay on individual profile cards
//
// Usage in matches grid:
//   if (isGuest && index >= 3) {
//     return GuestLockedCard(
//       borderRadius: 20,
//       child: MatchCard(match: match),
//     );
//   }
//
// Usage for full screen:
//   if (isGuest && viewedCount >= 3) {
//     return const GuestLockOverlay();
//   }
//
// TODO: authProvider.setGuestMode(false) on login
//       guestViewCountProvider to track views
// ============================================================


// ════════════════════════════════════════════════════════════
// FULL SCREEN OVERLAY
// Replaces the entire screen content when limit is reached
// ════════════════════════════════════════════════════════════
class GuestLockOverlay extends StatelessWidget {
  const GuestLockOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.bgScaffold,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Lock icon
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFDF2F4),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.brandPrimary.withValues(alpha: 0.15),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: AppTheme.brandPrimary,
                  size: 34,
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Create an account\nto see more profiles',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.brandDark,
                  height: 1.25,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                'You\'ve viewed 3 free profiles.\nSign up for free to unlock full access.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 32),

              // Primary CTA
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    HapticUtils.mediumImpact();
                    // TODO: authProvider.setGuestMode(false)
                    context.go('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.brandPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Create Free Account',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Secondary — already have account
              GestureDetector(
                onTap: () {
                  HapticUtils.lightImpact();
                  context.go('/login');
                },
                child: Text(
                  'Already have an account? Sign in',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ════════════════════════════════════════════════════════════
// LOCKED CARD
// Blurs an individual profile card and shows a lock overlay.
// Tap triggers a mini bottom sheet nudge.
// ════════════════════════════════════════════════════════════
class GuestLockedCard extends StatelessWidget {
  const GuestLockedCard({
    super.key,
    required this.child,
    required this.borderRadius,
  });

  final Widget child;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        _showLoginNudge(context);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [

            // Blurred content underneath
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: child,
            ),

            // Dark gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.22),
                    Colors.black.withValues(alpha: 0.52),
                  ],
                ),
              ),
            ),

            // Lock icon + label
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      color: AppTheme.brandPrimary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Sign in to view',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.brandPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mini bottom sheet nudge
  static void _showLoginNudge(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
          24, 12, 24,
          24 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // Handle
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),

            const Text('🔒', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 12),

            const Text(
              'This profile is locked',
              style: TextStyle(
                fontFamily: 'Cormorant Garamond',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.brandDark,
              ),
            ),
            const SizedBox(height: 6),

            Text(
              'You\'ve used your 3 free views.\nCreate a free account for full access.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                // Dismiss
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Maybe later',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Sign up CTA
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      HapticUtils.mediumImpact();
                      // TODO: authProvider.setGuestMode(false)
                      context.go('/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.brandPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Create Free Account',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}