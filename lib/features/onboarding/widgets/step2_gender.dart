import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_utils.dart';
import 'onboarding_helpers.dart';

class Step2Gender extends StatelessWidget {
  const Step2Gender({
    super.key,
    required this.gender,
    required this.firstName,
    required this.onChanged,
  });

  final String gender;
  final String firstName;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepTitle(
            title: firstName.isNotEmpty
                ? 'Who are you,\n$firstName?'
                : 'Who are you?',
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _GenderCard(
                  emoji: '👨', title: 'Male',
                  isSelected: gender == 'Male',
                  onTap: () { HapticUtils.selectionClick(); onChanged('Male'); },
                )),
                const SizedBox(width: 16),
                Expanded(child: _GenderCard(
                  emoji: '👩', title: 'Female',
                  isSelected: gender == 'Female',
                  onTap: () { HapticUtils.selectionClick(); onChanged('Female'); },
                )),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.emoji, required this.title,
    required this.isSelected, required this.onTap,
  });

  final String emoji, title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.brandPrimary.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? AppTheme.brandPrimary : Colors.grey.shade200,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppTheme.brandPrimary.withValues(alpha: 0.15),
              blurRadius: 18, offset: const Offset(0, 6),
            ),
          ] : AppTheme.softShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: isSelected ? 48 : 40)),
            const SizedBox(height: 14),
            Text(title, style: TextStyle(
              fontFamily: 'Poppins', fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isSelected ? AppTheme.brandPrimary : AppTheme.brandDark,
            )),
            const SizedBox(height: 8),
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.brandPrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Selected ✓', style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 10,
                  fontWeight: FontWeight.w700, color: Colors.white,
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}