import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ── Splash ────────────────────────────────────────────────
import '../../features/splash/screens/splash_screen.dart';

// ── Auth ──────────────────────────────────────────────────
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_verification_screen.dart';

// ── Onboarding ────────────────────────────────────────────
import '../../features/onboarding/screens/account_creation_screen.dart';

// ── Navigation Shell ──────────────────────────────────────
import '../../features/navigation/screens/main_scaffold.dart';

// ── Chat ──────────────────────────────────────────────────
import '../../features/chat/screens/chat_detail_screen.dart';

// ── Profile ───────────────────────────────────────────────
import '../../features/profile/screens/user_detail_screen.dart';
import '../../features/profile/screens/my_profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/settings_screen.dart';

// ── Notifications ─────────────────────────────────────────
import '../../features/notifications/screens/notifications_screen.dart';

// ── Premium ───────────────────────────────────────────────
import '../../features/premium/screens/upgrade_screen.dart';

// ============================================================
// 🛣️  APP ROUTER
//
// All routes defined in one place using GoRouter.
//
// Transition types:
//   _fadePage    → top-level screens  (splash, login, dashboard)
//   _slidePage   → sub-screens        (profile, chat, settings)
//   _slideUpPage → modal-feel screens (otp, edit profile, upgrade)
//
// Auth flow:
//   / → /login → /otp → /onboarding  (new user)
//                      → /dashboard   (existing user)
//   Guest → /dashboard (read-only, 3 free profiles then lock)
//
// TODO: Add auth redirect guard once Firebase Auth is connected:
//   redirect: (context, state) {
//     final loggedIn = ref.read(authProvider).isLoggedIn;
//     if (!loggedIn && state.matchedLocation != '/login') return '/login';
//     return null;
//   }
// ============================================================
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true, // TODO: Set to false before production release

    errorBuilder: (context, state) => _ErrorScreen(error: state.error),

    routes: [

      // 1. Splash
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),

      // 2. Login — single phone field, no separate signup,
      //    guest mode available (3 free profiles)
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),

      // 3. OTP Verification
      //    Phone number received via GoRouter extra from LoginScreen.
      //    Routes to /onboarding (new user) or /dashboard (existing user).
      GoRoute(
        path: '/otp',
        pageBuilder: (context, state) => _slideUpPage(
          key: state.pageKey,
          child: const OtpVerificationScreen(),
        ),
      ),

      // 4. Onboarding — 6-step account creation for new users only
      //    Steps: Name → Gender → Birthday → Height → Community → Photo + City
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const AccountCreationScreen(),
        ),
      ),

      // 5. Dashboard — MainScaffold hosts all 5 bottom nav tabs
      //    Tabs: Home / Matches / Interests / Chat / Premium
      GoRoute(
        path: '/dashboard',
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const MainScaffold(),
        ),
      ),

      // 6. Chat Detail — individual conversation
      GoRoute(
        path: '/chat_detail',
        pageBuilder: (context, state) => _slidePage(
          key: state.pageKey,
          child: const ChatDetailScreen(),
        ),
      ),

      // 7. User Detail — another user's full profile
      //    Includes: photo gallery, compatibility bars, interests, CTAs
      GoRoute(
        path: '/user_detail',
        pageBuilder: (context, state) => _slidePage(
          key: state.pageKey,
          child: const UserDetailScreen(),
        ),
      ),

      // 8. My Profile — current user's own profile view
      GoRoute(
        path: '/my_profile',
        pageBuilder: (context, state) => _slidePage(
          key: state.pageKey,
          child: const MyProfileScreen(),
        ),
      ),

      // 9. Edit Profile — 3-tab editor (Basic Info / About / Preferences)
      GoRoute(
        path: '/edit_profile',
        pageBuilder: (context, state) => _slideUpPage(
          key: state.pageKey,
          child: const EditProfileScreen(),
        ),
      ),

      // 10. Settings — Account, Privacy, Notifications, App, Support
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => _slidePage(
          key: state.pageKey,
          child: const SettingsScreen(),
        ),
      ),

      // 11. Notifications — grouped Today / Earlier, swipe to delete
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) => _slidePage(
          key: state.pageKey,
          child: const NotificationsScreen(),
        ),
      ),

      // 12. Premium Upgrade — plan selection, perks, testimonials
      GoRoute(
        path: '/premium',
        pageBuilder: (context, state) => _slideUpPage(
          key: state.pageKey,
          child: const UpgradeScreen(),
        ),
      ),

      // 13. Legacy redirect — /upgrade now resolves to /premium
      GoRoute(
        path: '/upgrade',
        redirect: (_, _) => '/premium',
      ),
    ],
  );

  // ── Transition helpers ────────────────────────────────────

  /// Fade only — for top-level context shifts
  static CustomTransitionPage<void> _fadePage({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: child,
        );
      },
    );
  }

  /// Slide from right + fade — for sub-screens
  static CustomTransitionPage<void> _slidePage({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 320),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: animation.drive(
            Tween(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic)),
          ),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.7),
            ),
            child: child,
          ),
        );
      },
    );
  }

  /// Slide up + fade — for modal-feel screens
  static CustomTransitionPage<void> _slideUpPage({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 380),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: animation.drive(
            Tween(
              begin: const Offset(0.0, 0.08),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic)),
          ),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: child,
          ),
        );
      },
    );
  }
}


// ============================================================
// ❌ ERROR SCREEN
// Shown when a route is not found
// ============================================================
class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({this.error});
  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120610),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFE8395A),
                  size: 56,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Page not found',
                  style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error?.toString() ?? 'This route does not exist.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.40),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8395A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                  ),
                  child: const Text(
                    'Go to Home',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
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