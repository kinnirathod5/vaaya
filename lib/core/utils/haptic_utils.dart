import 'package:flutter/services.dart';

// ============================================================
// 📳 HAPTIC UTILS
// Centralized haptic feedback for the entire app.
// Consistent tactile responses make the app feel premium.
//
// Usage:
//   HapticUtils.lightImpact();    // icon taps, chip selections
//   HapticUtils.mediumImpact();   // navigation, send actions
//   HapticUtils.heavyImpact();    // OTP submit, match confirm
//   HapticUtils.selectionClick(); // picker scroll, toggle
//   HapticUtils.errorVibrate();   // wrong OTP, validation fail
//   HapticUtils.successPattern(); // profile saved, interest sent
//   HapticUtils.matchPattern();   // mutual match celebration
//   HapticUtils.deletePattern();  // destructive action warning
// ============================================================
class HapticUtils {
  HapticUtils._();

  // ── Standard impacts ──────────────────────────────────────

  /// Light tap — small icons, chips, filter selections, like button
  static void lightImpact() => HapticFeedback.lightImpact();

  /// Medium tap — tab changes, navigation pushes, send interest
  static void mediumImpact() => HapticFeedback.mediumImpact();

  /// Heavy tap — OTP submit, match confirmed, VIP Lounge entry,
  /// celebration trigger, destructive actions (delete, sign out)
  static void heavyImpact() => HapticFeedback.heavyImpact();

  /// Selection tick — Cupertino pickers, toggle switches,
  /// gender card selection, gotra chip tap
  static void selectionClick() => HapticFeedback.selectionClick();

  // ── Semantic patterns ─────────────────────────────────────

  /// Error — wrong OTP, validation fail, disabled button tap
  static void errorVibrate() => HapticFeedback.vibrate();

  /// Success — profile saved, interest sent, photo verified
  /// Double light tap = confirmation feel
  static Future<void> successPattern() async {
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.lightImpact();
  }

  /// Match — mutual match confirmed, celebration moment
  /// Heavy → pause → light = heartbeat feel
  static Future<void> matchPattern() async {
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    HapticFeedback.lightImpact();
  }

  /// Notification — new interest received, new message
  /// Medium → light = gentle nudge
  static Future<void> notificationPattern() async {
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    HapticFeedback.lightImpact();
  }

  /// Delete / Danger — account delete, block user confirm
  /// Heavy → heavy = serious warning feel
  static Future<void> deletePattern() async {
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 120));
    HapticFeedback.heavyImpact();
  }

  /// Premium unlock — upgrade purchased, feature unlocked
  /// Light → medium → heavy = escalating celebration
  static Future<void> premiumPattern() async {
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    HapticFeedback.heavyImpact();
  }
}