import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/haptic_utils.dart';
import 'custom_network_image.dart';
import 'glass_container.dart';

// ============================================================
// 💎 PREMIUM MATCH CARD
// Full-bleed profile card with gradient overlay, match badge,
// quick action buttons, online dot, and new/verified tags.
// Used in: Home spotlight, daily matches row, matches grid.
//
// Usage:
//   PremiumMatchCard(
//     name: 'Priya', age: 24,
//     imageUrl: url,
//     onTap: () => context.push('/user_detail'),
//   )
//
//   PremiumMatchCard(
//     name: 'Anjali', age: 26,
//     imageUrl: url,
//     matchPct: 92,
//     profession: 'UX Designer',
//     isOnline: true,
//     isNew: true,
//     onTap: ..., onLike: ...,
//   )
// ============================================================
class PremiumMatchCard extends StatefulWidget {
  const PremiumMatchCard({
    super.key,
    required this.name,
    required this.age,
    required this.imageUrl,
    required this.onTap,
    this.matchPct,
    this.profession,
    this.city,
    this.isOnline = false,
    this.isNew = false,
    this.isVerified = false,
    this.isPremium = false,
    this.onLike,
    this.onSkip,
    this.borderRadius = 20.0,
  });

  final String name;
  final int age;
  final String imageUrl;
  final VoidCallback onTap;

  /// Match percentage — shown as glass pill top-left
  final int? matchPct;

  final String? profession;
  final String? city;

  final bool isOnline;

  /// Shows a "New" badge — recently joined or newly matched
  final bool isNew;

  final bool isVerified;

  /// Shows gold diamond badge
  final bool isPremium;

  final VoidCallback? onLike;
  final VoidCallback? onSkip;

  final double borderRadius;

  @override
  State<PremiumMatchCard> createState() => _PremiumMatchCardState();
}

class _PremiumMatchCardState extends State<PremiumMatchCard>
    with SingleTickerProviderStateMixin {

  late final AnimationController _likeCtrl;
  late final Animation<double> _likeScale;
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    _likeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _likeScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _likeCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _likeCtrl.dispose();
    super.dispose();
  }

  void _onLikeTap() {
    HapticUtils.heavyImpact();
    setState(() => _liked = !_liked);
    _likeCtrl.forward(from: 0);
    widget.onLike?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasActions = widget.onLike != null || widget.onSkip != null;

    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        widget.onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: AppTheme.mediumShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [

              // ── Profile photo ──────────────────────────
              CustomNetworkImage(
                imageUrl: widget.imageUrl,
                borderRadius: 0,
              ),

              // ── Bottom gradient ────────────────────────
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.20),
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    stops: const [0.40, 0.65, 1.0],
                  ),
                ),
              ),

              // ── Top badges row ─────────────────────────
              Positioned(
                top: 10, left: 10, right: 10,
                child: Row(
                  children: [
                    // Match % badge
                    if (widget.matchPct != null)
                      GlassContainer(
                        blur: 10,
                        opacity: 0.25,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        child: Text(
                          '${widget.matchPct}% match',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),

                    const Spacer(),

                    // Online dot
                    if (widget.isOnline)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF4ADE80)
                                .withValues(alpha: 0.50),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6, height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4ADE80),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Online',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // New badge
                    if (widget.isNew && !widget.isOnline) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.brandPrimary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'New',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],

                    // Premium badge
                    if (widget.isPremium) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          gradient: AppTheme.goldGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.diamond_rounded,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ── Bottom info ────────────────────────────
              Positioned(
                bottom: 12, left: 12,
                right: hasActions ? 68 : 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name + age + verified
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${widget.name}, ${widget.age}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.isVerified) ...[
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF60A5FA),
                            size: 14,
                          ),
                        ],
                      ],
                    ),

                    // Profession or city
                    if (widget.profession != null ||
                        widget.city != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (widget.profession != null) widget.profession!,
                          if (widget.city != null) widget.city!,
                        ].join(' · '),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.75),
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // ── Action buttons ─────────────────────────
              if (hasActions)
                Positioned(
                  bottom: 10, right: 10,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Like button
                      if (widget.onLike != null)
                        ScaleTransition(
                          scale: _likeScale,
                          child: GestureDetector(
                            onTap: _onLikeTap,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 38, height: 38,
                              decoration: BoxDecoration(
                                color: _liked
                                    ? AppTheme.brandPrimary
                                    : AppTheme.brandPrimary
                                    .withValues(alpha: 0.85),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.brandPrimary
                                        .withValues(alpha: 0.40),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _liked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),

                      // Skip button
                      if (widget.onSkip != null) ...[
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () {
                            HapticUtils.lightImpact();
                            widget.onSkip!();
                          },
                          child: Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.30),
                              ),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 15,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}