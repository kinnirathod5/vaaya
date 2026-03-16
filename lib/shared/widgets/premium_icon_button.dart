import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/haptic_utils.dart';

class PremiumIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final Color backgroundColor;
  final double size;

  const PremiumIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor = AppTheme.brandDark,
    this.backgroundColor = Colors.white,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: AppTheme.softShadow,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(icon, color: iconColor, size: size),
      ),
    );
  }
}