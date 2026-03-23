import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// ============================================================
// 📭 CHAT EMPTY STATE
// Shown when no conversations or no search results
// ============================================================
class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({
    super.key,
    required this.isSearching,
    this.searchQuery = '',
  });

  final bool isSearching;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88, height: 88,
              decoration: const BoxDecoration(
                color: Color(0xFFFAE4E9),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  isSearching ? '🔍' : '💬',
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isSearching
                  ? '"$searchQuery" not found'
                  : 'No conversations yet',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.brandDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Try a different name'
                  : 'Send an interest to start a conversation',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Colors.grey.shade500,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}