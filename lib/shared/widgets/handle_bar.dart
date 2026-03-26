import 'package:flutter/material.dart';

import '../../core/constants/auth_constants.dart';
import '../../core/theme/app_theme.dart';

/// The small rounded pill centred at the top of every bottom-sheet-style
/// form card in the auth flow.
class HandleBar extends StatelessWidget {
  const HandleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: AuthConstants.handleBarWidth,
        height: AuthConstants.handleBarHeight,
        decoration: BoxDecoration(
          color: AppTheme.brandPrimary
              .withValues(alpha: AuthConstants.handleBarAlpha),
          borderRadius: BorderRadius.circular(AuthConstants.handleBarHeight),
        ),
      ),
    );
  }
}