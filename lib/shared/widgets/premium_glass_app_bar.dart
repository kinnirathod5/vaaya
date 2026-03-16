import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/haptic_utils.dart';

class PremiumGlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;

  const PremiumGlassAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      // ✨ Wohi Premium Frosted Glass Effect jo Bottom Bar mein tha
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            // 🔥 Niche ki taraf ek subtle premium border
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.6), width: 1.5)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Container(
              height: kToolbarHeight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 🔙 Leading Icon (Agar nahi diya toh alignment ke liye khali space)
                  leading ?? const SizedBox(width: 48),

                  // 🔤 Center Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.brandDark,
                    ),
                  ),

                  // ⚙️ Action Icons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions ?? [const SizedBox(width: 48)],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // AppBar ke liye height specify karna zaroori hota hai
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}