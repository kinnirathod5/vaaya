import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../shared/widgets/custom_chip.dart';
import '../../../shared/widgets/custom_textfield.dart';
import 'onboarding_helpers.dart';

class Step4Height extends StatelessWidget {
  const Step4Height({
    super.key,
    required this.feet, required this.inches,
    required this.firstName, required this.isFemale,
    required this.onFeetChanged, required this.onInchesChanged,
  });

  final int feet, inches;
  final bool isFemale;
  final String firstName;
  final ValueChanged<int> onFeetChanged, onInchesChanged;

  @override
  Widget build(BuildContext context) {
    final q = isFemale ? 'How tall are\nyou' : 'How tall are\nyou';
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepTitle(
            title: firstName.isNotEmpty ? '$q, $firstName?' : '$q?',
            subtitle: 'Helps find compatible matches.',
          ),
          const SizedBox(height: 24),

          Container(
            height: 230,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.heavyShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(initialItem: feet - 4),
                    itemExtent: 52,
                    onSelectedItemChanged: (i) {
                      HapticUtils.selectionClick();
                      onFeetChanged(i + 4);
                    },
                    children: List.generate(4, (i) => Center(
                      child: Text('${i + 4} ft', style: const TextStyle(
                        fontFamily: 'Poppins', fontSize: 22,
                        fontWeight: FontWeight.w700, color: AppTheme.brandDark,
                      )),
                    )),
                  ),
                ),
                Text(':', style: TextStyle(fontSize: 26, color: Colors.grey.shade300)),
                SizedBox(
                  width: 120,
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(initialItem: inches),
                    itemExtent: 52,
                    onSelectedItemChanged: (i) {
                      HapticUtils.selectionClick();
                      onInchesChanged(i);
                    },
                    children: List.generate(12, (i) => Center(
                      child: Text('$i in', style: const TextStyle(
                        fontFamily: 'Poppins', fontSize: 22,
                        fontWeight: FontWeight.w700, color: AppTheme.brandDark,
                      )),
                    )),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),
          Center(
            child: Text("$feet'$inches\"", style: const TextStyle(
              fontFamily: 'Poppins', fontSize: 52,
              fontWeight: FontWeight.w900,
              color: AppTheme.brandPrimary, letterSpacing: -1,
            )),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}


// ════════════════════════════════════════════════════════════
// step5_community.dart
// ════════════════════════════════════════════════════════════