import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// ============================================================
// 🎛️ MATCHES FILTER CHIPS
// Horizontal scrollable filter pill row
// ============================================================
class MatchesFilterChips extends StatelessWidget {
  const MatchesFilterChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = option == selected;

          return GestureDetector(
            onTap: () => onSelected(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.brandPrimary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [BoxShadow(
                  color: AppTheme.brandPrimary.withValues(alpha: 0.28),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )]
                    : AppTheme.softShadow,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.brandPrimary
                      : Colors.grey.shade200,
                  width: 1.5,
                ),
              ),
              child: Text(
                option,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}