// ── step1_name.dart ──────────────────────────────────────────
// lib/features/onboarding/widgets/step1_name.dart

import 'package:flutter/material.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../shared/widgets/custom_chip.dart';
import '../../../shared/widgets/custom_textfield.dart';
import 'onboarding_helpers.dart';

class Step1Name extends StatelessWidget {
  const Step1Name({
    super.key,
    required this.profileFor,
    required this.forOptions,
    required this.firstCtrl,
    required this.lastCtrl,
    required this.onForChanged,
  });

  final String profileFor;
  final List<String> forOptions;
  final TextEditingController firstCtrl;
  final TextEditingController lastCtrl;
  final ValueChanged<String> onForChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StepTitle(
            title: 'Let\'s start\nwith the basics.',
            subtitle: 'Genuine details help find genuine matches.',
          ),
          const SizedBox(height: 28),

          const FieldLabel('PROFILE CREATED FOR'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10, runSpacing: 10,
            children: forOptions.map((o) => CustomChip(
              label: o,
              isSelected: profileFor == o,
              onTap: () { HapticUtils.selectionClick(); onForChanged(o); },
            )).toList(),
          ),
          const SizedBox(height: 26),

          const FieldLabel('FIRST NAME'),
          const SizedBox(height: 10),
          CustomTextField(hintText: 'e.g. Rahul', controller: firstCtrl),
          const SizedBox(height: 18),

          const FieldLabel('LAST NAME'),
          const SizedBox(height: 10),
          CustomTextField(hintText: 'e.g. Rathod', controller: lastCtrl),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}