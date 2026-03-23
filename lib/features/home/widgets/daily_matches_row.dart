import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_network_image.dart';
import '../../../../shared/widgets/glass_container.dart';

// ============================================================
// 📅 DAILY MATCHES ROW
// Horizontal large photo cards with match % badge
// ============================================================
class DailyMatchesRow extends StatelessWidget {
  const DailyMatchesRow({
    super.key,
    required this.matches,
    required this.onMatchTap,
  });

  final List<Map<String, dynamic>> matches;
  final void Function(Map<String, dynamic>) onMatchTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 275,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final match = matches[index];
          return GestureDetector(
            onTap: () => onMatchTap(match),
            child: Container(
              width: 195,
              margin: const EdgeInsets.symmetric(horizontal: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: AppTheme.softShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Photo
                    CustomNetworkImage(
                      imageUrl: match['image'],
                      borderRadius: 0,
                    ),

                    // Bottom gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.78),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5],
                        ),
                      ),
                    ),

                    // Match % — top left
                    Positioned(
                      top: 12, left: 12,
                      child: GlassContainer(
                        blur: 10,
                        opacity: 0.22,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        child: Text(
                          '${match['match']}% match',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    // Name + profession — bottom
                    Positioned(
                      bottom: 14, left: 14, right: 14,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${match['name']}, ${match['age']}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            match['profession'],
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.70),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}