import 'package:flutter/material.dart';

// ============================================================
// 🪷 ONBOARDING CONSTANTS
// Single source of truth for all onboarding-flow design tokens.
//
// Used by AccountCreationScreen and StepProgressHeader so that
// animation timing, spacing, and sizing stay consistent across
// all 6 wizard steps.
// ============================================================
abstract class OnboardingConstants {

  // ── Page transitions ──────────────────────────────────────
  static const Duration pageTransitionDuration = Duration(milliseconds: 480);
  static const Curve    pageTransitionCurve    = Curves.easeOutCubic;

  // ── Ambient glow animation ────────────────────────────────
  static const Duration ambientGlowDuration = Duration(milliseconds: 900);
  static const Curve    ambientGlowCurve    = Curves.easeInOutCubic;

  // ── Step content animations ───────────────────────────────
  static const Duration containerAnimDuration = Duration(milliseconds: 220);
  static const Duration genderCardDuration    = Duration(milliseconds: 200);
  static const Duration hintBannerDuration    = Duration(milliseconds: 320);

  // ── Step progress header ──────────────────────────────────
  static const Duration progressBubbleDuration = Duration(milliseconds: 300);
  static const Duration progressBarDuration    = Duration(milliseconds: 380);
  static const double   emojiBubbleActiveSize   = 28.0;
  static const double   emojiBubbleInactiveSize = 22.0;
  static const double   progressBarHeight       = 3.0;
  static const double   progressBarRadius       = 4.0;
  static const double   emojiFontActive         = 13.0;
  static const double   emojiFontInactive       = 10.0;

  // ── Celebration overlay ───────────────────────────────────
  static const Duration confettiDuration         = Duration(milliseconds: 2700);
  static const Duration celebrationFadeDuration  = Duration(milliseconds: 350);
  static const Duration celebrationScaleDuration = Duration(milliseconds: 550);

  // ── Layout ────────────────────────────────────────────────
  static const double stepHorizontalPad = 24.0;
  static const double stepTopPad        = 20.0;
  static const double buttonBottomPad   = 16.0;
  static const double buttonTopPad      = 10.0;

  // ── Card / chip radii ─────────────────────────────────────
  static const double genderCardRadius     = 22.0;
  static const double pickerCardRadius     = 20.0;
  static const double photoCardRadius      = 26.0;
  static const double communityChipRadius  = 14.0;
  static const double infoNoteRadius       = 14.0;

  // ── Picker dimensions ─────────────────────────────────────
  static const double pickerCardHeight       = 210.0;
  static const double heightPickerCardHeight = 230.0;
  static const double pickerItemExtent       = 52.0;
  static const double pickerColumnWidth      = 120.0;

  // ── Photo step ────────────────────────────────────────────
  static const double photoCardWidth  = 180.0;
  static const double photoCardHeight = 220.0;
}
