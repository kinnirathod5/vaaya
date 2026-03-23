import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/haptic_utils.dart';

// ============================================================
// 📭 EMPTY STATE WIDGET
// Shown when a list or screen has no content.
// Supports icon, emoji, title, message, and action button.
//
// Quick presets for common screens:
//   EmptyStateWidget.noMatches(onRefresh: ...)
//   EmptyStateWidget.noChats(onExplore: ...)
//   EmptyStateWidget.noInterests()
//   EmptyStateWidget.noNotifications()
//
// Custom usage:
//   EmptyStateWidget(
//     emoji: '🔍',
//     title: 'No results found',
//     message: 'Try changing your filters.',
//     actionLabel: 'Reset Filters',
//     onAction: _resetFilters,
//   )
// ============================================================
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    this.icon,
    this.emoji,
    this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.compact = false,
  }) : assert(
  icon != null || emoji != null,
  'Provide either icon or emoji',
  );

  /// Material icon — shown in a grey circle
  final IconData? icon;

  /// Emoji — shown large, no background circle
  final String? emoji;

  /// Bold title above the message (optional)
  final String? title;

  /// Main descriptive text
  final String message;

  /// Primary CTA button label
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Optional secondary text link below the button
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  /// Compact mode — less padding, smaller icon (for inline use)
  final bool compact;

  // ── Named presets ─────────────────────────────────────────

  /// No matches found in discovery
  static Widget noMatches({VoidCallback? onRefresh}) {
    return EmptyStateWidget(
      emoji: '🔍',
      title: 'No profiles found',
      message: 'Try adjusting your filters\nor search term.',
      actionLabel: onRefresh != null ? 'Reset Filters' : null,
      onAction: onRefresh,
    );
  }

  /// No chat conversations yet
  static Widget noChats({VoidCallback? onExplore}) {
    return EmptyStateWidget(
      emoji: '💬',
      title: 'No conversations yet',
      message: 'Send an interest to start\na conversation.',
      actionLabel: onExplore != null ? 'Explore Matches' : null,
      onAction: onExplore,
    );
  }

  /// No interests received or sent
  static Widget noInterests({bool isSent = false}) {
    return EmptyStateWidget(
      emoji: '🌸',
      title: isSent ? 'No interests sent' : 'No interests yet',
      message: isSent
          ? 'Browse profiles and send\nyour first interest.'
          : 'When someone likes your profile,\nthey will appear here.',
    );
  }

  /// No notifications
  static Widget noNotifications() {
    return EmptyStateWidget(
      emoji: '🔔',
      title: 'All caught up!',
      message: 'New interests, matches, and\nmessages will appear here.',
    );
  }

  /// No mutual matches yet
  static Widget noMutualMatches() {
    return EmptyStateWidget(
      emoji: '🎉',
      title: 'No matches yet',
      message: 'When both of you accept\neach other\'s interest, it\'s a match!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 24 : 36,
          vertical: compact ? 16 : 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // ── Icon or emoji ──────────────────────────
            emoji != null
                ? Text(
              emoji!,
              style: TextStyle(
                fontSize: compact ? 40 : 52,
              ),
            )
                : Container(
              width: compact ? 64 : 80,
              height: compact ? 64 : 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon!,
                size: compact ? 28 : 36,
                color: Colors.grey.shade400,
              ),
            ),

            SizedBox(height: compact ? 12 : 16),

            // ── Title ──────────────────────────────────
            if (title != null) ...[
              Text(
                title!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: compact ? 14 : 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.brandDark,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
            ],

            // ── Message ────────────────────────────────
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: compact ? 12 : 13,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w400,
                height: 1.55,
              ),
            ),

            // ── Primary action button ──────────────────
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: compact ? 16 : 22),
              GestureDetector(
                onTap: () {
                  HapticUtils.mediumImpact();
                  onAction!();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.brandPrimary,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: AppTheme.primaryGlow,
                  ),
                  child: Text(
                    actionLabel!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],

            // ── Secondary action link ──────────────────
            if (secondaryActionLabel != null &&
                onSecondaryAction != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  HapticUtils.lightImpact();
                  onSecondaryAction!();
                },
                child: Text(
                  secondaryActionLabel!,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}