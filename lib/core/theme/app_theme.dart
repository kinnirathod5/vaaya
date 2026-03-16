import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🎨 1. Premium Brand Colors (Aapke design se liye gaye)
  static const Color brandPrimary = Color(0xFFF23B5F); // Pinkish-Red
  static const Color brandDark = Color(0xFF2A2D34);    // Deep Dark Grey for Text
  static const Color bgScaffold = Color(0xFFF4F7FC);   // Premium Off-white/Greyish background
  static const Color surfaceWhite = Colors.white;

  // Keep old variable names for backward compatibility with existing code
  static const Color primaryColor = brandPrimary;
  static const Color secondaryColor = brandDark;
  static const Color backgroundColor = bgScaffold;
  static const Color textPrimary = brandDark;
  static const Color textSecondary = Color(0xFF757575);

  // 🛠️ 2. Light Theme Setup
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bgScaffold,
      primaryColor: brandPrimary,
      colorScheme: const ColorScheme.light(
        primary: brandPrimary,
        secondary: brandDark,
        surface: surfaceWhite,
        background: bgScaffold,
      ),

      // 📝 3. Typography (Poppins Font with your specific weights and spacing)
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        // Badi headings ke liye (e.g., "Let's start with the basics.")
        displayLarge: GoogleFonts.poppins(
          color: brandDark,
          fontSize: 32,
          fontWeight: FontWeight.w900,
          height: 1.2,
          letterSpacing: -0.5,
        ),
        // Normal text aur subtitles ke liye
        bodyLarge: GoogleFonts.poppins(
          color: brandDark,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.poppins(
          color: Colors.grey.shade500,
          fontSize: 14,
        ),
        // Chhote Labels ke liye (e.g., "FIRST NAME")
        labelSmall: GoogleFonts.poppins(
          color: Colors.grey.shade400,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),

      // 🔘 4. Primary Button Theme (Aapka Glow wala Bottom Button)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandPrimary,
          foregroundColor: Colors.white,
          elevation: 8, // Soft shadow
          shadowColor: brandPrimary.withOpacity(0.5),
          minimumSize: const Size(double.infinity, 60), // 60px height
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // 20px radius
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),

      // 🔤 5. TextField Theme (Aapka clean, white input box)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: GoogleFonts.poppins(
          color: Colors.grey.shade300,
          fontWeight: FontWeight.normal,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: brandPrimary, width: 2),
        ),
      ),
    );
  }

  // ✨ 6. Custom Shadows (Aapke cards ke liye reusable shadows)
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      blurRadius: 10,
      offset: const Offset(0, 5),
    )
  ];

  static List<BoxShadow> get heavyShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 20,
      offset: const Offset(0, 10),
    )
  ];

  static List<BoxShadow> get primaryGlow => [
    BoxShadow(
      color: brandPrimary.withOpacity(0.3),
      blurRadius: 15,
      offset: const Offset(0, 8),
    )
  ];
}
