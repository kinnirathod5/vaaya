import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================
// 🎨 APP THEME — v2.0
// Central design system — colors, typography, shadows,
// component themes, reusable decorations, AND design tokens.
//
// WHAT'S NEW in v2.0:
//   ✅ Component tokens added — single source of truth for
//      icon buttons, search field, bottom sheet, avatars,
//      screen padding, section titles. Every screen reads
//      from here — no more magic numbers inline.
//
// Usage:
//   AppTheme.brandPrimary
//   AppTheme.softShadow
//   AppTheme.screenPadH          → 20.0 (horizontal padding)
//   AppTheme.iconBtnSize         → 44.0 (all header buttons)
//   AppTheme.cardRadius          → 20.0 (all content cards)
//   AppTheme.sheetRadius         → 28.0 (all bottom sheets)
//   AppTheme.searchFieldHeight   → 48.0
//   AppTheme.sectionTitleStyle   → Cormorant 22px w700
//   AppTheme.r.md                → BorderRadius.circular(16)
//   AppTheme.sp.md               → 16.0
//   Theme.of(context)            → uses AppTheme.lightTheme
// ============================================================
class AppTheme {
  AppTheme._();

  // ══════════════════════════════════════════════════════════
  // BRAND COLORS
  // ══════════════════════════════════════════════════════════
  static const Color brandPrimary = Color(0xFFF23B5F);
  static const Color brandDark    = Color(0xFF2A2D34);
  static const Color bgScaffold   = Color(0xFFF4F7FC);
  static const Color surfaceWhite = Colors.white;

  // ── Gold / Premium ────────────────────────────────────────
  static const Color goldPrimary = Color(0xFFC9962A);
  static const Color goldLight   = Color(0xFFF5C842);

  // ── Semantic ──────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color error   = Color(0xFFE8395A);
  static const Color info    = Color(0xFF2563EB);

  // ── Text ──────────────────────────────────────────────────
  static const Color textPrimary   = brandDark;
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint      = Color(0xFFBDBDBD);

  // ── Accent palette ────────────────────────────────────────
  static const Color accentPurple = Color(0xFF6366F1);
  static const Color accentBlue   = Color(0xFF0EA5E9);
  static const Color accentGreen  = Color(0xFF10B981);
  static const Color accentViolet = Color(0xFF8B5CF6);
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentPink   = Color(0xFFEC4899);

  // ── Online indicator ──────────────────────────────────────
  /// Online/active now dot — fixed green across ALL screens
  static const Color onlineDot = Color(0xFF4ADE80);

  // ── Backward compatibility aliases ────────────────────────
  static const Color primaryColor    = brandPrimary;
  static const Color secondaryColor  = brandDark;
  static const Color backgroundColor = bgScaffold;

  // ══════════════════════════════════════════════════════════
  // ▶▶ NEW: COMPONENT DESIGN TOKENS
  // Single source of truth for every reusable component.
  // Screens read from here — never hardcode these values.
  // ══════════════════════════════════════════════════════════

  // ── Screen layout ─────────────────────────────────────────
  /// Horizontal padding on ALL screens — left & right edges
  static const double screenPadH = 20.0;

  /// Vertical padding at top of screen content (below status bar)
  static const double screenPadTop = 18.0;

  // ── Icon button (AppIconButton) ───────────────────────────
  /// Standard header button size — Home, Matches, Chat, Interests
  static const double iconBtnSize    = 44.0;

  /// Compact button size — My Profile top bar, Chat Detail
  static const double iconBtnCompact = 40.0;

  /// Mini button size — sticky mini header
  static const double iconBtnMini    = 36.0;

  /// Rounded rect radius — Matches, Chat, Interests buttons
  static const double iconBtnRadius  = 13.0;

  // ── Search field (AppSearchField) ─────────────────────────
  /// Height of search field — Matches, Chat List
  static const double searchFieldHeight = 48.0;

  /// Border radius of search field
  static const double searchFieldRadius = 14.0;

