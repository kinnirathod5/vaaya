import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// ============================================================
// 🎩 INTERESTS HEADER
// Title + notification button
// ============================================================
class InterestsHeader extends StatelessWidget {
  const InterestsHeader({
    super.key,
    required this.newCount,
    required this.onNotificationTap,
  });

  final int newCount;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Interests',
                        style: TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.brandDark,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      TextSpan(
                        text: ' & Requests',
                        style: TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.brandPrimary,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  newCount > 0
                      ? '$newCount new since last visit'
                      : 'All up to date',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Notification button
          GestureDetector(
            onTap: onNotificationTap,
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.brandPrimary.withValues(alpha: 0.12),
                ),
                boxShadow: AppTheme.softShadow,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: AppTheme.brandDark,
                    size: 22,
                  ),
                  if (newCount > 0)
                    Positioned(
                      top: 8, right: 8,
                      child: Container(
                        width: 9, height: 9,
                        decoration: BoxDecoration(
                          color: AppTheme.brandPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}