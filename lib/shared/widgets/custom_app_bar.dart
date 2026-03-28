import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/haptic_utils.dart';

// ============================================================
// 🔝 CUSTOM APP BAR
// Standard top app bar used across all screens.
// Supports: title, subtitle, back button, actions, badge.
//
// Usage:
//   appBar: const CustomAppBar(title: 'Settings')
//   appBar: CustomAppBar(
//     title: 'Notifications',
//     badge: 3,
//     actions: [IconButton(...)],
//   )
//   appBar: CustomAppBar(
//     title: 'My Profile',
//     subtitle: 'Manage your account',
//     showBackButton: false,
//   )
// ============================================================
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showBackButton = true,
    this.badge,
    this.onBackTap,
    this.centerTitle = false,
    this.backgroundColor,
  });

  /// Main title text
  final String title;

  /// Optional subtitle shown below the title in smaller text
  final String? subtitle;

  /// Action widgets shown on the right (icons, buttons)
  final List<Widget>? actions;

  /// Whether to show the back button on the left
  final bool showBackButton;

  /// Unread count badge shown next to the title (e.g. notifications)
  final int? badge;

  /// Custom back tap handler — defaults to context.pop()
  final VoidCallback? onBackTap;

  /// Center the title — default false (left-aligned)
  final bool centerTitle;

  /// Override background color — default transparent
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      leading: showBackButton ? _BackButton(onTap: onBackTap) : null,
      title: _AppBarTitle(
        title: title,
        subtitle: subtitle,
        badge: badge,
        centerTitle: centerTitle,
      ),
      actions: actions != null
          ? [
        ...actions!,
        const SizedBox(width: 8),
      ]
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    subtitle != null ? kToolbarHeight + 10 : kToolbarHeight,
  );
}


// ── Back Button ───────────────────────────────────────────────
class _BackButton extends StatelessWidget {
  const _BackButton({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            HapticUtils.lightImpact();
            if (onTap != null) {
              onTap!();
            } else if (context.canPop()) {
              context.pop();
            }
          },
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: AppTheme.softShadow,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppTheme.brandDark,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}


// ── Title + Subtitle + Badge ──────────────────────────────────
class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle({
    required this.title,
    this.subtitle,
    this.badge,
    this.centerTitle = false,
  });

  final String title;
  final String? subtitle;
  final int? badge;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    final hasBadge = badge != null && badge! > 0;

    return Column(
      crossAxisAlignment:
      centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.brandDark,
                  letterSpacing: -0.3,
                  height: 1.1,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasBadge) ...[
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
                    fontSize: 11,
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
          Text(
            subtitle!,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),
          ),
      ],
    );
  }
}