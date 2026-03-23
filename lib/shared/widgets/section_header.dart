import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/haptic_utils.dart';

// ============================================================
// 📌 SECTION HEADER
// Reusable section title row with optional subtitle,
// action button, count badge, and leading icon.
//
// Usage:
//   SectionHeader(title: 'Daily Matches')
//
//   SectionHeader(
//     title: 'Spotlight',
//     subtitle: 'Highly compatible profiles',
//     actionText: 'View All',
//     onActionTap: () => context.push('/matches'),
//   )
//
//   SectionHeader(
//     title: 'New Interests',
//     badge: 3,
//   )
//
//   SectionHeader(
//     title: 'Success Stories',
//     icon: Icons.favorite_rounded,
//   )
// ============================================================
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onActionTap,
    this.badge,
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  /// Main heading text
  final String title;

  /// Optional small grey subtitle below the title
  final String? subtitle;

  /// Right-side action label (e.g. "View All", "See More")
  final String? actionText;

  final VoidCallback? onActionTap;

  /// Count badge shown next to title (e.g. unread count)
  final int? badge;

  /// Optional leading icon before the title
  final IconData? icon;

  /// Outer padding — override for custom screen layouts
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // ── Leading icon ────────────────────────────
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppTheme.brandPrimary),
            const SizedBox(width: 7),
          ],

          // ── Title + subtitle + badge ─────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.brandDark,
                          letterSpacing: -0.2,
                          height: 1.1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Count badge
                    if (badge != null && badge! > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.brandPrimary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badge! > 99 ? '99+' : '$badge',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Subtitle
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),

          // ── Action button ─────────────────────────────
          if (actionText != null && onActionTap != null)
            GestureDetector(
              onTap: () {
                HapticUtils.lightImpact();
                onActionTap!();
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionText!,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.brandPrimary,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: AppTheme.brandPrimary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}