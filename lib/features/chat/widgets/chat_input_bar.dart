import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// ============================================================
// ✍️ CHAT INPUT BAR
// Attachment + text field + animated send button
// Send button activates (brand color) only when typing
// ============================================================
class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.isTyping,
    required this.bottomPadding,
    required this.onSend,
    required this.onAttachmentTap,
  });

  final TextEditingController controller;
  final bool isTyping;
  final double bottomPadding;
  final VoidCallback onSend;
  final VoidCallback onAttachmentTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(14, 10, 14, 10 + bottomPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [

          // Attachment button
          GestureDetector(
            onTap: onAttachmentTap,
            child: Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFFAE4E9),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.attach_file_rounded,
                color: AppTheme.brandPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Text field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 42, maxHeight: 110,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F4F5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.brandPrimary.withValues(alpha: 0.10),
                ),
              ),
              child: TextField(
                controller: controller,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppTheme.brandDark,
                ),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 11,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Send button
          GestureDetector(
            onTap: isTyping ? onSend : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: isTyping
                    ? AppTheme.brandPrimary
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(13),
                boxShadow: isTyping ? AppTheme.primaryGlow : [],
              ),
              child: Icon(
                Icons.send_rounded,
                size: 19,
                color: isTyping ? Colors.white : Colors.grey.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}