import 'package:flutter/services.dart';

/// Yeh class poore app ki vibrations (Haptics) ko control karegi.
/// Isse app ko ek premium aur tactile feel milta hai.
class HapticUtils {
  // Constructor ko private banaya hai taaki iska object na ban sake
  HapticUtils._();

  /// Halke touch ke liye (Jaise chote buttons ya icons par click karna)
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  /// Normal touch ke liye (Jaise navigation ya tabs change karna)
  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  /// Bhari touch ke liye (Jaise "Get OTP" ya kisi bade action par click karna)
  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  /// Scroll karte waqt ya drop-down select karte waqt ka feel
  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  /// Jab koi error ho (Jaise galat OTP ya 10 digit se kam number dalna)
  static void errorVibrate() {
    HapticFeedback.vibrate();
  }
}