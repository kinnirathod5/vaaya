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
//   AppTheme.radius.md          → BorderRadius.circular(16)
//   AppTheme.spacing.md         → 16.0
//   Theme.of(context)           → uses AppTheme.lightTheme
// ============================================================
class AppTheme {
  AppTheme._();

  // ══════════════════════════════════════════════════════════
  // BRAND COLORS
  // ══════════════════════════════════════════════════════════
  static const Color brandPrimary = Color(0xFFF23B5F); // Rose red — primary actions
  static const Color brandDark    = Color(0xFF2A2D34); // Deep charcoal — headings & text
  static const Color bgScaffold   = Color(0xFFF4F7FC); // Off-white — screen backgrounds
  static const Color surfaceWhite = Colors.white;

  // ── Gold / Premium ────────────────────────────────────────
  static const Color goldPrimary  = Color(0xFFC9962A);
  static const Color goldLight    = Color(0xFFF5C842);

  // ── Semantic ──────────────────────────────────────────────
  static const Color success      = Color(0xFF16A34A);
  static const Color warning      = Color(0xFFD97706);
  static const Color error        = Color(0xFFE8395A);
  static const Color info         = Color(0xFF2563EB);

  // ── Text ──────────────────────────────────────────────────
  static const Color textPrimary   = brandDark;
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint      = Color(0xFFBDBDBD);

  // ── Accent palette (used in detail cards, settings icons) ─
  static const Color accentPurple  = Color(0xFF6366F1);
  static const Color accentBlue    = Color(0xFF0EA5E9);
  static const Color accentGreen   = Color(0xFF10B981);
  static const Color accentViolet  = Color(0xFF8B5CF6);
  static const Color accentOrange  = Color(0xFFF97316);
  static const Color accentPink    = Color(0xFFEC4899);

  // ── Backward compatibility aliases ────────────────────────
  static const Color primaryColor    = brandPrimary;
  static const Color secondaryColor  = brandDark;
  static const Color backgroundColor = bgScaffold;

  // ══════════════════════════════════════════════════════════
  // SPACING SYSTEM
  // Use AppTheme.sp.xs / sm / md / lg / xl / xxl
  // ══════════════════════════════════════════════════════════
  // ignore: library_private_types_in_public_api
  static const _Spacing sp = _Spacing();

  // ══════════════════════════════════════════════════════════
  // BORDER RADIUS SYSTEM
  // Use AppTheme.r.xs / sm / md / lg / xl / full
  // ══════════════════════════════════════════════════════════
  // ignore: library_private_types_in_public_api
  static const _Radius r = _Radius();

