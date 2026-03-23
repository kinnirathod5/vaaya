import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

// ============================================================
// 🍞 CUSTOM TOAST
// Floating snackbar notifications with icon + message.
//
// Usage:
//   CustomToast.success(context, 'Profile updated!');
//   CustomToast.error(context, 'Something went wrong.');
//   CustomToast.info(context, 'OTP sent to your number.');
//   CustomToast.warning(context, 'Please complete your profile.');
//   CustomToast.premium(context, 'Upgrade to send more interests.');
// ============================================================
class CustomToast {
  CustomToast._(); // Private constructor — no instances

  // ── Public API ────────────────────────────────────────────

  /// Green — successful actions (saved, sent, verified)
  static void success(BuildContext context, String message) {
    HapticFeedback.lightImpact();
    _show(
      context,
      message: message,
      bgColor: AppTheme.success,
      icon: Icons.check_circle_rounded,
    );
  }

  /// Red — errors, failures, validation issues
  static void error(BuildContext context, String message) {
    HapticFeedback.vibrate();
    _show(
      context,
      message: message,
      bgColor: AppTheme.error,
      icon: Icons.error_outline_rounded,
    );
  }

  /// Blue — neutral info (OTP sent, loading, tips)
  static void info(BuildContext context, String message) {
    HapticFeedback.lightImpact();
    _show(
      context,
      message: message,
      bgColor: AppTheme.info,
      icon: Icons.info_outline_rounded,
    );
  }

  /// Amber — soft warnings (incomplete profile, missing fields)
  static void warning(BuildContext context, String message) {
    HapticFeedback.mediumImpact();
    _show(
      context,
      message: message,
      bgColor: AppTheme.warning,
      icon: Icons.warning_amber_rounded,
    );
  }

  /// Gold — premium nudges (upgrade CTA, locked feature)
  static void premium(BuildContext context, String message) {
    HapticFeedback.mediumImpact();
    _show(
      context,
      message: message,
      bgColor: AppTheme.goldPrimary,
      icon: Icons.diamond_rounded,
      duration: const Duration(seconds: 3),
    );
  }

  // ── Backward-compatible aliases ───────────────────────────
  // Old code used showSuccess / showError — keep working
  static void showSuccess(BuildContext context, String message) =>
      success(context, message);

  static void showError(BuildContext context, String message) =>
      error(context, message);

  // ── Core builder ─────────────────────────────────────────
  static void _show(
      BuildContext context, {
        required String message,
        required Color bgColor,
        required IconData icon,
        Duration duration = const Duration(seconds: 2),
      }) {
    // Dismiss any existing toast before showing new one
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        duration: duration,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: bgColor.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
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