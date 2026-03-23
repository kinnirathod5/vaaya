import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'custom_network_image.dart';

// ============================================================
// 👤 PREMIUM AVATAR
// Circular profile photo with online dot, premium badge,
// and initials fallback when no image is available.
//
// Usage:
//   PremiumAvatar(imageUrl: url)
//
//   PremiumAvatar(
//     imageUrl: url,
//     size: 56,
//     isOnline: true,
//     isPremium: true,
//   )
//
//   PremiumAvatar(
//     imageUrl: '',
//     initials: 'PR',   // shows initials if image is empty
//     size: 44,
//   )
//
//   PremiumAvatar(
//     imageUrl: url,
//     showRing: true,   // brand color ring — for stories / active now
//   )
// ============================================================
class PremiumAvatar extends StatelessWidget {
  const PremiumAvatar({
    super.key,
    required this.imageUrl,
    this.size = 50,
    this.isOnline = false,
    this.isPremium = false,
    this.showRing = false,
    this.initials,
    this.ringColor,
  });

  /// Remote image URL — pass empty string to show initials fallback
  final String imageUrl;

  /// Diameter of the avatar (default: 50)
  final double size;

  /// Show green online dot at bottom-right
  final bool isOnline;

  /// Show gold diamond badge at bottom-right
  /// Note: isPremium takes priority over isOnline if both are true
  final bool isPremium;

  /// Show a colored ring around the avatar — used for stories / active now
  final bool showRing;

  /// 1–2 character initials shown when imageUrl is empty
  final String? initials;

  /// Ring color override — defaults to brandPrimary
  final Color? ringColor;

  @override
  Widget build(BuildContext context) {
    final ringWidth = showRing ? size * 0.06 : 0.0;
    final ringGap   = showRing ? size * 0.04 : 0.0;
    final photoSize = showRing
        ? size - (ringWidth + ringGap) * 2
        : size;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [

          // ── Ring ────────────────────────────────────
          if (showRing)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ringColor ?? AppTheme.brandPrimary,
                    ringColor?.withValues(alpha: 0.60) ??
                        AppTheme.brandPrimary.withValues(alpha: 0.60),
                  ],
                ),
              ),
            ),

          // ── Photo or initials ────────────────────────
          imageUrl.isNotEmpty
              ? CustomNetworkImage(
            imageUrl: imageUrl,
            width: photoSize,
            height: photoSize,
            borderRadius: photoSize / 2,
          )
              : _InitialsFallback(
            size: photoSize,
            initials: initials,
          ),

          // ── Premium badge (priority over online dot) ─
          if (isPremium)
            Positioned(
              bottom: 0,
              right: 0,
              child: _PremiumBadge(parentSize: size),
            )

          // ── Online dot ───────────────────────────────
          else if (isOnline)
            Positioned(
              bottom: showRing ? ringWidth : 0,
              right:  showRing ? ringWidth : 0,
              child: _OnlineDot(parentSize: size),
            ),
        ],
      ),
    );
  }
}


// ── Online dot ────────────────────────────────────────────────
class _OnlineDot extends StatelessWidget {
  const _OnlineDot({required this.parentSize});
  final double parentSize;

  @override
  Widget build(BuildContext context) {
    final dotSize = parentSize * 0.27;
    return Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: const Color(0xFF4ADE80),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: dotSize * 0.18,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4ADE80).withValues(alpha: 0.40),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}


// ── Premium gold badge ────────────────────────────────────────
class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge({required this.parentSize});
  final double parentSize;

  @override
  Widget build(BuildContext context) {
    final badgeSize = parentSize * 0.30;
    return Container(
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppTheme.goldGradient,
        border: Border.all(
          color: Colors.white,
          width: badgeSize * 0.14,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.goldPrimary.withValues(alpha: 0.40),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Icon(
        Icons.diamond_rounded,
        color: Colors.white,
        size: badgeSize * 0.55,
      ),
    );
  }
}


// ── Initials fallback ─────────────────────────────────────────
class _InitialsFallback extends StatelessWidget {
  const _InitialsFallback({required this.size, this.initials});
  final double size;
  final String? initials;

  @override
  Widget build(BuildContext context) {
    final text = initials?.isNotEmpty == true
        ? initials!.substring(0, initials!.length.clamp(0, 2)).toUpperCase()
        : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.brandPrimary.withValues(alpha: 0.80),
            AppTheme.brandPrimary,
          ],
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: size * 0.32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1,
          ),
        ),
      ),
    );
  }
}