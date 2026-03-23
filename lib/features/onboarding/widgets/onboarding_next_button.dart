import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingNextButton extends StatelessWidget {
  const OnboardingNextButton({
    super.key,
    required this.enabled,
    required this.isLast,
    required this.bottom,
    required this.onTap,
  });

  final bool enabled;
  final bool isLast;
  final double bottom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 10, 24, bottom),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity, height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: enabled
                ? [const Color(0xFFE8395A), const Color(0xFFFF6B84)]
                : [Colors.grey.shade200, Colors.grey.shade200],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: enabled
              ? [BoxShadow(
              color: const Color(0xFFE8395A).withValues(alpha: 0.30),
              blurRadius: 14, offset: const Offset(0, 6))]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLast)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(Icons.workspace_premium_rounded,
                        color: enabled ? Colors.white : Colors.grey.shade400,
                        size: 18),
                  ),
                Text(
                  isLast ? 'Enter VIP Lounge' : 'Continue',
                  style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 16,
                    fontWeight: FontWeight.w700, letterSpacing: 0.2,
                    color: enabled ? Colors.white : Colors.grey.shade400,
                  ),
                ),
                if (!isLast && enabled) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 18),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}