import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

// ============================================================
// 🪟 PREMIUM GLASS APP BAR
// Frosted glass top bar — floats over scrollable content.
// Used on screens where content scrolls behind the header.
//
// Difference from CustomAppBar:
//   CustomAppBar      → standard opaque bar, standard screens
//   PremiumGlassAppBar → frosted glass, home/chat/profile screens
//
// Usage:
//   appBar: PremiumGlassAppBar(title: 'Messages')
//
//   appBar: PremiumGlassAppBar(
//     title: 'Home',
//     subtitle: 'Good morning, Rahul',
//     leading: _avatarButton,
//     actions: [_notifButton],
//     statusBarBrightness: Brightness.dark,
//   )
// ============================================================
class PremiumGlassAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const PremiumGlassAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.statusBarBrightness = Brightness.dark,
    this.blurSigma = 24.0,
    this.backgroundColor,
    this.showBottomBorder = true,
  });

  /// Main heading
  final String title;

  /// Optional subtitle shown below title in smaller text
  final String? subtitle;

  /// Custom leading widget — defaults to empty spacer
  final Widget? leading;

  /// Action widgets on the right
  final List<Widget>? actions;

  /// Center the title (default: true)
  final bool centerTitle;

  /// Status bar icon color (default: dark — for light backgrounds)
  final Brightness statusBarBrightness;

  /// Blur amount (default: 24)
  final double blurSigma;

  /// Override glass tint color — defaults to white
  final Color? backgroundColor;

  /// Show bottom divider line (default: true)
  final bool showBottomBorder;

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitle != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: statusBarBrightness,
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            decoration: BoxDecoration(
              color: (backgroundColor ?? Colors.white)
                  .withValues(alpha: 0.86),
              border: showBottomBorder
                  ? Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.55),
                  width: 1,
                ),
              )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: hasSubtitle
                    ? kToolbarHeight + 10
                    : kToolbarHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      // ── Leading ────────────────────────
                      SizedBox(
                        width: 52,
                        child: leading ?? const SizedBox.shrink(),
                      ),

                      // ── Title + subtitle ───────────────
                      Expanded(
                        child: centerTitle
                            ? Center(child: _TitleContent(
                          title: title,
                          subtitle: subtitle,
                          centerTitle: true,
                        ))
                            : _TitleContent(
                          title: title,
                          subtitle: subtitle,
                          centerTitle: false,
                        ),
                      ),

                      // ── Actions ────────────────────────
                      SizedBox(
                        width: 52,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: actions ?? [const SizedBox.shrink()],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    subtitle != null ? kToolbarHeight + 10 : kToolbarHeight,
  );
}


// ── Title + subtitle ──────────────────────────────────────────
class _TitleContent extends StatelessWidget {
  const _TitleContent({
    required this.title,
    this.subtitle,
    required this.centerTitle,
  });

  final String title;
  final String? subtitle;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: centerTitle
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
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
        if (subtitle != null)
          Text(
            subtitle!,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: Colors.grey.shade500,
              height: 1.2,
            ),
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}