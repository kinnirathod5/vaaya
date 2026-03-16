import 'package:flutter/material.dart';

// 🔥 Humare doosre Lego Blocks jinki yahan zaroorat hai
import '../../core/theme/app_theme.dart';
import '../../core/utils/haptic_utils.dart';
import 'custom_network_image.dart';
import 'glass_container.dart';

class PremiumMatchCard extends StatelessWidget {
  final String name;
  final int age;
  final String imageUrl;
  final String? matchPercentage;
  final String? profession; // Extra details ke liye
  final VoidCallback onTap;

  // 🔥 Quick Action Buttons (Optional)
  final VoidCallback? onLike;
  final VoidCallback? onSkip;

  const PremiumMatchCard({
    super.key,
    required this.name,
    required this.age,
    required this.imageUrl,
    required this.onTap,
    this.matchPercentage,
    this.profession,
    this.onLike,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.softShadow,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 🖼️ Background Profile Image
            CustomNetworkImage(imageUrl: imageUrl, borderRadius: 20),

            // 🌑 Dark Gradient (Taaki text clear dikhe)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8), // Bottom me dark
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),

            // 🎯 Match Percentage Badge (Top Left)
            if (matchPercentage != null)
              Positioned(
                top: 10,
                left: 10,
                child: GlassContainer(
                  blur: 10,
                  opacity: 0.3,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  borderRadius: BorderRadius.circular(12),
                  child: Text(
                    '$matchPercentage Match',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // 📝 User Details (Bottom Left)
            Positioned(
              bottom: 15,
              left: 15,
              // Agar buttons hain, toh text ko thoda pehle rok do taaki overlap na ho
              right: (onLike != null || onSkip != null) ? 65 : 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$name, $age',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (profession != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      profession!,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ]
                ],
              ),
            ),

            // 💖 Quick Action Buttons (Bottom Right)
            if (onLike != null || onSkip != null)
              Positioned(
                bottom: 10,
                right: 10,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Skip (Cross) Button
                    if (onSkip != null)
                      GestureDetector(
                        onTap: () {
                          HapticUtils.lightImpact();
                          onSkip!();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                        ),
                      ),

                    // Like (Heart) Button
                    if (onLike != null)
                      GestureDetector(
                        onTap: () {
                          HapticUtils.heavyImpact();
                          onLike!();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.brandPrimary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.brandPrimary.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 18),
                        ),
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