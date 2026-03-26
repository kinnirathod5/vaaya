import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/haptic_utils.dart';

// ============================================================
// 📋 PREMIUM LIST TILE
// Elevated card-style list tile with icon, title, subtitle,
// optional trailing value, toggle, or custom widget.
//
// Variants:
//   TileVariant.nav    → arrow on right — navigates somewhere (default)
//   TileVariant.toggle → switch on right — settings toggles
//   TileVariant.info   → no arrow — read-only display
//   TileVariant.danger → red tint — destructive actions
//
// Usage:
//   PremiumListTile(
//     title: 'Edit Profile',
//     leadingIcon: Icons.edit_rounded,
//     onTap: () => context.push('/edit_profile'),
//   )
//
//   PremiumListTile(
//     title: 'Show Online Status',
//     subtitle: 'Others can see when you\'re active',
//     leadingIcon: Icons.visibility_outlined,
//     variant: TileVariant.toggle,
//     toggleValue: _showOnline,
//     onToggleChanged: (v) => setState(() => _showOnline = v),
//   )
//
//   PremiumListTile(
//     title: 'App Version',
//     leadingIcon: Icons.info_outline_rounded,
//     trailingValue: '1.0.0',
//     variant: TileVariant.info,
//   )
// ============================================================

enum TileVariant { nav, toggle, info, danger }

class PremiumListTile extends StatefulWidget {
  const PremiumListTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.leadingIcon,
    this.onTap,
    this.iconColor,
    this.variant = TileVariant.nav,
    this.trailingValue,
    this.trailingValueColor,
    this.toggleValue = false,
    this.onToggleChanged,
    this.showDivider = false,
    this.margin,
  });

  final String title;
  final String? subtitle;
  final IconData leadingIcon;
  final VoidCallback? onTap;
  final Color? iconColor;
  final TileVariant variant;
  final String? trailingValue;
  final Color? trailingValueColor;
  final bool toggleValue;
  final ValueChanged<bool>? onToggleChanged;
  final bool showDivider;
  final EdgeInsets? margin;

  @override
  State<PremiumListTile> createState() => _PremiumListTileState();
}

class _PremiumListTileState extends State<PremiumListTile>
    with SingleTickerProviderStateMixin {

  late final AnimationController _pressCtrl;
  late final Animation<double> _pressAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _pressAnim = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  Color get _effectiveIconColor =>
      widget.iconColor ??
          (widget.variant == TileVariant.danger
              ? AppTheme.error
              : AppTheme.brandPrimary);

  Color get _titleColor =>
      widget.variant == TileVariant.danger
          ? AppTheme.error
          : AppTheme.brandDark;

  bool get _isTappable =>
      widget.variant == TileVariant.toggle ||
          (widget.variant != TileVariant.info && widget.onTap != null);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _isTappable ? (_) => _pressCtrl.forward() : null,
      onTapUp: _isTappable ? (_) => _pressCtrl.reverse() : null,
      onTapCancel: _isTappable ? () => _pressCtrl.reverse() : null,
      onTap: _isTappable
          ? () {
        if (widget.variant == TileVariant.toggle) {
          HapticUtils.selectionClick();
          widget.onToggleChanged?.call(!widget.toggleValue);
        } else {
          HapticUtils.lightImpact();
          widget.onTap?.call();
        }
      }
          : null,
      child: ScaleTransition(
        scale: _pressAnim,
        child: Container(
          margin: widget.showDivider
              ? EdgeInsets.zero
              : widget.margin ?? const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: widget.showDivider
              ? null
              : BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppTheme.softShadow,
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              // ── Leading icon ──────────────────────────
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: _effectiveIconColor.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.leadingIcon,
                  color: _effectiveIconColor,
                  size: 19,
                ),
              ),
              const SizedBox(width: 14),

              // ── Title + subtitle ──────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _titleColor,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle!,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // ── Trailing ──────────────────────────────
              _buildTrailing(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrailing() {
    switch (widget.variant) {

      case TileVariant.toggle:
        return Transform.scale(
          scale: 0.85,
          child: Switch(
            value: widget.toggleValue,
            onChanged: (v) {
              HapticUtils.selectionClick();
              widget.onToggleChanged?.call(v);
            },
            activeThumbColor: AppTheme.brandPrimary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        );

      case TileVariant.info:
        if (widget.trailingValue != null) {
          return Text(
            widget.trailingValue!,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: widget.trailingValueColor ?? Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          );
        }
        return const SizedBox.shrink();

      case TileVariant.nav:
      case TileVariant.danger:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.trailingValue != null) ...[
              Text(
                widget.trailingValue!,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: widget.trailingValueColor ?? Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
            ],
            // ✅ Fixed: shade350 doesn't exist — use shade300
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: Colors.grey.shade300,
            ),
          ],
        );
    }
  }
}