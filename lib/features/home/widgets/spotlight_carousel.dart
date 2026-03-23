import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_network_image.dart';

// ============================================================
// 🌟 SPOTLIGHT CAROUSEL
// Large full-bleed card carousel — scale effect on scroll
// ============================================================
class SpotlightCarousel extends StatelessWidget {
  const SpotlightCarousel({
    super.key,
    required this.matches,
    required this.pageController,
    required this.onMatchTap,
    required this.onLike,
    required this.onReject,
  });

  final List<Map<String, dynamic>> matches;
  final PageController pageController;
  final void Function(Map<String, dynamic>) onMatchTap;
  final void Function(Map<String, dynamic>) onLike;
  final void Function(Map<String, dynamic>) onReject;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 420,
      child: PageView.builder(
        controller: pageController,
        physics: const BouncingScrollPhysics(),
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final match = matches[index];
          return AnimatedBuilder(
            animation: pageController,
            builder: (context, child) {
              double scale = 1.0;
              if (pageController.position.haveDimensions) {
                final page = pageController.page! - index;
                scale = (1 - page.abs() * 0.10).clamp(0.88, 1.0);
              } else {
                scale = index == 0 ? 1.0 : 0.88;
              }
              return Transform.scale(scale: scale, child: child);
            },
            child: _SpotlightCard(
              match: match,
              onTap: () => onMatchTap(match),
              onLike: () => onLike(match),
              onReject: () => onReject(match),
            ),
          );
        },
      ),
    );
  }
}


// ── Spotlight card ────────────────────────────────────────────
class _SpotlightCard extends StatelessWidget {
  const _SpotlightCard({
    required this.match,
    required this.onTap,
    required this.onLike,
    required this.onReject,
  });

  final Map<String, dynamic> match;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32, left: 8, right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [

            // ── Photo card ────────────────────────────
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
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
                            Colors.black.withValues(alpha: 0.85),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.55],
                        ),
                      ),
                    ),

                    // Match % badge — top left
                    Positioned(
                      top: 18, left: 18,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_fire_department_rounded,
                              color: AppTheme.brandPrimary,
                              size: 15,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${match['match']}% Match',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                color: AppTheme.brandPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Profile info — bottom
                    Positioned(
                      bottom: 44, left: 18, right: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${match['name']}, ${match['age']}',
                            style: const TextStyle(
                              fontFamily: 'Cormorant Garamond',
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _InfoChip(
                                icon: Icons.work_outline_rounded,
                                label: match['profession'],
                              ),
                              const SizedBox(width: 8),
                              _InfoChip(
                                icon: Icons.location_on_outlined,
                                label: match['city'],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Action buttons — floating below card ──
            Positioned(
              bottom: -2, right: 20,
              child: Row(
                children: [
                  // Reject
                  GestureDetector(
                    onTap: onReject,
                    child: Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.grey.shade400,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Like
                  GestureDetector(
                    onTap: onLike,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: AppTheme.brandGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.brandPrimary
                                .withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
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


// ── Info chip ─────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}