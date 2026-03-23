import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

class PhoneInputField extends StatelessWidget {
  const PhoneInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isValid,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isValid;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: isValid ? const Color(0xFFF0FDF4) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isValid
              ? AppTheme.success.withValues(alpha: 0.50)
              : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: isValid
            ? [BoxShadow(
          color: AppTheme.success.withValues(alpha: 0.08),
          blurRadius: 12, offset: const Offset(0, 4),
        )]
            : [],
      ),
      child: Row(
        children: [
          // +91 prefix
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🇮🇳', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  '+91',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 16, color: Colors.grey.shade400),
              ],
            ),
          ),

          // Number input
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              onSubmitted: onSubmitted,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.brandDark,
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                hintText: '98765 43210',
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.grey.shade300,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1,
                ),
                border: InputBorder.none,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 18,
                ),
                suffixIcon: isValid
                    ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: Icon(Icons.check_circle_rounded,
                      color: AppTheme.success, size: 22),
                )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ============================================================
// 🔢 OTP INPUT ROW
// 6 individual digit boxes with focus auto-advance
// ============================================================