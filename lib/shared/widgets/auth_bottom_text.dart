import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// "By continuing you agree to our Terms of Service and Privacy Policy."
///
/// Shared across login, OTP, and any future auth screen.
class AuthBottomText extends StatelessWidget {
  const AuthBottomText({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text.rich(
        TextSpan(
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            color: Color(0xFFBDBDBD),
            height: 1.6,
          ),
          children: const [
            TextSpan(text: 'By continuing you agree to our '),
            TextSpan(
              text: 'Terms of Service',
              style: TextStyle(
                color: AppTheme.brandPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(
                color: AppTheme.brandPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(text: '.'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}