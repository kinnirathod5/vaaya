import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_network_image.dart';

// ============================================================
// 📊 ACTIVITY UPDATE CARD
// Profile visitor count summary — taps to My Profile
// ============================================================
class ActivityUpdateCard extends StatelessWidget {
  const ActivityUpdateCard({
    super.key,
    required this.visitorCount,
    required this.visitorImages,
    required this.onTap,
  });

  final int visitorCount;
  final List<String> visitorImages;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppTheme.brandPrimary.withValues(alpha: 0.07),
                Colors.white,
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppTheme.brandPrimary.withValues(alpha: 0.16),
            ),
          ),
          child: Row(
            children: [
              // Stacked avatars
              _StackedAvatars(imageUrls: visitorImages),
              const SizedBox(width: 14),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.visibility_rounded,
                          size: 14,
                          color: AppTheme.brandPrimary,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Recent Profile Visits',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.brandDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$visitorCount people viewed your profile',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: AppTheme.brandPrimary.withValues(alpha: 0.60),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ── Stacked avatars ───────────────────────────────────────────
class _StackedAvatars extends StatelessWidget {
  const _StackedAvatars({required this.imageUrls});
  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    const double size   = 30;
    const double offset = 14;
    final count = imageUrls.length.clamp(0, 3);
    final totalWidth = size + (count - 1) * offset;

    return SizedBox(
      width: totalWidth,
      height: size,
      child: Stack(
        children: List.generate(count, (i) {
          return Positioned(
            left: i * offset,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipOval(
                child: CustomNetworkImage(
                  imageUrl: imageUrls[i],
                  width: size,
                  height: size,
                  borderRadius: size / 2,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}