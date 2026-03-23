import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class InterestsTabBar extends StatelessWidget {
  const InterestsTabBar({
    super.key,
    required this.controller,
    required this.receivedCount,
    required this.sentCount,
  });

  final TabController controller;
  final int receivedCount;
  final int sentCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          return Row(
            children: [
              _TabPill(
                label: 'Received',
                count: receivedCount,
                icon: Icons.favorite_rounded,
                isActive: controller.index == 0,
                onTap: () => controller.animateTo(0),
              ),
              const SizedBox(width: 10),
              _TabPill(
                label: 'Sent',
                count: sentCount,
                icon: Icons.send_rounded,
                isActive: controller.index == 1,
                onTap: () => controller.animateTo(1),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.count,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final int count;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          height: 48,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.brandPrimary : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? AppTheme.brandPrimary
                  : AppTheme.brandPrimary.withValues(alpha: 0.12),
              width: 1.5,
            ),
            boxShadow: isActive
                ? [BoxShadow(
              color: AppTheme.brandPrimary.withValues(alpha: 0.28),
              blurRadius: 14,
              offset: const Offset(0, 5),
            )]
                : AppTheme.softShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isActive ? Colors.white : AppTheme.brandPrimary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isActive ? Colors.white : AppTheme.brandDark,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.22)
                      : const Color(0xFFFAE4E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isActive ? Colors.white : AppTheme.brandPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ============================================================
// 🏷️ SECTION DIVIDER LABEL
// Section heading with emoji + optional count
// ============================================================