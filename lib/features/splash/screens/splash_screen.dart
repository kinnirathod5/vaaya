import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 🔥 Humara Theme Import
import '../../../core/theme/app_theme.dart';

// 🚀 Login Screen ka import (Path folder structure ke hisaab se)
import '../../auth/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// SingleTickerProviderStateMixin animation ke liye zaroori hai
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // ✨ Premium Touch: Splash screen par status bar transparent kar rahe hain
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // 🎬 Animation Controller Setup (1.5 seconds ka smooth animation)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // 💓 Scale Animation: Chote se bada hoke thoda bounce karega (Heartbeat jaisa)
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut, // Yeh curve Bumble/Tinder jaisa bounce deta hai
      ),
    );

    // 🌫️ Fade Animation: Dheere dheere screen par aayega
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // Animation start karein
    _animationController.forward();

    // ⏱️ 3 Seconds ke baad Login screen par bhejne ka timer
    Timer(const Duration(seconds: 3), () {
      _navigateToNextScreen();
    });
  }

  void _navigateToNextScreen() {
    // Haptic feedback ek premium feel ke liye
    HapticFeedback.lightImpact();

    // 🔥 Yahan hum user ko seedha Login Screen par bhej rahe hain
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Smooth Fade Transition
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🎨 Background poora Pinkish-Red hoga
      backgroundColor: AppTheme.brandPrimary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 💖 Premium Logo Container (Glassmorphism effect ke sath)
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15), // Semi-transparent white
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  // Abhi icon use kar rahe hain. Baad mein yahan aapki Image aayegi
                  child: const Icon(
                    Icons.favorite_rounded, // App ka ek premium symbol
                    color: Colors.white,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 25),

                // 🔤 Brand Name
                const Text(
                  'Banjara Vivah',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 8),

                // ✨ Tagline
                Text(
                  'Find Your Perfect Match',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}