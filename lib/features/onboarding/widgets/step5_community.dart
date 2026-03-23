import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../shared/widgets/custom_chip.dart';
import '../../../shared/widgets/custom_textfield.dart';
import 'onboarding_helpers.dart';

class Step5Community extends StatelessWidget {
  const Step5Community({
    super.key,
    required this.gotra, required this.gotraList,
    required this.firstName, required this.onGotraChanged,
  });

  final String gotra, firstName;
  final List<String> gotraList;
  final ValueChanged<String> onGotraChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepTitle(
            title: firstName.isNotEmpty
                ? 'Your roots,\n$firstName.'
                : 'Your roots.',
            subtitle: 'Ensures cultural compatibility.',
          ),
          const SizedBox(height: 26),

          const FieldLabel('COMMUNITY'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.brandPrimary.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_rounded, color: Colors.green, size: 18),
                SizedBox(width: 10),
                Text('Banjara', style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 15,
                  fontWeight: FontWeight.w700, color: AppTheme.brandDark,
                )),
              ],
            ),
          ),
          const SizedBox(height: 22),

          const FieldLabel('SELECT GOTRA'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10, runSpacing: 10,
            children: gotraList.map((g) => CustomChip(
              label: g,
              isSelected: gotra == g,
              onTap: () { HapticUtils.selectionClick(); onGotraChanged(g); },
            )).toList(),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}


// ════════════════════════════════════════════════════════════
// step6_photo_location.dart
// ════════════════════════════════════════════════════════════