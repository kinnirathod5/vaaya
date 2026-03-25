import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/haptic_utils.dart';

// ============================================================
// 🔘 PRIMARY BUTTON
// Main action button used across all screens.
//
// Variants:
//   ButtonVariant.filled   → solid brand gradient (default)
//   ButtonVariant.outlined → border only, transparent fill
//   ButtonVariant.ghost    → light brand tint, no border
//   ButtonVariant.dark     → dark cinematic — premium screens
//   ButtonVariant.gold     → gold gradient — VIP / upgrade CTAs
//   ButtonVariant.success  → green — confirmed / saved states
//
// Usage:
//   PrimaryButton(text: 'Continue', onTap: _next)
//
//   PrimaryButton(
//     text: 'Send Interest',
//     icon: Icons.favorite_rounded,
//     isLoading: _loading,
//     onTap: _send,
//   )
//
//   PrimaryButton(
//     text: 'Upgrade to Premium',
//     variant: ButtonVariant.gold,
//     onTap: () => context.push('/premium'),
//   )
//
//   PrimaryButton(
//     text: 'Profile Saved',
//     variant: ButtonVariant.success,
//     onTap: null,
//   )
// ============================================================

enum ButtonVariant { filled, outlined, ghost, dark, gold, success }

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    this.onTap,
    this.isEnabled = true,
    this.isLoading = false,
    this.variant = ButtonVariant.filled,
    this.icon,
    this.trailingIcon,
    this.height = 54,
    this.width,
    this.fontSize = 15,
    this.borderRadius = 18.0,
  });

  /// Button label
  final String text;

  /// Tap callback — null disables the button
  final VoidCallback? onTap;

  /// Whether the button is interactive (default: true)
  final bool isEnabled;

  /// Show loading spinner instead of text + icon
  final bool isLoading;

  /// Visual variant (default: filled)
  final ButtonVariant variant;

  /// Optional leading icon
  final IconData? icon;

  /// Optional trailing icon (e.g. arrow)
  final IconData? trailingIcon;

  final double height;
  final double? width;
  final double fontSize;
  final double borderRadius;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {

  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  bool get _interactive =>
      widget.isEnabled && !widget.isLoading && widget.onTap != null;

  // ── Decoration per variant ────────────────────────────────
  Decoration _decoration() {
    if (!_interactive) {
      return BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      );
    }

    switch (widget.variant) {
      case ButtonVariant.filled:
        return BoxDecoration(
          gradient: AppTheme.brandGradient,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: AppTheme.primaryGlow,
        );

      case ButtonVariant.outlined:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: AppTheme.brandPrimary, width: 2),
        );

      case ButtonVariant.ghost:
        return BoxDecoration(
          color: AppTheme.brandPrimary.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        );

      case ButtonVariant.dark:
        return BoxDecoration(
          gradient: AppTheme.darkGradient,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 14, offset: const Offset(0, 6),
            ),
          ],
        );

      case ButtonVariant.gold:
        return BoxDecoration(
          gradient: AppTheme.goldGradient,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: AppTheme.goldGlow,
        );

      case ButtonVariant.success:
        return BoxDecoration(
          color: AppTheme.success,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppTheme.success.withValues(alpha: 0.28),
              blurRadius: 14, offset: const Offset(0, 6),
            ),
          ],
        );
    }
  }

  Color _textColor() {
    if (!_interactive) return Colors.grey.shade400;
    switch (widget.variant) {
      case ButtonVariant.filled:
      case ButtonVariant.dark:
      case ButtonVariant.gold:
      case ButtonVariant.success:
        return Colors.white;
      case ButtonVariant.outlined:
      case ButtonVariant.ghost:
        return AppTheme.brandPrimary;
    }
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _interactive ? (_) => _pressCtrl.forward() : null,
      onTapUp: _interactive ? (_) => _pressCtrl.reverse() : null,
      onTapCancel: _interactive ? () => _pressCtrl.reverse() : null,
      onTap: () {
        if (!_interactive) {
          HapticUtils.errorVibrate();
          return;
        }
        HapticUtils.mediumImpact();
        widget.onTap!();
      },
      child: ScaleTransition(
        scale: _pressScale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: _decoration(),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
              width: 22, height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(_textColor()),
              ),
            )
                : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: _textColor(), size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.text,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.w700,
                    color: _textColor(),
                    letterSpacing: 0.2,
                  ),
                ),
                if (widget.trailingIcon != null) ...[
                  const SizedBox(width: 6),
                  Icon(widget.trailingIcon, color: _textColor(), size: 16),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}