import 'package:flutter/material.dart';

// 🔥 Humare banaye hue Theme aur Haptics import kar rahe hain
import '../../core/theme/app_theme.dart';
import '../../core/utils/haptic_utils.dart';

class PrimaryButton extends StatelessWidget {
  final String text;              // Button par kya likha hoga
  final VoidCallback? onTap;      // Button dabane par kya hoga
  final bool isEnabled;           // Button on hai ya off (Grey ya Pink)

  const PrimaryButton({
    super.key,
    required this.text,
    this.onTap,
    this.isEnabled = true, // Default on rahega
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isEnabled && onTap != null) {
          // Premium Vibration (Humara banaya hua HapticUtils!)
          HapticUtils.heavyImpact();
          onTap!();
        } else {
          // Agar button disable hai aur koi tap kare toh error vibrate ho
          HapticUtils.errorVibrate();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isEnabled ? AppTheme.brandPrimary : Colors.grey.shade200,
          // Agar enabled hai tabhi shadow/glow aayega
          boxShadow: isEnabled
              ? [BoxShadow(color: AppTheme.brandPrimary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))]
              : [],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isEnabled ? Colors.white : Colors.grey.shade400,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}