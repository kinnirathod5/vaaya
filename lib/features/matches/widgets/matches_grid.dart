import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_network_image.dart';

// ============================================================
// 🗂️ MATCHES GRID
// 2-column profile card grid
// buildCard() is a static factory used by matches_screen.dart
// ============================================================
class MatchesGrid extends StatelessWidget {
  const MatchesGrid({
    super.key,
    required this.matches,
    required this.scrollController,
    required this.bottomPadding,
    required this.onMatchTap,
    required this.onLikeTap,
  });

  final List<Map<String, dynamic>> matches;
  final ScrollController scrollController;
  final double bottomPadding;
  final void Function(Map<String, dynamic>) onMatchTap;
  final void Function(Map<String, dynamic>) onLikeTap;

  /// Static factory — called by MatchesScreen for guest lock wrapping
  static Widget buildCard({
    required Map<String, dynamic> match,
    required VoidCallback onLikeTap,
  }) {
    return _MatchCard(match: match, onLikeTap: onLikeTap);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      padding: EdgeInsets.fromLTRB(16, 0, 16, 80 + bottomPadding),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.66,
      ),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return GestureDetector(
          onTap: () => onMatchTap(match),
          child: _MatchCard(
            match: match,
            onLikeTap: () => onLikeTap(match),
          ),
        );
      },
    );
  }
}


// ── Match card ────────────────────────────────────────────────
class _MatchCard extends StatelessWidget {
  const _MatchCard({
    required this.match,
    required this.onLikeTap,
  });

  final Map<String, dynamic> match;
  final VoidCallback onLikeTap;

  @override
  Widget build(BuildContext context) {
    final bool isOnline  = match['isOnline']  as bool;
    final bool isPremium = match['isPremium'] as bool;
    final bool isNew     = match['isNew']     as bool;
    final int matchPct   = match['match']     as int;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.mediumShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
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
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.82),
                  ],
                  stops: const [0.38, 1.0],
                ),
              ),
            ),

            // Top badges
            Positioned(
              top: 10, left: 10, right: 10,
              child: Row(
                children: [
                  // Online badge
                  if (isOnline)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5, height: 5,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Text('Online', style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          )),
                        ],
                      ),
                    ),
                  const Spacer(),

                  // New badge
                  if (isNew)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.brandPrimary.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('New', style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      )),
                    ),

                  // Premium badge
                  if (isPremium) ...[
                    if (isNew) const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.diamond_rounded,
                        size: 9,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Bottom content
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Name + age
                    Text(
                      '${match['name']}, ${match['age']}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // City · profession
                    Text(
                      '${match['city']} · ${match['profession']}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 9),

                    // Match bar + like button
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$matchPct% match',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 9,
                                  color: Colors.white.withValues(alpha: 0.70),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: matchPct / 100,
                                  backgroundColor:
                                  Colors.white.withValues(alpha: 0.18),
                                  valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                      AppTheme.brandPrimary),
                                  minHeight: 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Like button
                        GestureDetector(
                          onTap: onLikeTap,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              gradient: AppTheme.brandGradient,
                              shape: BoxShape.circle,
                              boxShadow: AppTheme.primaryGlow,
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}