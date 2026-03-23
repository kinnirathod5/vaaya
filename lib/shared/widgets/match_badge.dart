import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// ============================================================
// 💯 MATCH BADGE
// Glowing pill showing compatibility percentage.
// Color automatically adjusts based on match quality.
//
// Tiers:
//   90–100% → Purple-pink gradient  (Excellent)
//   75–89%  → Brand pink gradient   (Great)
//   60–74%  → Amber gradient        (Good)
//   < 60%   → Grey, no glow         (Low)
//
// Sizes:
//   BadgeSize.small  → compact, for grid cards
//   BadgeSize.medium → standard (default)
//   BadgeSize.large  → for user detail screen header
//
// Usage:
//   MatchBadge(percent: 98)
//   MatchBadge(percent: 84, size: BadgeSize.small)
//   MatchBadge(percent: 92, size: BadgeSize.large, showIcon: false)
// ============================================================

enum BadgeSize { small, medium, large }

class MatchBadge extends StatelessWidget {
  const MatchBadge({
    super.key,
    required this.percent,
    this.size = BadgeSize.medium,
    this.showIcon = true,
  });

  /// Match percentage value (0–100)
  final int percent;

  final BadgeSize size;

  /// Show flame icon before the percentage (default: true)
  final bool showIcon;

  // ── Color tier ────────────────────────────────────────────
  List<Color> get _colors {
    if (percent >= 90) return [const Color(0xFF7C3AED), AppTheme.brandPrimary];
    if (percent >= 75) return [AppTheme.brandPrimary, const Color(0xFFFF6B84)];
    if (percent >= 60) return [const Color(0xFFD97706), const Color(0xFFF59E0B)];
    return [Colors.grey.shade400, Colors.grey.shade400];
  }

  Color get _glow {
    if (percent >= 90) return const Color(0xFF7C3AED);
    if (percent >= 75) return AppTheme.brandPrimary;
    if (percent >= 60) return const Color(0xFFD97706);
    return Colors.transparent;
  }

  bool get _isLow => percent < 60;

  // ── Size config ───────────────────────────────────────────
  double get _fontSize     => size == BadgeSize.small ? 9  : size == BadgeSize.medium ? 11 : 14;
  double get _iconSize     => size == BadgeSize.small ? 10 : size == BadgeSize.medium ? 13 : 16;
  double get _borderRadius => size == BadgeSize.small ? 10 : size == BadgeSize.medium ? 14 : 18;
  double get _spacing      => size == BadgeSize.small ? 3  : 5;

  EdgeInsets get _padding => switch (size) {
    BadgeSize.small  => const EdgeInsets.symmetric(horizontal: 8,  vertical: 4),
    BadgeSize.medium => const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
    BadgeSize.large  => const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: _colors),
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: _isLow
            ? []
            : [
          BoxShadow(
            color: _glow.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Flame icon — hidden for low matches
          if (showIcon && !_isLow) ...[
            Icon(
              Icons.local_fire_department_rounded,
              color: Colors.white,
              size: _iconSize,
            ),
            SizedBox(width: _spacing),
          ],

          // Percentage
          Text(
            '$percent%',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: _fontSize,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1,
            ),
          ),
          SizedBox(width: _spacing - 1),

          // "match" label
          Text(
            'match',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: _fontSize - 1,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.80),
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}