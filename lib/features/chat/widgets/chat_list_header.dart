import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// ============================================================
// 🎩 CHAT LIST HEADER
// Title + unread count + search icon toggle + compose icon
// ============================================================
class ChatListHeader extends StatelessWidget {
  const ChatListHeader({
    super.key,
    required this.unreadCount,
    required this.searchOpen,
    required this.onSearchTap,
  });

  final int unreadCount;
  final bool searchOpen;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Messages',
                  style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.brandDark,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  unreadCount > 0
                      ? '$unreadCount unread messages'
                      : 'All caught up',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Search icon — toggles search bar
          _HeaderBtn(
            icon: searchOpen
                ? Icons.close_rounded
                : Icons.search_rounded,
            isActive: searchOpen,
            onTap: onSearchTap,
          ),
          const SizedBox(width: 8),

          // Compose icon
          _HeaderBtn(
            icon: Icons.edit_outlined,
            isActive: false,
            onTap: () {}, // TODO: new conversation
          ),
        ],
      ),
    );
  }
}


class _HeaderBtn extends StatelessWidget {
  const _HeaderBtn({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: isActive ? AppTheme.brandPrimary : Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: isActive
                ? AppTheme.brandPrimary
                : AppTheme.brandPrimary.withValues(alpha: 0.12),
          ),
          boxShadow: isActive ? AppTheme.primaryGlow : AppTheme.softShadow,
        ),
        child: Icon(
          icon,
          size: 19,
          color: isActive ? Colors.white : AppTheme.brandDark,
        ),
      ),
    );
  }
}