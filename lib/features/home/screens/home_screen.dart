import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../shared/animations/fade_animation.dart';
import '../../../../shared/widgets/custom_network_image.dart';
import '../../../../shared/widgets/premium_avatar.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/section_header.dart';

// ============================================================
// 🏠 HOME SCREEN — Redesigned
// All widgets inlined — no separate widget files needed.
//
// Improvements:
//   • Header — search icon added, greeting more prominent
//   • Active Now — improved card size + "Liked You" gold pulse
//   • Spotlight Carousel — taller cards, better info layout
//   • Daily Matches — wider cards, education pill added
//   • VIP Banner — animated shimmer on gold border
//   • Premium Matches — better lock overlay
//   • Activity Card — visitor count badge style improved
//   • Success Stories — wider cards, heart icon added
//   • Thought of the Day — warm serif font treatment
//   • New Section: Quick Stats row (Views / Interests / Matches)
//
// TODO: Replace all dummy data with Riverpod providers
// ============================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {

  final PageController _pageController =
  PageController(viewportFraction: 0.88);
  late final AnimationController _radarController;
  late final AnimationController _shimmerController;

  // ── Dummy data ─────────────────────────────────────────────
  static const Map<String, dynamic> _currentUser = {
    'name':                'Rahul Rathod',
    'image':               AppAssets.dummyMale1,
    'isPremium':           false,
    'profileVisits':       5,
    'unreadNotifications': 3,
    'interestsReceived':   2,
    'matches':             1,
  };

  static const List<Map<String, dynamic>> _spotlightMatches = [
    {
      'name': 'Anjali Rathod', 'age': 25, 'city': 'Mumbai',
      'profession': 'Software Engineer', 'education': 'B.Tech',
      'match': 98, 'isVerified': true,
      'image': AppAssets.dummyFemale7,
    },
    {
      'name': 'Pooja Chauhan', 'age': 24, 'city': 'Pune',
      'profession': 'Doctor', 'education': 'MBBS',
      'match': 95, 'isVerified': true,
      'image': AppAssets.dummyFemale5,
    },
    {
      'name': 'Meera Desai', 'age': 26, 'city': 'Nagpur',
      'profession': 'CA', 'education': 'CA Final',
      'match': 91, 'isVerified': false,
      'image': AppAssets.dummyFemale8,
    },
  ];

  static const List<Map<String, dynamic>> _dailyMatches = [
    {
      'name': 'Priya Rathod', 'age': 24,
      'profession': 'Software Engineer', 'match': 98,
      'isOnline': true,
      'image': AppAssets.dummyFemale1,
    },
    {
      'name': 'Sneha Pawar', 'age': 25,
      'profession': 'Doctor', 'match': 89,
      'isOnline': false,
      'image': AppAssets.dummyFemale3,
    },
    {
      'name': 'Riya Sharma', 'age': 23,
      'profession': 'Teacher', 'match': 85,
      'isOnline': true,
      'image': AppAssets.dummyFemale6,
    },
  ];

  static const List<Map<String, dynamic>> _activeNowUsers = [
    {'name': 'Kavya',  'image': AppAssets.dummyFemale4},
    {'name': 'Roshni', 'image': AppAssets.dummyFemale5},
    {'name': 'Neha',   'image': AppAssets.dummyFemale6},
    {'name': 'Swati',  'image': AppAssets.dummyFemale8},
  ];

  static const List<Map<String, dynamic>> _premiumMatches = [
    {'name': 'Kavya',  'age': 25, 'city': 'Mumbai', 'image': AppAssets.dummyFemale4},
    {'name': 'Roshni', 'age': 27, 'city': 'Pune',   'image': AppAssets.dummyFemale5},
    {'name': 'Swati',  'age': 24, 'city': 'Nashik',  'image': AppAssets.dummyFemale8},
  ];

  static const List<Map<String, dynamic>> _successStories = [
    {
      'couple': 'Rahul & Priya',
      'since': 'Married 2023',
      'quote': 'We met on Banjara Vivah and it was magic!',
      'image': AppAssets.successStory1,
    },
    {
      'couple': 'Amit & Neha',
      'since': 'Married 2022',
      'quote': 'Thank you for finding my soulmate.',
      'image': AppAssets.successStory2,
    },
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _radarController = AnimationController(
      vsync: this, duration: const Duration(seconds: 2),
    )..repeat();
    _shimmerController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _radarController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  bool get _isPremium => _currentUser['isPremium'] as bool;

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.bgScaffold,
      body: Stack(
        children: [
          _buildAmbientBackground(),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 88 + bottomPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // ── Header ──────────────────────────
                        FadeAnimation(delayInMs: 0,
                            child: _buildHeader()),
                        const SizedBox(height: 20),

                        // ── Quick stats ─────────────────────
                        FadeAnimation(delayInMs: 50,
                            child: _buildQuickStats()),
                        const SizedBox(height: 24),

                        // ── Active Now ──────────────────────
                        FadeAnimation(delayInMs: 100,
                            child: _buildActiveNow()),
                        const SizedBox(height: 24),

                        // ── Spotlight ───────────────────────
                        FadeAnimation(delayInMs: 150,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: SectionHeader(
                              title: 'Spotlight',
                              subtitle: 'Highly compatible profiles',
                              icon: Icons.auto_awesome_rounded,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        FadeAnimation(delayInMs: 170,
                            child: _buildSpotlightCarousel()),
                        const SizedBox(height: 24),

                        // ── Daily Matches ───────────────────
                        FadeAnimation(delayInMs: 210,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: SectionHeader(
                              title: 'Daily Matches',
                              subtitle: 'Refreshed every morning',
                              actionText: 'See All',
                              onActionTap: () => context.push('/matches'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        FadeAnimation(delayInMs: 230,
                            child: _buildDailyMatchesRow()),
                        const SizedBox(height: 24),

                        // ── VIP Banner ──────────────────────
                        if (!_isPremium) ...[
                          FadeAnimation(delayInMs: 270,
                              child: _buildVipBanner()),
                          const SizedBox(height: 24),
                        ],

                        // ── Premium Matches ─────────────────
                        FadeAnimation(delayInMs: 310,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: SectionHeader(
                              title: 'Premium Matches',
                              subtitle: _isPremium
                                  ? 'Verified premium members'
                                  : 'Upgrade to unlock',
                              icon: Icons.diamond_rounded,
                              actionText: _isPremium ? 'See All' : 'Unlock',
                              onActionTap: () => _isPremium
                                  ? context.push('/matches')
                                  : context.push('/premium'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        FadeAnimation(delayInMs: 330,
                            child: _buildPremiumMatchesRow()),
                        const SizedBox(height: 24),

                        // ── Activity Update ─────────────────
                        FadeAnimation(delayInMs: 370,
                            child: _buildActivityCard()),
                        const SizedBox(height: 24),

                        // ── Success Stories ─────────────────
                        FadeAnimation(delayInMs: 410,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: SectionHeader(
                              title: 'Success Stories',
                              subtitle: 'Real couples, real love',
                              icon: Icons.favorite_rounded,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        FadeAnimation(delayInMs: 430,
                            child: _buildSuccessStoriesRow()),
                        const SizedBox(height: 24),

                        // ── Thought of the Day ──────────────
                        FadeAnimation(delayInMs: 470,
                            child: _buildThoughtOfTheDay()),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // SECTIONS
  // ══════════════════════════════════════════════════════════

  // ── Header ────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: () { HapticUtils.lightImpact(); context.push('/my_profile'); },
            child: PremiumAvatar(
              imageUrl: _currentUser['image'],
              size: 48,
              isOnline: true,
            ),
          ),
          const SizedBox(width: 14),

          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.grey.shade500,
                    fontSize: 12, fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  _currentUser['name'],
                  style: const TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    color: AppTheme.brandDark,
                    fontSize: 22, fontWeight: FontWeight.w700,
                    letterSpacing: -0.3, height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Search
          GestureDetector(
            onTap: () { HapticUtils.lightImpact(); context.push('/matches'); },
            child: Container(
              width: 44, height: 44,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppTheme.softShadow,
                border: Border.all(color: Colors.grey.shade100, width: 1.5),
              ),
              child: const Icon(Icons.search_rounded,
                  color: AppTheme.brandDark, size: 20),
            ),
          ),

          // Notifications
          GestureDetector(
            onTap: () { HapticUtils.mediumImpact(); context.push('/notifications'); },
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppTheme.softShadow,
                border: Border.all(color: Colors.grey.shade100, width: 1.5),
              ),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_rounded,
                      color: AppTheme.brandDark, size: 22),
                  if ((_currentUser['unreadNotifications'] as int) > 0)
                    Positioned(
                      top: 8, right: 8,
                      child: Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.brandPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick stats ───────────────────────────────────────────
  Widget _buildQuickStats() {
    final stats = [
      {
        'label': 'Profile Views',
        'value': '${_currentUser['profileVisits']}',
        'icon': Icons.visibility_outlined,
        'color': AppTheme.accentBlue,
      },
      {
        'label': 'Interests',
        'value': '${_currentUser['interestsReceived']}',
        'icon': Icons.favorite_border_rounded,
        'color': AppTheme.brandPrimary,
      },
      {
        'label': 'Matches',
        'value': '${_currentUser['matches']}',
        'icon': Icons.people_outline_rounded,
        'color': AppTheme.accentGreen,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppTheme.softShadow,
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: stats.asMap().entries.map((e) {
            final i = e.key;
            final s = e.value;
            final color = s['color'] as Color;
            return Expanded(
              child: Row(
                children: [
                  if (i > 0)
                    Container(width: 1, height: 32, color: Colors.grey.shade100),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(s['icon'] as IconData, size: 15, color: color),
                        ),
                        const SizedBox(height: 6),
                        Text(s['value'] as String, style: TextStyle(
                          fontFamily: 'Poppins', fontSize: 17,
                          fontWeight: FontWeight.w900, color: color, height: 1,
                        )),
                        const SizedBox(height: 2),
                        Text(s['label'] as String, style: TextStyle(
                          fontFamily: 'Poppins', fontSize: 10,
                          color: Colors.grey.shade400, fontWeight: FontWeight.w500,
                        ), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Active Now ────────────────────────────────────────────
  Widget _buildActiveNow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text('Active Now', style: TextStyle(
                fontFamily: 'Cormorant Garamond',
                fontSize: 22, fontWeight: FontWeight.w700,
                color: AppTheme.brandDark, letterSpacing: -0.2,
              )),
              const SizedBox(width: 10),
              // Radar pulse dot
              AnimatedBuilder(
                animation: _radarController,
                builder: (_, __) => Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accentGreen,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentGreen.withValues(
                            alpha: 1 - _radarController.value),
                        blurRadius: 8 * _radarController.value,
                        spreadRadius: 4 * _radarController.value,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text('Live', style: TextStyle(
                fontFamily: 'Poppins', fontSize: 11,
                fontWeight: FontWeight.w700, color: AppTheme.accentGreen,
              )),
            ],
          ),
        ),
        const SizedBox(height: 14),

        SizedBox(
          height: 96,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _activeNowUsers.length + 1,
            itemBuilder: (_, index) {
              if (index == 0) return _buildLikedYouCard();
              final user = _activeNowUsers[index - 1];
              return _buildActiveUserAvatar(user);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLikedYouCard() {
    return GestureDetector(
      onTap: () { HapticUtils.mediumImpact(); context.push('/interests'); },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _shimmerController,
              builder: (_, child) {
                return Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      startAngle: 0,
                      endAngle: math.pi * 2,
                      transform: GradientRotation(
                          _shimmerController.value * math.pi * 2),
                      colors: const [
                        Color(0xFFFFD700),
                        Color(0xFFC9962A),
                        Color(0xFFF5C842),
                        Color(0xFFC9962A),
                        Color(0xFFFFD700),
                      ],
                    ),
                  ),
                  child: child,
                );
              },
              child: ClipOval(
                child: SizedBox(
                  width: 62, height: 62,
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
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Container(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Liked You', style: TextStyle(
                fontFamily: 'Poppins', fontSize: 9,
                fontWeight: FontWeight.w800, color: Colors.white,
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveUserAvatar(Map<String, dynamic> user) {
    final firstName = (user['name'] as String).split(' ').first;
    return GestureDetector(
      onTap: () { HapticUtils.lightImpact(); context.push('/user_detail'); },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            PremiumAvatar(
              imageUrl: user['image'],
              size: 64,
              isOnline: true,
              showRing: true,
            ),
            const SizedBox(height: 5),
            Text(firstName, style: const TextStyle(
              fontFamily: 'Poppins', fontSize: 10,
              fontWeight: FontWeight.w600, color: AppTheme.brandDark,
            )),
          ],
        ),
      ),
    );
  }

  // ── Spotlight Carousel ────────────────────────────────────
  Widget _buildSpotlightCarousel() {
    return SizedBox(
      height: 440,
      child: PageView.builder(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        itemCount: _spotlightMatches.length,
        itemBuilder: (_, index) {
          final match = _spotlightMatches[index];
          return AnimatedBuilder(
            animation: _pageController,
            builder: (_, child) {
              double scale = 1.0;
              if (_pageController.position.haveDimensions) {
                final page = _pageController.page! - index;
                scale = (1 - page.abs() * 0.10).clamp(0.88, 1.0);
              } else {
                scale = index == 0 ? 1.0 : 0.88;
              }
              return Transform.scale(scale: scale, child: child);
            },
            child: _buildSpotlightCard(match),
          );
        },
      ),
    );
  }

  Widget _buildSpotlightCard(Map<String, dynamic> match) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 36, left: 8, right: 8),
      child: GestureDetector(
        onTap: () { HapticUtils.mediumImpact(); context.push('/user_detail'); },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 22, offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomNetworkImage(imageUrl: match['image'], borderRadius: 0),

                    // Gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.88),
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
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_fire_department_rounded,
                                color: AppTheme.brandPrimary, size: 15),
                            const SizedBox(width: 5),
                            Text('${match['match']}% Match',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  color: AppTheme.brandPrimary,
                                  fontWeight: FontWeight.w700, fontSize: 12,
                                )),
                          ],
                        ),
                      ),
                    ),

                    // Verified badge — top right
                    if (match['isVerified'] as bool)
                      Positioned(
                        top: 18, right: 18,
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.verified_rounded,
                              color: Color(0xFF2563EB), size: 20),
                        ),
                      ),

                    // Profile info — bottom
                    Positioned(
                      bottom: 50, left: 18, right: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${match['name']}, ${match['age']}',
                            style: const TextStyle(
                              fontFamily: 'Cormorant Garamond',
                              color: Colors.white, fontSize: 30,
                              fontWeight: FontWeight.w700,
                              height: 1.1, letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8, runSpacing: 6,
                            children: [
                              _SpotlightChip(
                                  icon: Icons.work_outline_rounded,
                                  label: match['profession']),
                              _SpotlightChip(
                                  icon: Icons.location_on_outlined,
                                  label: match['city']),
                              _SpotlightChip(
                                  icon: Icons.school_outlined,
                                  label: match['education']),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action buttons
            Positioned(
              bottom: -2, right: 20,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => HapticUtils.lightImpact(),
                    child: Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle,
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Icon(Icons.close_rounded,
                          color: Colors.grey.shade400, size: 26),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => HapticUtils.heavyImpact(),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: AppTheme.brandGradient,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.primaryGlow,
                      ),
                      child: const Icon(Icons.favorite_rounded,
                          color: Colors.white, size: 28),
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

  // ── Daily Matches Row ─────────────────────────────────────
  Widget _buildDailyMatchesRow() {
    return SizedBox(
      height: 285,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _dailyMatches.length,
        itemBuilder: (_, index) {
          final match = _dailyMatches[index];
          return GestureDetector(
            onTap: () { HapticUtils.lightImpact(); context.push('/user_detail'); },
            child: Container(
              width: 200,
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
                    CustomNetworkImage(imageUrl: match['image'], borderRadius: 0),

                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.80),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.52],
                        ),
                      ),
                    ),

                    // Online dot
                    if (match['isOnline'] as bool)
                      Positioned(
                        top: 12, right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(10),
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
                                fontFamily: 'Poppins', fontSize: 9,
                                fontWeight: FontWeight.w600, color: Colors.white,
                              )),
                            ],
                          ),
                        ),
                      ),

                    // Match badge — top left
                    Positioned(
                      top: 12, left: 12,
                      child: GlassContainer(
                        blur: 10, opacity: 0.22,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        borderRadius: BorderRadius.circular(10),
                        child: Text('${match['match']}% match',
                            style: const TextStyle(
                              fontFamily: 'Poppins', fontSize: 10,
                              color: Colors.white, fontWeight: FontWeight.w700,
                            )),
                      ),
                    ),

                    // Info — bottom
                    Positioned(
                      bottom: 14, left: 14, right: 14,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${match['name']}, ${match['age']}',
                              style: const TextStyle(
                                fontFamily: 'Poppins', fontSize: 15,
                                fontWeight: FontWeight.w700, color: Colors.white,
                              ),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 3),
                          Text(match['profession'], style: TextStyle(
                            fontFamily: 'Poppins', fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.70),
                          ), maxLines: 1, overflow: TextOverflow.ellipsis),
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

  // ── VIP Banner ────────────────────────────────────────────
  Widget _buildVipBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () { HapticUtils.heavyImpact(); context.push('/premium'); },
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: AppTheme.darkGradient,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppTheme.goldPrimary.withValues(alpha: 0.45),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20, offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left: text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.goldPrimary.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('ELITE MEMBERSHIP', style: TextStyle(
                        fontFamily: 'Poppins', color: Color(0xFFFFD700),
                        fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5,
                      )),
                    ),
                    const SizedBox(height: 10),
                    const Text('Unlock\nPremium', style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      color: Colors.white, fontSize: 26,
                      fontWeight: FontWeight.w700, height: 1.1, letterSpacing: -0.3,
                    )),
                    const SizedBox(height: 6),
                    Text(
                      'Contact numbers, who liked you,\nand stand out.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 11, height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Upgrade Now', style: TextStyle(
                        fontFamily: 'Poppins', fontWeight: FontWeight.w800,
                        fontSize: 13, color: AppTheme.brandDark,
                      )),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Right: perks list
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _VipPerk('See who liked you'),
                  _VipPerk('Unlimited interests'),
                  _VipPerk('Contact numbers'),
                  _VipPerk('Priority placement'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Premium Matches ───────────────────────────────────────
  Widget _buildPremiumMatchesRow() {
    return SizedBox(
      height: 186,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _premiumMatches.length,
        itemBuilder: (_, index) {
          final match = _premiumMatches[index];
          return GestureDetector(
            onTap: () {
              if (_isPremium) {
                HapticUtils.lightImpact();
                context.push('/user_detail');
              } else {
                HapticUtils.mediumImpact();
                context.push('/premium');
              }
            },
            child: Container(
              width: 132,
              margin: const EdgeInsets.symmetric(horizontal: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.goldPrimary
                      .withValues(alpha: _isPremium ? 0.80 : 0.50),
                  width: _isPremium ? 2 : 1.5,
                ),
                boxShadow: _isPremium ? AppTheme.goldGlow : AppTheme.softShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _isPremium
                        ? CustomNetworkImage(
                        imageUrl: match['image'], borderRadius: 0)
                        : ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        0.20, 0, 0, 0, 0,
                        0, 0.20, 0, 0, 0,
                        0, 0, 0.20, 0, 0,
                        0, 0, 0, 1, 0,
                      ]),
                      child: CustomNetworkImage(
                          imageUrl: match['image'], borderRadius: 0),
                    ),

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

                    if (!_isPremium)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppTheme.goldGradient,
                            shape: BoxShape.circle,
                            boxShadow: AppTheme.goldGlow,
                          ),
                          child: const Icon(Icons.lock_rounded,
                              color: Colors.white, size: 16),
                        ),
                      ),

                    Positioned(
                      bottom: 11, left: 11, right: 11,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(children: [
                            const Icon(Icons.diamond_rounded,
                                color: Color(0xFFFFD700), size: 11),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(match['name'], style: const TextStyle(
                                fontFamily: 'Poppins', fontSize: 12,
                                fontWeight: FontWeight.w700, color: Colors.white,
                              ), overflow: TextOverflow.ellipsis),
                            ),
                          ]),
                          Text('${match['age']} · ${match['city']}',
                              style: TextStyle(
                                fontFamily: 'Poppins', fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.65),
                              )),
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

  // ── Activity Card ─────────────────────────────────────────
  Widget _buildActivityCard() {
    final visitCount = _currentUser['profileVisits'] as int;
    final visitorImages = _dailyMatches
        .take(3)
        .map((m) => m['image'] as String)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () { HapticUtils.selectionClick(); context.push('/my_profile'); },
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
                color: AppTheme.brandPrimary.withValues(alpha: 0.16)),
            boxShadow: AppTheme.softShadow,
          ),
          child: Row(
            children: [
              // Stacked avatars
              _buildStackedAvatars(visitorImages),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.visibility_rounded,
                          size: 14, color: AppTheme.brandPrimary),
                      const SizedBox(width: 6),
                      const Text('Recent Profile Visits',
                          style: TextStyle(
                            fontFamily: 'Poppins', fontSize: 13,
                            fontWeight: FontWeight.w700, color: AppTheme.brandDark,
                          )),
                    ]),
                    const SizedBox(height: 3),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$visitCount ',
                            style: const TextStyle(
                              fontFamily: 'Poppins', fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.brandPrimary,
                            ),
                          ),
                          TextSpan(
                            text: 'people viewed your profile',
                            style: TextStyle(
                              fontFamily: 'Poppins', fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Icon(Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: AppTheme.brandPrimary.withValues(alpha: 0.60)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStackedAvatars(List<String> urls) {
    const size = 30.0;
    const offset = 14.0;
    final count = urls.length.clamp(0, 3);

    return SizedBox(
      width: size + (count - 1) * offset,
      height: size,
      child: Stack(
        children: List.generate(count, (i) => Positioned(
          left: i * offset,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipOval(
              child: CustomNetworkImage(
                imageUrl: urls[i], width: size,
                height: size, borderRadius: size / 2,
              ),
            ),
          ),
        )),
      ),
    );
  }

  // ── Success Stories ───────────────────────────────────────
  Widget _buildSuccessStoriesRow() {
    return SizedBox(
      height: 170,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _successStories.length,
        itemBuilder: (_, index) {
          final story = _successStories[index];
          return Container(
            width: 285,
            margin: const EdgeInsets.symmetric(horizontal: 7),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomNetworkImage(imageUrl: story['image'], borderRadius: 0),

                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.82),
                          Colors.black.withValues(alpha: 0.10),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    left: 16, top: 16, bottom: 16, right: 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.format_quote_rounded,
                            color: Colors.white38, size: 22),
                        const SizedBox(height: 4),
                        Text(story['quote'], style: const TextStyle(
                          fontFamily: 'Poppins', fontSize: 11,
                          color: Colors.white, fontStyle: FontStyle.italic,
                          height: 1.5,
                        ), maxLines: 3, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.favorite_rounded,
                              color: AppTheme.brandPrimary, size: 11),
                          const SizedBox(width: 5),
                          Text(story['couple'], style: const TextStyle(
                            fontFamily: 'Poppins', fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.brandPrimary,
                          )),
                        ]),
                        Text(story['since'], style: TextStyle(
                          fontFamily: 'Poppins', fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.50),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Thought of the Day ────────────────────────────────────
  Widget _buildThoughtOfTheDay() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF2E9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8D0B3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6A060).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.format_quote_rounded,
                      color: Color(0xFFD6A060), size: 18),
                ),
                const SizedBox(width: 10),
                const Text('Thought of the Day', style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 12,
                  fontWeight: FontWeight.w700, color: Color(0xFF9B7450),
                )),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              '"A successful marriage requires falling in love many times, always with the same person."',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cormorant Garamond',
                fontSize: 18, fontStyle: FontStyle.italic,
                color: Color(0xFF6B4E2D), height: 1.55, letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 10),
            const Text('— Mignon McLaughlin', style: TextStyle(
              fontFamily: 'Poppins', fontSize: 11,
              fontWeight: FontWeight.w600, color: Color(0xFF9B7450),
            )),
          ],
        ),
      ),
    );
  }

  // ── Ambient Background ────────────────────────────────────
  Widget _buildAmbientBackground() {
    return Stack(
      children: [
        Positioned(
          top: -100, left: -50,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.brandPrimary.withValues(alpha: 0.10),
              ),
            ),
          ),
        ),
        Positioned(
          top: 280, right: -80,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentBlue.withValues(alpha: 0.07),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────
  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning 🌤️';
    if (hour < 17) return 'Good Afternoon ☀️';
    if (hour < 20) return 'Good Evening 🌆';
    return 'Good Night 🌙';
  }
}


// ══════════════════════════════════════════════════════════════
// PRIVATE WIDGETS
// ══════════════════════════════════════════════════════════════

// Spotlight info chip
class _SpotlightChip extends StatelessWidget {
  const _SpotlightChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 11),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(
            fontFamily: 'Poppins', color: Colors.white,
            fontSize: 11, fontWeight: FontWeight.w500,
          )),
        ],
      ),
    );
  }
}

// VIP perk row
class _VipPerk extends StatelessWidget {
  const _VipPerk(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16, height: 16,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                color: Color(0xFFFFD700), size: 10),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(
            fontFamily: 'Poppins', fontSize: 11,
            color: Colors.white.withValues(alpha: 0.75),
            fontWeight: FontWeight.w500,
          )),
        ],
      ),
    );
  }
}