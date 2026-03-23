import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

// Shared across all step widgets — public (no underscore)
class StepTitle extends StatelessWidget {
  const StepTitle({super.key, required this.title, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(
          fontFamily: 'Cormorant Garamond',
          fontSize: 34, fontWeight: FontWeight.w700,
          color: AppTheme.brandDark, height: 1.15, letterSpacing: -0.5,
        )),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(subtitle!, style: TextStyle(
            fontFamily: 'Poppins', fontSize: 13,
            color: Colors.grey.shade500, height: 1.4,
          )),
        ],
      ],
    );
  }
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(
      fontFamily: 'Poppins', fontSize: 11,
      fontWeight: FontWeight.w700,
      color: Colors.grey.shade400, letterSpacing: 1.2,
    ));
  }
}