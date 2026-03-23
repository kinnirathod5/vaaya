import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// ============================================================
// ✨ PERK ITEM
// Single premium perk row — highlighted ones glow in gold
// ============================================================
class PerkItem extends StatelessWidget {
  const PerkItem({super.key, required this.perk});
  final Map<String, dynamic> perk;

  @override
  Widget build(BuildContext context) {
    final bool isHighlight = perk['isHighlight'] as bool;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isHighlight
            ? AppTheme.goldPrimary.withValues(alpha: 0.07)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlight
              ? AppTheme.goldPrimary.withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [

          // Icon box
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: isHighlight
                  ? AppTheme.goldPrimary.withValues(alpha: 0.14)
                  : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              perk['icon'] as IconData,
              size: 20,
              color: isHighlight
                  ? AppTheme.goldLight
                  : Colors.white.withValues(alpha: 0.58),
            ),
          ),
          const SizedBox(width: 14),

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  perk['title'],
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isHighlight ? AppTheme.goldLight : Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  perk['subtitle'],
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.38),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Checkmark
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              color: isHighlight
                  ? AppTheme.goldPrimary.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 13,
              color: isHighlight
                  ? AppTheme.goldLight
                  : Colors.white.withValues(alpha: 0.32),
            ),
          ),
        ],
      ),
    );
  }
}