  // ══════════════════════════════════════════════════════════
  // LIGHT THEME
  // ══════════════════════════════════════════════════════════
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

      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          color: brandDark, fontSize: 32,
          fontWeight: FontWeight.w900, height: 1.2, letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.poppins(
          color: brandDark, fontSize: 24,
          fontWeight: FontWeight.w700, height: 1.2, letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.poppins(
          color: brandDark, fontSize: 18, fontWeight: FontWeight.w700,
        ),
        titleMedium: GoogleFonts.poppins(
          color: brandDark, fontSize: 15, fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.poppins(color: brandDark, fontSize: 16),
        bodyMedium: GoogleFonts.poppins(color: textSecondary, fontSize: 14),
        bodySmall: GoogleFonts.poppins(color: textSecondary, fontSize: 12),
        labelSmall: GoogleFonts.poppins(
          color: textHint, fontSize: 11,
          fontWeight: FontWeight.w700, letterSpacing: 1.2,
        ),
      ),

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
            fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.3,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brandPrimary,
          textStyle: GoogleFonts.poppins(
            fontSize: 13, fontWeight: FontWeight.w700,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: GoogleFonts.poppins(
          color: textHint, fontWeight: FontWeight.w400, fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: brandPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error, width: 2),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade100,
        selectedColor: brandPrimary.withValues(alpha: 0.10),
        labelStyle: GoogleFonts.poppins(
          fontSize: 12, fontWeight: FontWeight.w600, color: brandDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: bgScaffold,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: brandDark),
        titleTextStyle: GoogleFonts.poppins(
          color: brandDark, fontSize: 18, fontWeight: FontWeight.w700,
        ),
      ),

      dividerTheme: DividerThemeData(
        color: Colors.grey.shade100, thickness: 1, space: 1,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) => Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return brandPrimary;
          return Colors.grey.shade300;
        }),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: brandPrimary,
        inactiveTrackColor: Colors.grey.shade200,
        thumbColor: brandPrimary,
        overlayColor: brandPrimary.withValues(alpha: 0.12),
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // SHADOWS
  // ══════════════════════════════════════════════════════════

  /// Subtle — cards, list tiles, light elevation
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 12, offset: const Offset(0, 4),
    ),
  ];

  /// Medium — floating cards, bottom sheets
  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 20, offset: const Offset(0, 8),
    ),
  ];

  /// Heavy — modals, hero images, large elevated surfaces
  static List<BoxShadow> get heavyShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 30, offset: const Offset(0, 12),
    ),
  ];

  /// Brand glow — CTA buttons, active states
  static List<BoxShadow> get primaryGlow => [
    BoxShadow(
      color: brandPrimary.withValues(alpha: 0.28),
      blurRadius: 16, offset: const Offset(0, 6),
    ),
  ];

  /// Gold glow — premium badges, upgrade CTAs
  static List<BoxShadow> get goldGlow => [
    BoxShadow(
      color: goldPrimary.withValues(alpha: 0.30),
      blurRadius: 16, offset: const Offset(0, 6),
    ),
  ];

  // ══════════════════════════════════════════════════════════
  // REUSABLE DECORATIONS
  // ══════════════════════════════════════════════════════════

  /// Standard white card
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surfaceWhite,
    borderRadius: BorderRadius.circular(20),
    boxShadow: softShadow,
    border: Border.all(color: Colors.grey.shade100),
  );

  /// Brand-tinted card — selected states
  static BoxDecoration get brandCardDecoration => BoxDecoration(
    color: brandPrimary.withValues(alpha: 0.05),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: brandPrimary.withValues(alpha: 0.18), width: 1.5,
    ),
  );

  /// Dark cinematic card — splash, premium, dark overlays
  static BoxDecoration get darkCardDecoration => BoxDecoration(
    color: const Color(0xFF1A0814),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
  );

  /// Gold premium card — upgrade, VIP sections
  static BoxDecoration get goldCardDecoration => BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1A0814), Color(0xFF2D1020)],
    ),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: goldPrimary.withValues(alpha: 0.30)),
    boxShadow: goldGlow,
  );

  /// Danger / destructive — delete, block actions
  static BoxDecoration dangerDecoration(Color color) => BoxDecoration(
    color: color.withValues(alpha: 0.06),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: color.withValues(alpha: 0.14)),
  );

  /// Icon container — used in settings, menu tiles, detail cards
  static BoxDecoration iconBg(Color color, {double radius = 10}) => BoxDecoration(
    color: color.withValues(alpha: 0.10),
    borderRadius: BorderRadius.circular(radius),
  );

  // ══════════════════════════════════════════════════════════
  // GRADIENTS
  // ══════════════════════════════════════════════════════════

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

  /// Subtle surface gradient — bottom nav bg, frosted sections
  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, Color(0xFFF8F9FF)],
  );

  // ══════════════════════════════════════════════════════════
  // TEXT STYLES (standalone, no context needed)
  // ══════════════════════════════════════════════════════════

  /// Display title — Cormorant Garamond, large headings
  static const TextStyle displayTitle = TextStyle(
    fontFamily: 'Cormorant Garamond',
    fontSize: 32, fontWeight: FontWeight.w700,
    color: brandDark, letterSpacing: -0.5, height: 1.1,
  );

  /// Section heading — Poppins bold
  static const TextStyle sectionHeading = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 15, fontWeight: FontWeight.w800,
    color: brandDark, letterSpacing: -0.2,
  );

  /// Card label — small caps, letter-spaced
  static const TextStyle cardLabel = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10, fontWeight: FontWeight.w700,
    color: Color(0xFF9CA3AF), letterSpacing: 1.2,
  );

  /// Body text — standard content
  static const TextStyle bodyText = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 13, color: textSecondary, height: 1.65,
  );

  /// Caption — small secondary info
  static const TextStyle caption = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 11, color: Color(0xFF9CA3AF),
  );

  /// Button text — CTA labels
  static const TextStyle buttonText = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 15, fontWeight: FontWeight.w700,
    color: Colors.white, letterSpacing: 0.2,
  );

  // ══════════════════════════════════════════════════════════
  // HELPER METHODS
  // ══════════════════════════════════════════════════════════

  /// Returns the right accent color for a given index.
  /// Useful for cycling through color-coded icon backgrounds.
  /// Usage: AppTheme.accentAt(index)
  static Color accentAt(int index) {
    const accents = [
      accentPurple, accentBlue, accentGreen,
      accentViolet, accentOrange, accentPink,
      brandPrimary, info,
    ];
    return accents[index % accents.length];
  }

  /// Returns appropriate text color for a given background.
  /// Useful for dynamically colored chips/badges.
  static Color contrastText(Color background) {
    return background.computeLuminance() > 0.4
        ? brandDark
        : Colors.white;
  }
}


// ══════════════════════════════════════════════════════════════
// SPACING CONSTANTS
// AppTheme.sp.xs → 4, .sm → 8, .md → 16, .lg → 24, .xl → 32
// ══════════════════════════════════════════════════════════════
class _Spacing {
  const _Spacing();
  double get xs  => 4;
  double get sm  => 8;
  double get md  => 16;
  double get lg  => 24;
  double get xl  => 32;
  double get xxl => 48;

  SizedBox get hXs  => const SizedBox(height: 4);
  SizedBox get hSm  => const SizedBox(height: 8);
  SizedBox get hMd  => const SizedBox(height: 16);
  SizedBox get hLg  => const SizedBox(height: 24);
  SizedBox get hXl  => const SizedBox(height: 32);

  SizedBox get wXs  => const SizedBox(width: 4);
  SizedBox get wSm  => const SizedBox(width: 8);
  SizedBox get wMd  => const SizedBox(width: 16);
  SizedBox get wLg  => const SizedBox(width: 24);
  SizedBox get wXl  => const SizedBox(width: 32);
}


// ══════════════════════════════════════════════════════════════
// BORDER RADIUS CONSTANTS
// AppTheme.r.sm → circular(8), .md → circular(16), etc.
// ══════════════════════════════════════════════════════════════
class _Radius {
  const _Radius();
  BorderRadius get xs   => BorderRadius.circular(6);
  BorderRadius get sm   => BorderRadius.circular(10);
  BorderRadius get md   => BorderRadius.circular(16);
  BorderRadius get lg   => BorderRadius.circular(20);
  BorderRadius get xl   => BorderRadius.circular(24);
  BorderRadius get xxl  => BorderRadius.circular(32);
  BorderRadius get full => BorderRadius.circular(999);
}