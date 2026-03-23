import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_network_image.dart';

// ============================================================
// 📩 RECEIVED REQUEST CARD
// Cinematic full-bleed card with accept / decline buttons
// ============================================================
class ReceivedRequestCard extends StatelessWidget {
  const ReceivedRequestCard({
    super.key,
    required this.profile,
    required this.onTap,
    required this.onAccept,
    required this.onDecline,
  });

  final Map<String, dynamic> profile;
  final VoidCallback onTap;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final bool isOnline = profile['isOnline'] as bool? ?? false;
    final int matchPct  = profile['matchPct']  as int?  ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 210,
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [

              // Photo
              CustomNetworkImage(
                imageUrl: profile['image'],
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
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    stops: const [0.30, 1.0],
                  ),
                ),
              ),

              // Top badges
              Positioned(
                top: 14, left: 14, right: 14,
                child: Row(
                  children: [
                    // Time
                    _GlassBadge(label: '⏱ ${profile['time']}'),
                    const Spacer(),

                    // Online
                    if (isOnline) ...[
                      _OnlineBadge(),
                      const SizedBox(width: 6),
                    ],

                    // Match %
                    if (matchPct > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '🔥 $matchPct%',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.brandPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Bottom — name + chips + action buttons
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Name
                      Text(
                        '${profile['name']}, ${profile['age']}',
                        style: const TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Info chips
                      Row(
                        children: [
                          _MetaChip(icon: Icons.work_outline_rounded,
                              label: profile['profession']),
                          const SizedBox(width: 6),
                          _MetaChip(icon: Icons.location_on_outlined,
                              label: profile['city']),
                          const SizedBox(width: 6),
                          _MetaChip(icon: Icons.school_outlined,
                              label: profile['education']),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Action buttons
                      Row(
                        children: [
                          // Decline
                          Expanded(
                            child: GestureDetector(
                              onTap: onDecline,
                              child: Container(
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.15),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.close_rounded,
                                        color: Colors.white70, size: 15),
                                    SizedBox(width: 4),
                                    Text('Decline', style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white70,
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Accept
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: onAccept,
                              child: Container(
                                height: 42,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.brandGradient,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: AppTheme.primaryGlow,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.favorite_rounded,
                                        color: Colors.white, size: 15),
                                    SizedBox(width: 6),
                                    Text('Accept Interest', style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    )),
                                  ],
                                ),
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
      ),
    );
  }
}

// ── Glass badge ───────────────────────────────────────────────
class _GlassBadge extends StatelessWidget {
  const _GlassBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          child: Text(label, style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          )),
        ),
      ),
    );
  }
}

// ── Online badge ──────────────────────────────────────────────
class _OnlineBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF16A34A).withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF16A34A).withValues(alpha: 0.35),
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
              const Text('Online', style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4ADE80),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Meta chip ─────────────────────────────────────────────────
class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 10),
          const SizedBox(width: 3),
          Text(label, style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          )),
        ],
      ),
    );
  }
}