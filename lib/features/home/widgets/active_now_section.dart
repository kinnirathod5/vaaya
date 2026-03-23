import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/premium_avatar.dart';

// ============================================================
// 🟢 ACTIVE NOW SECTION
// Online users horizontal row + "Liked You" locked card
// ============================================================
class ActiveNowSection extends StatelessWidget {
  const ActiveNowSection({
    super.key,
    required this.users,
    required this.radarController,
    required this.onUserTap,
    required this.onLikedYouTap,
  });

  final List<Map<String, dynamic>> users;
  final AnimationController radarController;
  final void Function(Map<String, dynamic> user) onUserTap;
  final VoidCallback onLikedYouTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text(
                'Active Now',
                style: TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.brandDark,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 10),
              _RadarDot(controller: radarController),
              const SizedBox(width: 6),
              const Text(
                'Live',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF16A34A),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Horizontal user list
        SizedBox(
          height: 92,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: users.length + 1, // +1 for "Liked You" card
            itemBuilder: (context, index) {
              if (index == 0) {
                return _LikedYouCard(onTap: onLikedYouTap);
              }
              final user = users[index - 1];
              return _ActiveUserAvatar(
                user: user,
                onTap: () => onUserTap(user),
              );
            },
          ),
        ),
      ],
    );
  }
}


// ── Radar pulse dot ───────────────────────────────────────────
class _RadarDot extends StatelessWidget {
  const _RadarDot({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => Container(
        width: 8, height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF16A34A),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF16A34A)
                  .withValues(alpha: 1 - controller.value),
              blurRadius: 8 * controller.value,
              spreadRadius: 4 * controller.value,
            ),
          ],
        ),
      ),
    );
  }
}


// ── "Liked You" locked card ───────────────────────────────────
class _LikedYouCard extends StatelessWidget {
  const _LikedYouCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFC9962A), Color(0xFFF5C842)],
                ),
              ),
              child: Stack(
                children: [
                  // Blurred avatar
                  ClipOval(
                    child: SizedBox(
                      width: 60, height: 60,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                  'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=crop&w=200&q=80',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                            child: Container(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Lock badge
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Liked You',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFFC9962A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ── Single active user avatar ─────────────────────────────────
class _ActiveUserAvatar extends StatelessWidget {
  const _ActiveUserAvatar({required this.user, required this.onTap});
  final Map<String, dynamic> user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final firstName = (user['name'] as String).split(' ').first;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            PremiumAvatar(
              imageUrl: user['image'],
              size: 62,
              isOnline: true,
              showRing: true,
            ),
            const SizedBox(height: 5),
            Text(
              firstName,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppTheme.brandDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}