  // ── Bottom sheet ──────────────────────────────────────────
  /// Top corner radius for ALL bottom sheets in the app
  /// (overrides AuthConstants cardRadius 32 for non-auth sheets)
  static const double sheetRadius = 28.0;

  /// Handle bar width inside bottom sheets
  static const double sheetHandleWidth  = 40.0;

  /// Handle bar height inside bottom sheets
  static const double sheetHandleHeight = 4.0;

  // ── Cards ─────────────────────────────────────────────────
  /// Standard content card radius — profile cards, chat tiles
  static const double cardRadius = 20.0;

  /// Auth flow card radius — login, OTP form card
  static const double authCardRadius = 32.0;

  // ── Avatar (PremiumAvatar / StoryAvatar) ──────────────────
  /// Standard story avatar size — Home Active Now, Chat Stories
  static const double avatarStorySize = 56.0;

  /// Conversation tile avatar size — Chat List
  static const double avatarConvoSize = 54.0;

  /// Online dot size — fixed across ALL screens
  static const double avatarOnlineDotSize   = 10.0;

  /// Online dot border width
  static const double avatarOnlineDotBorder = 2.0;

  /// Story ring width
  static const double avatarStoryRingWidth  = 3.0;

  /// Story ring gap (white gap between ring and photo)
  static const double avatarStoryRingGap    = 2.0;

  // ── Section header ────────────────────────────────────────
  /// Section title text style — Cormorant Garamond
  /// Used in: Home, Matches, Interests, Chat, Profile sections
  static const TextStyle sectionTitleStyle = TextStyle(
    fontFamily:  'Cormorant Garamond',
    fontSize:    22,
    fontWeight:  FontWeight.w700,
    color:       brandDark,
    letterSpacing: -0.2,
    height:      1.1,
  );

