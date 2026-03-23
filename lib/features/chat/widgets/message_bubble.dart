import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_network_image.dart';

// ============================================================
// 💬 MESSAGE BUBBLE
// Mine (right, brand color) | Theirs (left, white)
// Smart corner radius, delivery ticks, avatar
// ============================================================
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.showAvatar,
    required this.otherUserImage,
  });

  final Map<String, dynamic> message;
  final bool showAvatar;
  final String otherUserImage;

  @override
  Widget build(BuildContext context) {
    final bool isMe   = message['isMe']   as bool;
    final String text = message['text']   as String;
    final String time = message['time']   as String;
    final String status = message['status'] as String? ?? 'sent';

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment:
        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [

          // Avatar — other user only
          if (!isMe) ...[
            showAvatar
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomNetworkImage(
                imageUrl: otherUserImage,
                width: 30, height: 30,
                borderRadius: 12,
              ),
            )
                : const SizedBox(width: 30),
            const SizedBox(width: 8),
          ],

          // Bubble + time
          Flexible(
            child: Column(
              crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.68,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? AppTheme.brandPrimary : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft:     const Radius.circular(18),
                      topRight:    const Radius.circular(18),
                      bottomLeft:  Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4  : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isMe
                            ? AppTheme.brandPrimary.withValues(alpha: 0.18)
                            : Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: isMe ? Colors.white : AppTheme.brandDark,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      _StatusIcon(status),
                    ],
                  ],
                ),
              ],
            ),
          ),

          if (isMe) const SizedBox(width: 4),
        ],
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
            size: 13, color: Colors.grey.shade400);
      case 'delivered':
        return Icon(Icons.done_all_rounded,
            size: 13, color: Colors.grey.shade400);
      case 'read':
        return const Icon(Icons.done_all_rounded,
            size: 13, color: AppTheme.brandPrimary);
      default:
        return const SizedBox.shrink();
    }
  }
}