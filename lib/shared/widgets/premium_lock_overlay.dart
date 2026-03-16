import 'dart:ui';
import 'package:flutter/material.dart';

// 🔥 Humare doosre Lego Blocks
import '../../core/theme/app_theme.dart';
import '../../core/utils/haptic_utils.dart';

class PremiumLockOverlay extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onUnlockTap;
  final bool useDarkTheme;
  final double borderRadius;

  const PremiumLockOverlay({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onUnlockTap,
    this.useDarkTheme = true, // Default premium look dark hota hai
    this.borderRadius = 20.0, // Default card border radius
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        // ✨ Premium Blur Effect
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: useDarkTheme
                ? Colors.black.withOpacity(0.5) // Dark overlay
                : Colors.white.withOpacity(0.4), // Light overlay
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: useDarkTheme ? Colors.white12 : Colors.white54,
              width: 1,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min, // Jitni jagah chahiye utni hi lega
                children: [
                  // 🔒 Glowing Golden Lock Icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)], // Gold Gradient
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Icon(Icons.lock_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 15),

                  // 📝 Title Text
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: useDarkTheme ? Colors.white : AppTheme.brandDark,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // 📝 Subtitle Text
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: useDarkTheme ? Colors.white70 : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🔓 Unlock Button
                  GestureDetector(
                    onTap: () {
                      HapticUtils.heavyImpact();
                      onUnlockTap();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: const Text(
                        'Unlock Now',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.brandDark, // Text hamesha dark rahega white button pe
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