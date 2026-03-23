import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_network_image.dart';

// ============================================================
// 💎 PREMIUM MATCHES ROW
// Gold-bordered cards — darkened + lock icon if not premium
// ============================================================
class PremiumMatchesRow extends StatelessWidget {
  const PremiumMatchesRow({
    super.key,
    required this.matches,
    required this.isLocked,
    required this.onMatchTap,
  });

  final List<Map<String, dynamic>> matches;
  final bool isLocked;
  final void Function(Map<String, dynamic>) onMatchTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 182,
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
              width: 130,
              margin: const EdgeInsets.symmetric(horizontal: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.goldPrimary
                      .withValues(alpha: isLocked ? 0.50 : 0.80),
                  width: isLocked ? 1.5 : 2,
                ),
                boxShadow: isLocked ? AppTheme.softShadow : AppTheme.goldGlow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Photo — darkened when locked
                    isLocked
                        ? ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        0.20, 0, 0, 0, 0,
                        0, 0.20, 0, 0, 0,
                        0, 0, 0.20, 0, 0,
                        0, 0, 0,  1, 0,
                      ]),
                      child: CustomNetworkImage(
                        imageUrl: match['image'],
                        borderRadius: 0,
                      ),
                    )
                        : CustomNetworkImage(
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
                            Colors.black.withValues(alpha: 0.80),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5],
                        ),
                      ),
                    ),

                    // Lock overlay — center
                    if (isLocked)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppTheme.goldGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),

                    // Name + city — bottom
                    Positioned(
                      bottom: 11, left: 11, right: 11,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.diamond_rounded,
                                color: Color(0xFFFFD700),
                                size: 11,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  match['name'],
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${match['age']} · ${match['city']}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.65),
                            ),
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