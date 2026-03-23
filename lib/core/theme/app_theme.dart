import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// 🎨 APP THEME
// Central design system — colors, typography, shadows,
// component themes, and reusable decorations.
//
// Usage:
//   AppTheme.brandPrimary
//   AppTheme.softShadow
//   Theme.of(context) → uses AppTheme.lightTheme
// ============================================================
class AppTheme {

  AppTheme._(); // Private constructor — no instances

  // ── Brand Colors ──────────────────────────────────────────
  static const Color brandPrimary  = Color(0xFFF23B5F); // Rose red — primary actions
  static const Color brandDark     = Color(0xFF2A2D34); // Deep charcoal — headings & text
  static const Color bgScaffold    = Color(0xFFF4F7FC); // Off-white — screen backgrounds
  static const Color surfaceWhite  = Colors.white;      // Card surfaces

  // ── Gold / Premium Colors ─────────────────────────────────
  static const Color goldPrimary   = Color(0xFFC9962A); // Premium gold
  static const Color goldLight     = Color(0xFFF5C842); // Light gold highlight

  // ── Semantic Colors ───────────────────────────────────────
  static const Color success       = Color(0xFF16A34A); // Green — verified, accepted
  static const Color warning       = Color(0xFFD97706); // Amber — pending, caution
  static const Color error         = Color(0xFFE8395A); // Red — errors, destructive
  static const Color info          = Color(0xFF2563EB); // Blue — verified badge, info

  // ── Text Colors ───────────────────────────────────────────
  static const Color textPrimary   = brandDark;
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint      = Color(0xFFBDBDBD);

  // ── Backward Compatibility Aliases ───────────────────────
  // Kept so existing screens don't break
  static const Color primaryColor     = brandPrimary;
  static const Color secondaryColor   = brandDark;
  static const Color backgroundColor  = bgScaffold;

  // ── Light Theme ───────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bgScaffold,
      primaryColor: brandPrimary,
      colorScheme: ColorScheme.light(
        primary:   brandPrimary,
        secondary: brandDark,
        surface:   surfaceWhite,
        error:     error,
      ),

      // Typography
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          color: brandDark,
          fontSize: 32,
          fontWeight: FontWeight.w900,
          height: 1.2,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.poppins(
          color: brandDark,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.2,
          letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.poppins(
          color: brandDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: GoogleFonts.poppins(
          color: brandDark,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.poppins(
          color: brandDark,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.poppins(
          color: textSecondary,
          fontSize: 14,
        ),
        bodySmall: GoogleFonts.poppins(
          color: textSecondary,
          fontSize: 12,
        ),
        labelSmall: GoogleFonts.poppins(
          color: textHint,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: brandPrimary.withValues(alpha: 0.30),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brandPrimary,
          textStyle: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18, vertical: 16,
        ),
        hintStyle: GoogleFonts.poppins(
          color: textHint,
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: brandPrimary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: error,
            width: 2,
          ),
        ),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade100,
        selectedColor: brandPrimary.withValues(alpha: 0.10),
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: brandDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // App bar
      appBarTheme: AppBarTheme(
        backgroundColor: bgScaffold,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: brandDark),
        titleTextStyle: GoogleFonts.poppins(
          color: brandDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade100,
        thickness: 1,
        space: 1,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return brandPrimary;
          return Colors.grey.shade300;
        }),
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: brandPrimary,
        inactiveTrackColor: Colors.grey.shade200,
        thumbColor: brandPrimary,
        overlayColor: brandPrimary.withValues(alpha: 0.12),
        trackHeight: 3,
      ),
    );
  }

  // ── Shadows ───────────────────────────────────────────────

  /// Subtle shadow — cards, buttons, light elevation
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// Medium shadow — floating cards, bottom sheets
  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  /// Heavy shadow — modals, hero images, large elevated surfaces
  static List<BoxShadow> get heavyShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 30,
      offset: const Offset(0, 12),
    ),
  ];

  /// Brand glow — CTA buttons, selected states
  static List<BoxShadow> get primaryGlow => [
    BoxShadow(
      color: brandPrimary.withValues(alpha: 0.28),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  /// Gold glow — premium badges, upgrade CTAs
  static List<BoxShadow> get goldGlow => [
    BoxShadow(
      color: goldPrimary.withValues(alpha: 0.30),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  // ── Reusable Decorations ──────────────────────────────────

  /// Standard white card decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surfaceWhite,
    borderRadius: BorderRadius.circular(20),
    boxShadow: softShadow,
    border: Border.all(color: Colors.grey.shade100),
  );

  /// Brand-tinted card — selected states, highlighted sections
  static BoxDecoration get brandCardDecoration => BoxDecoration(
    color: brandPrimary.withValues(alpha: 0.05),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: brandPrimary.withValues(alpha: 0.18),
      width: 1.5,
    ),
  );

  /// Dark cinematic card — splash, premium, dark overlays
  static BoxDecoration get darkCardDecoration => BoxDecoration(
    color: const Color(0xFF1A0814),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.08),
    ),
  );

  /// Gold premium card — upgrade, VIP sections
  static BoxDecoration get goldCardDecoration => BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1A0814), Color(0xFF2D1020)],
    ),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: goldPrimary.withValues(alpha: 0.30),
    ),
    boxShadow: goldGlow,
  );

  // ── Gradients ─────────────────────────────────────────────

  /// Primary brand gradient — CTA buttons, active elements
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFFE8395A), Color(0xFFFF6B84)],
  );

  /// Gold gradient — premium badges, VIP crown icons
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC9962A), Color(0xFFF5C842)],
  );

  /// Dark cinematic gradient — splash background, hero overlays
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A0814), Color(0xFF120610), Color(0xFF0A0408)],
  );
}