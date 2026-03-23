import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/haptic_utils.dart';

// ============================================================
// 🔘 PREMIUM ICON BUTTON
// Circular icon button with shadow, press animation,
// optional badge count, and shape variants.
//
// Shapes:
//   ButtonShape.circle  → perfect circle (default)
//   ButtonShape.rounded → rounded rectangle
//
// Usage:
//   PremiumIconButton(
//     icon: Icons.notifications_outlined,
//     onTap: () => context.push('/notifications'),
//   )
//
//   PremiumIconButton(
//     icon: Icons.notifications_outlined,
//     badge: 3,
//     onTap: () => context.push('/notifications'),
//   )
//
//   PremiumIconButton(
//     icon: Icons.tune_rounded,
//     shape: ButtonShape.rounded,
//     backgroundColor: AppTheme.brandPrimary,
//     iconColor: Colors.white,
//     onTap: _openFilters,
//   )
// ============================================================

enum ButtonShape { circle, rounded }

class PremiumIconButton extends StatefulWidget {
  const PremiumIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor = AppTheme.brandDark,
    this.backgroundColor = Colors.white,
    this.iconSize = 20.0,
    this.padding = 12.0,
    this.shape = ButtonShape.circle,
    this.badge,
    this.showBorder = true,
  });

  final IconData icon;
  final VoidCallback onTap;

  final Color iconColor;
  final Color backgroundColor;

  /// Icon size (default: 20)
  final double iconSize;

  /// Inner padding around icon (default: 12)
  final double padding;

  final ButtonShape shape;

  /// Notification count badge — shown top-right
  final int? badge;

  /// Show grey border (default: true)
  final bool showBorder;

  @override
  State<PremiumIconButton> createState() => _PremiumIconButtonState();
}

class _PremiumIconButtonState extends State<PremiumIconButton>
    with SingleTickerProviderStateMixin {

  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  BorderRadiusGeometry get _borderRadius {
    return widget.shape == ButtonShape.circle
        ? BorderRadius.circular(100)
        : BorderRadius.circular(14);
  }

  @override
  Widget build(BuildContext context) {
    final hasBadge = widget.badge != null && widget.badge! > 0;

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) => _pressCtrl.reverse(),
      onTapCancel: () => _pressCtrl.reverse(),
      onTap: () {
        HapticUtils.lightImpact();
        widget.onTap();
      },
      child: ScaleTransition(
        scale: _pressScale,
        child: Stack(
          clipBehavior: Clip.none,
          children: [

            // ── Main button ──────────────────────────
            Container(
              padding: EdgeInsets.all(widget.padding),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: _borderRadius,
                border: widget.showBorder
                    ? Border.all(color: Colors.grey.shade200)
                    : null,
                boxShadow: AppTheme.softShadow,
              ),
              child: Icon(
                widget.icon,
                color: widget.iconColor,
                size: widget.iconSize,
              ),
            ),

            // ── Badge ────────────────────────────────
            if (hasBadge)
              Positioned(
                top: -3,
                right: -3,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.brandPrimary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.brandPrimary.withValues(alpha: 0.35),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.badge! > 9 ? '9+' : '${widget.badge}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}