  /// Section subtitle text style — below section title
  static TextStyle sectionSubtitleStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize:   11,
    color:      Colors.grey.shade500,
  );

  // ── Filter chips ──────────────────────────────────────────
  /// Filter chip border radius — Matches filter row
  static const double filterChipRadius = 20.0;

  // ══════════════════════════════════════════════════════════
  // SPACING SYSTEM
  // AppTheme.sp.xs / sm / md / lg / xl / xxl
  // ══════════════════════════════════════════════════════════
  // ignore: library_private_types_in_public_api
  static const _Spacing sp = _Spacing();

  // ══════════════════════════════════════════════════════════
  // BORDER RADIUS SYSTEM
  // AppTheme.r.xs / sm / md / lg / xl / full
  // ══════════════════════════════════════════════════════════
  // ignore: library_private_types_in_public_api
  static const _Radius r = _Radius();

  // ══════════════════════════════════════════════════════════
  // SHADOWS
  // ══════════════════════════════════════════════════════════

  /// Subtle — cards, list tiles, icon buttons (idle state)
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color:      Colors.black.withValues(alpha: 0.05),
      blurRadius: 12,
      offset:     const Offset(0, 4),
    ),
  ];

  /// Medium — floating cards, bottom sheets
  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color:      Colors.black.withValues(alpha: 0.08),
      blurRadius: 20,
      offset:     const Offset(0, 8),
    ),
  ];

  /// Heavy — modals, hero images, large elevated surfaces
  static List<BoxShadow> get heavyShadow => [
    BoxShadow(
      color:      Colors.black.withValues(alpha: 0.12),
      blurRadius: 30,
      offset:     const Offset(0, 12),
    ),
  ];

  /// Brand glow — CTA buttons, active icon buttons, active states
  static List<BoxShadow> get primaryGlow => [
    BoxShadow(
      color:      brandPrimary.withValues(alpha: 0.28),
      blurRadius: 16,
      offset:     const Offset(0, 6),
    ),
  ];

  /// Gold glow — premium badges, upgrade CTAs
  static List<BoxShadow> get goldGlow => [
    BoxShadow(
      color:      goldPrimary.withValues(alpha: 0.30),
      blurRadius: 16,
      offset:     const Offset(0, 6),
    ),
  ];

  // ══════════════════════════════════════════════════════════
  // REUSABLE DECORATIONS
  // ══════════════════════════════════════════════════════════

  /// Standard white card — uses cardRadius token
  static BoxDecoration get cardDecoration => BoxDecoration(
    color:        surfaceWhite,
    borderRadius: BorderRadius.circular(cardRadius),
    boxShadow:    softShadow,
    border:       Border.all(color: Colors.grey.shade100),
  );

  /// Brand-tinted card — selected states
  static BoxDecoration get brandCardDecoration => BoxDecoration(
    color:        brandPrimary.withValues(alpha: 0.05),
    borderRadius: BorderRadius.circular(cardRadius),
    border: Border.all(
      color: brandPrimary.withValues(alpha: 0.18),
      width: 1.5,
    ),
  );

  /// Dark cinematic card — splash, premium, dark overlays
  static BoxDecoration get darkCardDecoration => BoxDecoration(
    color:        const Color(0xFF1A0814),
    borderRadius: BorderRadius.circular(cardRadius),
    border:       Border.all(color: Colors.white.withValues(alpha: 0.08)),
  );

  /// Gold premium card — upgrade, VIP sections
  static BoxDecoration get goldCardDecoration => BoxDecoration(
    gradient: const LinearGradient(
      begin:  Alignment.topLeft,
      end:    Alignment.bottomRight,
      colors: [Color(0xFF1A0814), Color(0xFF2D1020)],
    ),
    borderRadius: BorderRadius.circular(cardRadius),
    border:       Border.all(color: goldPrimary.withValues(alpha: 0.30)),
    boxShadow:    goldGlow,
  );

  /// Danger / destructive — delete, block actions
  static BoxDecoration dangerDecoration(Color color) => BoxDecoration(
    color:        color.withValues(alpha: 0.06),
    borderRadius: BorderRadius.circular(16),
    border:       Border.all(color: color.withValues(alpha: 0.14)),
  );

  /// Icon container — settings, menu tiles, detail cards
  static BoxDecoration iconBg(Color color, {double radius = 10}) =>
      BoxDecoration(
        color:        color.withValues(alpha: 0.10),
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
    begin:  Alignment.topLeft,
    end:    Alignment.bottomRight,
    colors: [Color(0xFFC9962A), Color(0xFFF5C842)],
  );

  /// Dark cinematic gradient — premium bg, hero overlays
  static const LinearGradient darkGradient = LinearGradient(
    begin:  Alignment.topCenter,
    end:    Alignment.bottomCenter,
    colors: [Color(0xFF1A0814), Color(0xFF120610), Color(0xFF0A0408)],
  );

  /// Subtle surface gradient — bottom nav bg, frosted sections
  static const LinearGradient surfaceGradient = LinearGradient(
    begin:  Alignment.topLeft,
    end:    Alignment.bottomRight,
    colors: [Colors.white, Color(0xFFF8F9FF)],
  );

  // ══════════════════════════════════════════════════════════
  // TEXT STYLES (standalone — no context needed)
  // ══════════════════════════════════════════════════════════

  /// Display title — Cormorant Garamond, screen headings
  static const TextStyle displayTitle = TextStyle(
    fontFamily:   'Cormorant Garamond',
    fontSize:     32,
    fontWeight:   FontWeight.w700,
    color:        brandDark,
    letterSpacing: -0.5,
    height:       1.1,
  );

  /// Section heading — Poppins bold (use sectionTitleStyle for sections)
  static const TextStyle sectionHeading = TextStyle(
    fontFamily:  'Poppins',
    fontSize:    15,
    fontWeight:  FontWeight.w800,
    color:       brandDark,
    letterSpacing: -0.2,
  );

  /// Card label — small caps, letter-spaced
  static const TextStyle cardLabel = TextStyle(
    fontFamily:  'Poppins',
    fontSize:    10,
    fontWeight:  FontWeight.w700,
    color:       Color(0xFF9CA3AF),
    letterSpacing: 1.2,
  );

  /// Body text — standard content
  static const TextStyle bodyText = TextStyle(
    fontFamily: 'Poppins',
    fontSize:   13,
    color:      textSecondary,
    height:     1.65,
  );

  /// Caption — small secondary info
  static const TextStyle caption = TextStyle(
    fontFamily: 'Poppins',
    fontSize:   11,
    color:      Color(0xFF9CA3AF),
  );

  /// Button text — CTA labels
  static const TextStyle buttonText = TextStyle(
    fontFamily:  'Poppins',
    fontSize:    15,
    fontWeight:  FontWeight.w700,
    color:       Colors.white,
    letterSpacing: 0.2,
  );

  // ══════════════════════════════════════════════════════════
  // HELPER METHODS
  // ══════════════════════════════════════════════════════════

  /// Accent color for a given index — cycles through palette
  static Color accentAt(int index) {
    const accents = [
      accentPurple, accentBlue,  accentGreen,
      accentViolet, accentOrange, accentPink,
      brandPrimary, info,
    ];
    return accents[index % accents.length];
  }

  /// Text color for dynamic colored backgrounds
  static Color contrastText(Color background) {
    return background.computeLuminance() > 0.4 ? brandDark : Colors.white;
  }

  // ══════════════════════════════════════════════════════════
  // LIGHT THEME
  // ══════════════════════════════════════════════════════════
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3:           true,
      scaffoldBackgroundColor: bgScaffold,
      primaryColor:            brandPrimary,
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
        bodyLarge:  GoogleFonts.poppins(color: brandDark,      fontSize: 16),
        bodyMedium: GoogleFonts.poppins(color: textSecondary,  fontSize: 14),
        bodySmall:  GoogleFonts.poppins(color: textSecondary,  fontSize: 12),
        labelSmall: GoogleFonts.poppins(
          color: textHint, fontSize: 11,
          fontWeight: FontWeight.w700, letterSpacing: 1.2,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandPrimary,
          foregroundColor: Colors.white,
          elevation:       0,
          shadowColor:     brandPrimary.withValues(alpha: 0.30),
          minimumSize:     const Size(double.infinity, 56),
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
        filled:         true,
        fillColor:      surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: GoogleFonts.poppins(
          color: textHint, fontWeight: FontWeight.w400, fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:   BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:   BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:   const BorderSide(color: brandPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:   const BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:   const BorderSide(color: error, width: 2),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade100,
        selectedColor:   brandPrimary.withValues(alpha: 0.10),
        labelStyle: GoogleFonts.poppins(
          fontSize: 12, fontWeight: FontWeight.w600, color: brandDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(filterChipRadius),
          side:         BorderSide(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor:         bgScaffold,
        elevation:               0,
        scrolledUnderElevation:  0,
        centerTitle:             false,
        iconTheme:               const IconThemeData(color: brandDark),
        titleTextStyle: GoogleFonts.poppins(
          color: brandDark, fontSize: 18, fontWeight: FontWeight.w700,
        ),
      ),

      dividerTheme: DividerThemeData(
        color: Colors.grey.shade100, thickness: 1, space: 1,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((_) => Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return brandPrimary;
          return Colors.grey.shade300;
        }),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor:   brandPrimary,
        inactiveTrackColor: Colors.grey.shade200,
        thumbColor:         brandPrimary,
        overlayColor:       brandPrimary.withValues(alpha: 0.12),
        trackHeight:        3,
        thumbShape:         const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
    );
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

  SizedBox get hXs => const SizedBox(height: 4);
  SizedBox get hSm => const SizedBox(height: 8);
  SizedBox get hMd => const SizedBox(height: 16);
  SizedBox get hLg => const SizedBox(height: 24);
  SizedBox get hXl => const SizedBox(height: 32);

  SizedBox get wXs => const SizedBox(width: 4);
  SizedBox get wSm => const SizedBox(width: 8);
  SizedBox get wMd => const SizedBox(width: 16);
  SizedBox get wLg => const SizedBox(width: 24);
  SizedBox get wXl => const SizedBox(width: 32);
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