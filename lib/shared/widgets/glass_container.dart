import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// ============================================================
// 🪟 GLASS CONTAINER
// Frosted glass effect using BackdropFilter.
// Used for overlays, badges, cards on photo backgrounds.
//
// Variants:
//   GlassVariant.light   → white tint — on dark backgrounds (default)
//   GlassVariant.dark    → black tint — on light backgrounds
//   GlassVariant.brand   → brand pink tint — active/selected states
//   GlassVariant.gold    → gold tint — premium sections
//   GlassVariant.success → green tint — verified/confirmed states
//
// Usage:
//   GlassContainer(child: Text('98% match'))
//
//   GlassContainer(
//     variant: GlassVariant.dark,
//     blur: 14,
//     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//     borderRadius: BorderRadius.circular(10),
//     child: Row(children: [...]),
//   )
//
//   // Pill badge on photo
//   GlassContainer(
//     blur: 8,
//     opacity: 0.30,
//     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//     borderRadius: BorderRadius.circular(20),
//     child: Text('Active now'),
//   )
// ============================================================

enum GlassVariant { light, dark, brand, gold, success }

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.variant = GlassVariant.light,
    this.blur = 10.0,
    this.opacity = 0.20,
    this.borderRadius,
    this.padding,
    this.showBorder = true,
    this.width,
    this.height,
  });

  final Widget child;

  /// Color tint variant
  final GlassVariant variant;

  /// Blur sigma — higher = more frosted (default: 10)
  final double blur;

  /// Fill opacity — keep low for true glass feel (default: 0.20)
  final double opacity;

  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;

  /// Show a subtle border (default: true)
  final bool showBorder;

  final double? width;
  final double? height;

  // ── Tint color ────────────────────────────────────────────
  Color get _tintColor {
    switch (variant) {
      case GlassVariant.light:
        return Colors.white.withValues(alpha: opacity);
      case GlassVariant.dark:
        return Colors.black.withValues(alpha: opacity);
      case GlassVariant.brand:
        return AppTheme.brandPrimary.withValues(alpha: opacity);
      case GlassVariant.gold:
        return AppTheme.goldPrimary.withValues(alpha: opacity);
      case GlassVariant.success:
        return AppTheme.success.withValues(alpha: opacity);
    }
  }

  Color get _borderColor {
    switch (variant) {
      case GlassVariant.light:
        return Colors.white.withValues(alpha: 0.35);
      case GlassVariant.dark:
        return Colors.white.withValues(alpha: 0.12);
      case GlassVariant.brand:
        return AppTheme.brandPrimary.withValues(alpha: 0.30);
      case GlassVariant.gold:
        return AppTheme.goldPrimary.withValues(alpha: 0.40);
      case GlassVariant.success:
        return AppTheme.success.withValues(alpha: 0.35);
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(14);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _tintColor,
            borderRadius: radius,
            border: showBorder
                ? Border.all(color: _borderColor, width: 1)
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}