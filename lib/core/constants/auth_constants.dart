import 'package:flutter/material.dart';

/// Single source of truth for all auth-flow design tokens.
///
/// Both [LoginScreen] and [OtpVerificationScreen] (and any future auth
/// screen) must pull values from here so the visual language stays
/// consistent across the entire onboarding funnel.
abstract class AuthConstants {
  // ── Layout ────────────────────────────────────────────────
  static const double cardRadius       = 32.0;
  static const double buttonRadius     = 16.0;
  static const double buttonHeight     = 54.0;
  static const double handleBarWidth   = 36.0;
  static const double handleBarHeight  = 4.0;
  static const double handleBarAlpha   = 0.15;

  /// Spacing below the handle bar before the next content.
  static const double afterHandleBar   = 22.0;

  // ── Background ────────────────────────────────────────────
  static const Color scaffoldBg = Color(0xFFFDF8F9);

  // ── Dot grid ──────────────────────────────────────────────
  static const double dotSpacing       = 24.0;
  static const double dotRadius        = 1.2;
  static const double dotAlpha         = 0.055;
  static const double dotVertFactor    = 0.86;
  static const double dotGridHeight    = 260.0;

  // ── Orbs (soft bloom circles) ─────────────────────────────
  /// Top-right large bloom.
  static const double orbTopRightSize   = 340.0;
  static const double orbTopRightAlpha  = 0.09;

  /// Mid-left secondary bloom.
  static const double orbMidLeftSize    = 240.0;
  static const double orbMidLeftAlpha   = 0.05;

  /// Top-left tiny gold accent.
  static const double orbTopLeftSize    = 80.0;
  static const double orbTopLeftAlpha   = 0.06;

  /// Bottom-right gold bloom.
  static const double orbBotRightSize   = 200.0;
  static const double orbBotRightAlpha  = 0.04;

  /// Bottom-left subtle bloom.
  static const double orbBotLeftSize    = 160.0;
  static const double orbBotLeftAlpha   = 0.04;

  // ── Animations ────────────────────────────────────────────
  static const Duration entryDuration = Duration(milliseconds: 1000);

  /// Content (form card) fade-in interval within [entryDuration].
  static const double contentStart = 0.30;
  static const double contentEnd   = 0.90;

  /// Header / logo fade-in interval.
  static const double headerStart = 0.0;
  static const double headerEnd   = 0.50;

  // ── Card shadows ──────────────────────────────────────────
  static const double cardShadowBlur   = 32.0;
  static const double cardShadowAlpha  = 0.10;
  static const double cardBlackAlpha   = 0.04;
  static const double cardBlackBlur    = 20.0;

  // ── Snackbar ──────────────────────────────────────────────
  static const double snackBarRadius   = 14.0;
  static const double snackBarBlur     = 12.0;
  static const double snackBarAlpha    = 0.30;
}