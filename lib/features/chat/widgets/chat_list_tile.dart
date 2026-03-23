import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_network_image.dart';

// ============================================================
// 📋 CHAT LIST TILE
// Single conversation row — unread tint, premium badge,
// online dot, message status ticks
// ============================================================
class ChatListTile extends StatelessWidget {
  const ChatListTile({
    super.key,
    required this.conversation,
    required this.onTap,
    required this.onLongPress,
  });

  final Map<String, dynamic> conversation;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final bool isOnline  = conversation['isOnline']  as bool;
    final bool isPremium = conversation['isPremium'] as bool;
    final int unread     = conversation['unreadCount'] as int;
    final bool hasUnread = unread > 0;
    final bool isMe      = conversation['lastMessageIsMe'] as bool;
    final String status  = conversation['messageStatus'] as String;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: hasUnread
              ? AppTheme.brandPrimary.withValues(alpha: 0.04)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: hasUnread
              ? Border.all(
            color: AppTheme.brandPrimary.withValues(alpha: 0.09),
          )
              : null,
        ),
        child: Row(
          children: [

            // Avatar with online dot + premium badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: CustomNetworkImage(
                    imageUrl: conversation['image'],
                    width: 54, height: 54,
                    borderRadius: 18,
                  ),
                ),
                if (isPremium)
                  Positioned(
                    top: 0, right: 0,
                    child: Container(
                      width: 16, height: 16,
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.diamond_rounded,
                        size: 8,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (isOnline)
                  Positioned(
                    bottom: 1, right: 1,
                    child: Container(
                      width: 13, height: 13,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ADE80),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Name + last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation['name'],
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: hasUnread
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: AppTheme.brandDark,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        conversation['time'],
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: hasUnread
                              ? AppTheme.brandPrimary
                              : Colors.grey.shade400,
                          fontWeight: hasUnread
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (isMe) ...[
                        _StatusIcon(status),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          conversation['lastMessage'],
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: hasUnread
                                ? AppTheme.brandDark
                                : Colors.grey.shade500,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          constraints: const BoxConstraints(minWidth: 20),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.brandPrimary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$unread',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon(this.status);
  final String status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case 'sent':
        return Icon(Icons.check_rounded,
            size: 14, color: Colors.grey.shade400);
      case 'delivered':
        return Icon(Icons.done_all_rounded,
            size: 14, color: Colors.grey.shade400);
      case 'read':
        return const Icon(Icons.done_all_rounded,
            size: 14, color: AppTheme.brandPrimary);
      default:
        return const SizedBox.shrink();
    }
  }
}