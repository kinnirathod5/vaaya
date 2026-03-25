// ============================================================
// 📦 APP ASSETS
// Central store for all image URLs, local asset paths,
// and placeholder definitions used across the app.
//
// Usage:
//   CustomNetworkImage(imageUrl: AppAssets.dummyFemale1)
//   Image.asset(AppAssets.appLogo)
//
// v2.0 FIX: dummyFemale3 was a boat/yacht image — replaced
//           with actual female portrait URL.
// ============================================================
class AppAssets {
  AppAssets._(); // Private constructor — no instances

  // ══════════════════════════════════════════════════════════
  // 🌐 DUMMY PROFILE PHOTOS — Female
  // Used in: Home, Matches, Interests, User Detail screens
  // Replace with: Firestore user.photos[] when backend ready
  // ══════════════════════════════════════════════════════════
  static const String dummyFemale1 =
      'https://images.unsplash.com/photo-1583089892943-e02e52f17d50?auto=format&fit=crop&w=800&q=80';
  static const String dummyFemale2 =
      'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?auto=format&fit=crop&w=800&q=80';
  // FIX: was photo-1605281317010 (boat/yacht) — replaced with female portrait
  static const String dummyFemale3 =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=800&q=80';
  static const String dummyFemale4 =
      'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?auto=format&fit=crop&w=800&q=80';
  static const String dummyFemale5 =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80';
  static const String dummyFemale6 =
      'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&w=800&q=80';
  static const String dummyFemale7 =
      'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=80';
  static const String dummyFemale8 =
      'https://images.unsplash.com/photo-1488716820095-cbe80883c496?auto=format&fit=crop&w=800&q=80';
  static const String dummyFemale9 =
      'https://images.unsplash.com/photo-1607746882042-944635dfe10e?auto=format&fit=crop&w=800&q=80';

  // ══════════════════════════════════════════════════════════
  // 🌐 DUMMY PROFILE PHOTOS — Male
  // ══════════════════════════════════════════════════════════
  static const String dummyMale1 =
      'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=800&q=80';
  static const String dummyMale2 =
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=800&q=80';
  static const String dummyMale3 =
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=800&q=80';
  static const String dummyMale4 =
      'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=800&q=80';

  // ── Convenience list accessors ─────────────────────────
  static const List<String> dummyFemalePhotos = [
    dummyFemale1, dummyFemale2, dummyFemale3,
    dummyFemale4, dummyFemale5, dummyFemale6,
    dummyFemale7, dummyFemale8, dummyFemale9,
  ];

  static const List<String> dummyMalePhotos = [
    dummyMale1, dummyMale2, dummyMale3, dummyMale4,
  ];

  // ── Thumbnail variants (smaller, faster load) ──────────
  static const String dummyFemale1Thumb =
      'https://images.unsplash.com/photo-1583089892943-e02e52f17d50?auto=format&fit=crop&w=200&q=70';
  static const String dummyFemale2Thumb =
      'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?auto=format&fit=crop&w=200&q=70';
  static const String dummyMale1Thumb =
      'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=200&q=70';
  static const String dummyMale2Thumb =
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=70';

  // ══════════════════════════════════════════════════════════
  // 🌐 DUMMY COUPLE / SUCCESS STORY PHOTOS
  // Used in: Home screen success stories section
  // ══════════════════════════════════════════════════════════
  static const String successStory1 =
      'https://images.unsplash.com/photo-1529636798458-92182e662485?auto=format&fit=crop&w=800&q=80';
  static const String successStory2 =
      'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=800&q=80';
  static const String successStory3 =
      'https://images.unsplash.com/photo-1583939003579-730e3918a45a?auto=format&fit=crop&w=800&q=80';

  // ══════════════════════════════════════════════════════════
  // 📁 LOCAL ASSETS — Paths
  // Add files to assets/ folder and declare in pubspec.yaml
  //
  // pubspec.yaml mein yeh add karo:
  //   flutter:
  //     assets:
  //       - assets/images/
  //       - assets/icons/
  //       - assets/animations/
  // ══════════════════════════════════════════════════════════

  // ── App branding ──────────────────────────────────────
  // TODO: Add actual logo files
  static const String appLogo        = 'assets/images/logo.png';
  static const String appLogoWhite   = 'assets/images/logo_white.png';
  static const String appLogoDark    = 'assets/images/logo_dark.png';
  static const String splashBg       = 'assets/images/splash_bg.png';

  // ── Onboarding illustrations ──────────────────────────
  // TODO: Add onboarding art
  static const String onboardingArt1 = 'assets/images/onboarding_1.png';
  static const String onboardingArt2 = 'assets/images/onboarding_2.png';
  static const String onboardingArt3 = 'assets/images/onboarding_3.png';

  // ── Icons ─────────────────────────────────────────────
  // TODO: Add custom icon files
  static const String iconGoogle     = 'assets/icons/google.png';
  static const String iconBanjara    = 'assets/icons/banjara_symbol.png';
  static const String iconKundali    = 'assets/icons/kundali.png';
  static const String iconVip        = 'assets/icons/vip_crown.png';
  static const String iconVerified   = 'assets/icons/verified.png';

  // ── Lottie animations ─────────────────────────────────
  // TODO: Add .json Lottie files
  // Package: lottie: ^x.x.x
  static const String lottieHeart       = 'assets/animations/heart.json';
  static const String lottieCelebration = 'assets/animations/celebration.json';
  static const String lottieLoading     = 'assets/animations/loading.json';
  static const String lottieEmpty       = 'assets/animations/empty.json';
  static const String lottieSuccess     = 'assets/animations/success.json';
  static const String lottieMatch       = 'assets/animations/match.json';

  // ══════════════════════════════════════════════════════════
  // 🔤 FONT FAMILIES
  // Declare in pubspec.yaml under flutter > fonts
  // ══════════════════════════════════════════════════════════
  static const String fontCormorant = 'Cormorant Garamond';
  static const String fontPoppins   = 'Poppins';

  // ══════════════════════════════════════════════════════════
  // 🔗 EXTERNAL URLS
  // ══════════════════════════════════════════════════════════
  static const String privacyPolicyUrl   = 'https://banjaravivah.com/privacy';
  static const String termsOfServiceUrl  = 'https://banjaravivah.com/terms';
  static const String helpCenterUrl      = 'https://banjaravivah.com/help';
  static const String playStoreUrl       = 'https://play.google.com/store/apps/details?id=com.banjaravivah.app';
  static const String appStoreUrl        = 'https://apps.apple.com/app/banjara-vivah';
  static const String supportEmail       = 'support@banjaravivah.com';
  static const String whatsappSupport    = 'https://wa.me/919876543210';
}