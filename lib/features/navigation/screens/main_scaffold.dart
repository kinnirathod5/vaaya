import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_utils.dart';

import '../../home/screens/home_screen.dart';
import '../../matches/screens/matches_screen.dart';
import '../../interests/screens/interests_screen.dart';
import '../../chat/screens/chat_list_screen.dart';
import '../../premium/screens/upgrade_screen.dart';

// ============================================================
// 🧭 MAIN SCAFFOLD
// Root shell — hosts all 5 bottom nav tabs.
// Uses IndexedStack so screens retain their scroll state.
//
// Tabs:
//   0 → Home         (HomeScreen)
//   1 → Matches      (MatchesScreen)
//   2 → Interests    (InterestsScreen)   — badge: received count
//   3 → Chat         (ChatListScreen)    — badge: unread count
//   4 → Premium      (UpgradeScreen)     — gold VIP button
//
// TODO: Replace dummy badge counts with Riverpod providers:
//   interestsProvider.receivedCount
//   chatProvider.totalUnreadCount
// ============================================================
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {

  int _currentIndex = 0;

  // Dummy badge counts — TODO: replace with providers
  static const int _interestsBadge = 3;
  static const int _chatBadge      = 2;

  static const List<Widget> _screens = [
    HomeScreen(),
    MatchesScreen(),
    InterestsScreen(),
    ChatListScreen(),
    UpgradeScreen(),
  ];

  void _onTabTap(int index) {
    if (index == _currentIndex) return;
    // Premium tab gets heavier feedback — feels more significant
    if (index == 4) {
      HapticUtils.heavyImpact();
    } else {
      HapticUtils.selectionClick();
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgScaffold,
      extendBody: true, // Content scrolls behind frosted nav bar
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _NavBar(
        currentIndex: _currentIndex,
        interestsBadge: _interestsBadge,
        chatBadge: _chatBadge,
        onTap: _onTabTap,
      ),
    );
  }
}


// ══════════════════════════════════════════════════════════
// NAV BAR — frosted glass, pill indicator, sliding label
// ══════════════════════════════════════════════════════════
class _NavBar extends StatelessWidget {
  const _NavBar({
    required this.currentIndex,
    required this.interestsBadge,
    required this.chatBadge,
    required this.onTap,
  });

  final int currentIndex;
  final int interestsBadge;
  final int chatBadge;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.86),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.55),
                width: 1.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 62,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [

                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    index: 0,
                    isSelected: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),

                  _NavItem(
                    icon: Icons.grid_view_rounded,
                    label: 'Matches',
                    index: 1,
                    isSelected: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),

                  _NavItem(
                    icon: Icons.favorite_rounded,
                    label: 'Interests',
                    index: 2,
                    isSelected: currentIndex == 2,
                    badge: interestsBadge,
                    onTap: () => onTap(2),
                  ),

                  _NavItem(
                    icon: Icons.chat_bubble_rounded,
                    label: 'Chat',
                    index: 3,
                    isSelected: currentIndex == 3,
                    badge: chatBadge,
                    onTap: () => onTap(3),
                  ),

                  _PremiumNavItem(
                    isSelected: currentIndex == 4,
                    onTap: () => onTap(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// ── Standard nav item ─────────────────────────────────────────
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.isSelected,
    required this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final String label;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.brandPrimary.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            // Icon + badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected
                      ? AppTheme.brandPrimary
                      : Colors.grey.shade400,
                ),

                // Badge — hidden when tab is selected
                if (badge > 0)
                  Positioned(
                    top: -4, right: -6,
                    child: AnimatedScale(
                      scale: isSelected ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppTheme.brandPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.brandPrimary.withValues(alpha: 0.35),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          badge > 9 ? '9+' : '$badge',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Sliding label — appears when selected
            AnimatedSize(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: isSelected ? null : 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppTheme.brandPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ── Premium (VIP) nav item ────────────────────────────────────
class _PremiumNavItem extends StatelessWidget {
  const _PremiumNavItem({
    required this.isSelected,
    required this.onTap,
  });

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          width: 44, height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isSelected
                ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A0814), Color(0xFF2D1020)],
            )
                : LinearGradient(
              colors: [
                const Color(0xFFFFDF00).withValues(alpha: 0.28),
                const Color(0xFFD4AF37).withValues(alpha: 0.18),
              ],
            ),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFFFD700).withValues(alpha: 0.55)
                  : const Color(0xFFD4AF37).withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? Colors.black.withValues(alpha: 0.20)
                    : const Color(0xFFFFD700).withValues(alpha: 0.18),
                blurRadius: isSelected ? 10 : 14,
                spreadRadius: isSelected ? 0 : 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            Icons.diamond_rounded,
            size: 20,
            color: isSelected
                ? const Color(0xFFFFD700)
                : const Color(0xFFB8860B),
          ),
        ),
      ),
    );
  }
}