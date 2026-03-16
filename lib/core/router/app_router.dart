import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 🔥 JITNI SCREENS BAN CHUKI HAIN, UNKE IMPORTS:
import '../../features/splash/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_verification_screen.dart';
import '../../features/onboarding/screens/account_creation_screen.dart';
import '../../features/navigation/screens/main_scaffold.dart';
import '../../features/profile/screens/user_detail_screen.dart';
import '../../features/chat/screens/chat_detail_screen.dart';
import '../../features/profile/screens/my_profile_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';

// ✨ NAYA IMPORT: Humari Premium Edit Profile Screen
import '../../features/profile/screens/edit_profile_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // 1. Splash Screen
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

      // 2. Auth Flow
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey, child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/otp',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey, child: const OtpVerificationScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(position: animation.drive(Tween(begin: const Offset(0.0, 0.2), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic))), child: FadeTransition(opacity: animation, child: child));
          },
        ),
      ),

      // 3. Onboarding (Account Creation)
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey, child: const AccountCreationScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
        ),
      ),

      // 4. MAIN DASHBOARD (Wrapper for Home, Matches, etc.)
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const MainScaffold(),
      ),

      // 5. Chat Detail Screen
      GoRoute(
        path: '/chat_detail',
        builder: (context, state) => const ChatDetailScreen(),
      ),

      // 6. User Profile Detail (Kisi aur ki profile dekhna)
      GoRoute(
        path: '/user_detail',
        builder: (context, state) => const UserDetailScreen(),
      ),

      // 7. My Profile Screen (Apni profile dekhna aur manage karna)
      GoRoute(
        path: '/my_profile',
        builder: (context, state) => const MyProfileScreen(),
      ),

      // 8. Settings Screen
      GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen()
      ),

      // 9. Notifications Screen
      GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen()
      ),

      // 10. Edit Profile Screen
      // 🔥 YAHAN UPDATE KIYA HAI: Dummy screen hata kar asli screen lagayi
      GoRoute(
          path: '/edit_profile',
          builder: (context, state) => const EditProfileScreen()
      ),
    ],
  );
}

// 🚧 DUMMY SCREEN (Pichhli bachi hui screens ke liye placeholder, in case future me zaroorat pade)
class DummyScreen extends StatelessWidget {
  final String title;
  const DummyScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text("$title\nComing Soon!", textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
    );
  }
}