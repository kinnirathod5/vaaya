import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../shared/widgets/custom_chip.dart';
import '../../../shared/widgets/custom_textfield.dart';
import 'onboarding_helpers.dart';

class Step3Birthday extends StatelessWidget {
  const Step3Birthday({
    super.key,
    required this.dob, required this.touched,
    required this.firstName, required this.isFemale,
    required this.onChanged,
  });

  final DateTime dob;
  final bool touched, isFemale;
  final String firstName;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepTitle(
            title: firstName.isNotEmpty
                ? 'When is your\nbirthday, $firstName?'
                : 'When is your\nbirthday?',
            subtitle: 'Your birth year will be kept private.',
          ),
          const SizedBox(height: 24),

          Container(
            height: 210,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.heavyShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: dob,
                minimumDate: DateTime(1950),
                maximumDate: DateTime(DateTime.now().year - 18),
                onDateTimeChanged: (d) {
                  HapticUtils.selectionClick();
                  onChanged(d);
                },
              ),
            ),
          ),

          const Spacer(),
          AnimatedOpacity(
            opacity: touched ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 350),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.brandPrimary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.brandPrimary.withValues(alpha: 0.15),
                  ),
                ),
                child: Text(
                  'Age: ${DateTime.now().year - dob.year} years',
                  style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 14,
                    fontWeight: FontWeight.w700, color: AppTheme.brandPrimary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}


// ════════════════════════════════════════════════════════════
// step4_height.dart
// ════════════════════════════════════════════════════════════