import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 🔥 Humare Premium Lego Blocks & Theme
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_utils.dart';

// 🚀 Saari 5 Screens ke Imports
import '../../home/screens/home_screen.dart';
import '../../matches/screens/matches_screen.dart';
import '../../interests/screens/interests_screen.dart';
import '../../chat/screens/chat_list_screen.dart';
import '../../premium/screens/upgrade_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  // 🔥 THE ACTUAL LIST OF SCREENS
  final List<Widget> _screens = [
    const HomeScreen(),      // Index 0: Dashboard
    const MatchesScreen(),   // Index 1: Find Matches
    const InterestsScreen(), // Index 2: Likes/Requests
    const ChatListScreen(),  // Index 3: Messages
    const UpgradeScreen(),   // Index 4: VIP/Premium
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgScaffold,

      // 🔥 Content will scroll behind the frosted glass nav bar
      extendBody: true,

      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      // 🔥 FIXED DOCKED NAVIGATION BAR (As per your brilliant design)
      bottomNavigationBar: _buildDockedGlassNavBar(),
    );
  }

  Widget _buildDockedGlassNavBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            // 🔥 Sirf top par ek subtle border, premium finish ke liye
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.6), width: 1.5)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))
            ],
          ),
          // 🔥 SafeArea automatically iOS ke home indicator / Android gestures ki jagah chhod dega
          child: SafeArea(
            top: false,
            child: Container(
              height: 65, // Ekdum sleek height
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(icon: Icons.home_filled, index: 0, label: 'Home'),
                  _buildNavItem(icon: Icons.grid_view_rounded, index: 1, label: 'Matches'),
                  _buildNavItem(icon: Icons.favorite_rounded, index: 2, label: 'Likes', badgeCount: 12),
                  _buildNavItem(icon: Icons.chat_bubble_rounded, index: 3, label: 'Chat', badgeCount: 3),
                  _buildPremiumNavItem(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- UPGRADED NAVIGATION ICON WITH PILL & BADGES ---
  Widget _buildNavItem({required IconData icon, required int index, required String label, int badgeCount = 0}) {
    bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        HapticUtils.selectionClick();
        setState(() => _currentIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 12 : 8, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.brandPrimary.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppTheme.brandPrimary : Colors.grey.shade400,
                  size: 26, // 🔥 Thoda bada kiya solid feel ke liye
                ),

                // NOTIFICATION BADGE
                if (badgeCount > 0)
                  Positioned(
                    top: -4, right: -6,
                    child: AnimatedScale(
                      scale: isSelected ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE94057),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: [BoxShadow(color: const Color(0xFFE94057).withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 2))],
                        ),
                        child: Text(
                          badgeCount > 9 ? '9+' : badgeCount.toString(),
                          style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, height: 1),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // 🔥 Sliding Text Label
            AnimatedSize(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: isSelected ? null : 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    style: const TextStyle(fontFamily: 'Poppins', color: AppTheme.brandPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- VIP PREMIUM NAVIGATION ICON ---
  Widget _buildPremiumNavItem() {
    bool isSelected = _currentIndex == 4;

    return GestureDetector(
      onTap: () {
        HapticUtils.heavyImpact();
        setState(() => _currentIndex = 4);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E1E1E).withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(colors: [Color(0xFF1E1E1E), Color(0xFF3A3D45)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                : LinearGradient(colors: [const Color(0xFFFFDF00).withOpacity(0.3), const Color(0xFFD4AF37).withOpacity(0.2)]),
            shape: BoxShape.circle,
            boxShadow: [
              if (isSelected) BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
              if (!isSelected) BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.15), blurRadius: 15, spreadRadius: 2),
            ],
            border: isSelected ? Border.all(color: const Color(0xFFFFD700).withOpacity(0.5), width: 1.5) : null,
          ),
          child: Icon(
            Icons.diamond_rounded,
            color: isSelected ? const Color(0xFFFFD700) : const Color(0xFFB8860B),
            size: 20, // 🔥 VIP icon thoda aur sharp kiya
          ),
        ),
      ),
    );
  }
}