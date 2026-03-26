import 'package:flutter/material.dart';

import '../../core/constants/auth_constants.dart';
import '../../core/theme/app_theme.dart';

/// Centralised snackbar helpers so every auth screen shows the
/// same pill-shaped, floating snackbar with icon + message.
abstract class AuthSnackbar {
  /// Red error snackbar.
  static void showError(BuildContext context, String msg) {
    _show(
      context,
      color: AppTheme.error,
      icon: Icons.error_outline_rounded,
      message: msg,
    );
  }

  /// Green success snackbar.
  static void showSuccess(BuildContext context, String msg) {
    _show(
      context,
      color: AppTheme.success,
      icon: Icons.check_circle_rounded,
      message: msg,
    );
  }

  static void _show(
      BuildContext context, {
        required Color color,
        required IconData icon,
        required String message,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AuthConstants.snackBarRadius),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: AuthConstants.snackBarAlpha),
                blurRadius: AuthConstants.snackBarBlur,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}