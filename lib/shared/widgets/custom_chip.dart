import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// ============================================================
// 💊 CUSTOM CHIP — v2.0
//
// Fixes over v1:
//   ✅ FIX 1 — borderRadius: 20 → 10
//              Was pill-shaped (oval) in screenshots
//              Compact, professional tag appearance
//   ✅ FIX 2 — GestureDetector → Material + InkWell
//              Proper ripple feedback on tap
//              Consistent with rest of app
//
// Variants:
//   ChipVariant.filled   → solid brand color when selected (default)
//   ChipVariant.outlined → border only when selected, no fill
//   ChipVariant.subtle   → light brand tint when selected
//
// Usage:
//   CustomChip(label: 'Rathod', isSelected: true, onTap: () {})
//   CustomChip(label: 'Online', icon: Icons.circle, isSelected: false)
//   CustomChip(label: 'Mumbai', count: 12, isSelected: true)
//   CustomChip(label: 'Premium', variant: ChipVariant.subtle, ...)
// ============================================================

enum ChipVariant { filled, outlined, subtle }

class CustomChip extends StatelessWidget {
  const CustomChip({
    super.key,
    required this.label,
    this.icon,
    this.isSelected = false,
    this.onTap,
    this.variant = ChipVariant.filled,
    this.count,
    this.enabled = true,
  });

  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final ChipVariant variant;
  final int? count;
  final bool enabled;

  // ── Computed colors ───────────────────────────────────────

  Color _backgroundColor() {
    if (!isSelected) return Colors.white;
    switch (variant) {
      case ChipVariant.filled:   return AppTheme.brandPrimary;
      case ChipVariant.outlined: return Colors.white;
      case ChipVariant.subtle:   return AppTheme.brandPrimary.withValues(alpha: 0.08);
    }
  }

  Color _borderColor() {
    if (!isSelected) return Colors.grey.shade200;
    return AppTheme.brandPrimary;
  }

  Color _labelColor() {
    if (!enabled) return Colors.grey.shade400;
    if (!isSelected) return AppTheme.brandDark;
    switch (variant) {
      case ChipVariant.filled:   return Colors.white;
      case ChipVariant.outlined: return AppTheme.brandPrimary;
      case ChipVariant.subtle:   return AppTheme.brandPrimary;
    }
  }

  Color _iconColor() {
    if (!enabled) return Colors.grey.shade400;
    if (!isSelected) return Colors.grey.shade500;
    switch (variant) {
      case ChipVariant.filled:   return Colors.white;
      case ChipVariant.outlined: return AppTheme.brandPrimary;
      case ChipVariant.subtle:   return AppTheme.brandPrimary;
    }
  }

  List<BoxShadow> _shadow() {
    if (!isSelected || variant == ChipVariant.subtle) return [];
    if (variant == ChipVariant.filled) return AppTheme.primaryGlow;
    return [];
  }

  // ── FIX 1: Consistent radius constant ─────────────────────
  // was 20 — pill/oval shape in screenshots
  static const double _radius = 10.0;

  @override
  Widget build(BuildContext context) {
    // ── FIX 2: Material + InkWell — proper ripple ─────────
    return Material(
      color:        Colors.transparent,
      borderRadius: BorderRadius.circular(_radius),
      child: InkWell(
        onTap:        enabled ? onTap : null,
        borderRadius: BorderRadius.circular(_radius),
        splashColor:  isSelected
            ? Colors.white.withValues(alpha: 0.15)
            : AppTheme.brandPrimary.withValues(alpha: 0.08),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve:    Curves.easeOut,
          padding:  const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color:        _backgroundColor(),
            // ── FIX 1: radius 20 → 10 ─────────────────────
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(
              color: _borderColor(),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: _shadow(),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [

              // Leading icon
              if (icon != null) ...[
                Icon(icon, size: 14, color: _iconColor()),
                const SizedBox(width: 5),
              ],

              // Label
              Text(
                label,
                style: TextStyle(
                  fontFamily:  'Poppins',
                  fontSize:    12,
                  fontWeight:  isSelected ? FontWeight.w700 : FontWeight.w500,
                  color:       _labelColor(),
                  letterSpacing: 0.1,
                ),
              ),

              // Count badge
              if (count != null) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontFamily:  'Poppins',
                      fontSize:    10,
                      fontWeight:  FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}