import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_network_image.dart';

// ============================================================
// 🔝 CHAT DETAIL HEADER
// Back, avatar + name + online status, video call, more
// ============================================================
class ChatDetailHeader extends StatelessWidget {
  const ChatDetailHeader({
    super.key,
    required this.user,
    required this.onBackTap,
    required this.onProfileTap,
    required this.onCallTap,
    required this.onMoreTap,
  });

  final Map<String, dynamic> user;
  final VoidCallback onBackTap;
  final VoidCallback onProfileTap;
  final VoidCallback onCallTap;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    final bool isOnline = user['isOnline'] as bool;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
          child: Row(
            children: [

              // Back
              IconButton(
                onPressed: onBackTap,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppTheme.brandDark,
                  size: 20,
                ),
              ),

              // Avatar + name
              Expanded(
                child: GestureDetector(
                  onTap: onProfileTap,
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: CustomNetworkImage(
                              imageUrl: user['image'],
                              width: 44, height: 44,
                              borderRadius: 14,
                            ),
                          ),
                          if (isOnline)
                            Positioned(
                              bottom: 1, right: 1,
                              child: Container(
                                width: 11, height: 11,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4ADE80),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white, width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['name'],
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.brandDark,
                              letterSpacing: -0.2,
                            ),
                          ),
                          Text(
                            isOnline ? 'Online' : user['lastSeen'],
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: isOnline
                                  ? const Color(0xFF16A34A)
                                  : Colors.grey.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Video call
              GestureDetector(
                onTap: onCallTap,
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.brandPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.videocam_rounded,
                    color: AppTheme.brandPrimary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // More
              GestureDetector(
                onTap: onMoreTap,
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.more_vert_rounded,
                    color: Colors.grey.shade600,
                    size: 20,
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