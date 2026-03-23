import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../shared/animations/fade_animation.dart';
import '../../../../shared/widgets/section_header.dart';

import '../widgets/home_header.dart';
import '../widgets/active_now_section.dart';
import '../widgets/spotlight_carousel.dart';
import '../widgets/daily_matches_row.dart';
import '../widgets/vip_banner_card.dart';
import '../widgets/premium_matches_row.dart';
import '../widgets/activity_update_card.dart';
import '../widgets/success_stories_row.dart';
import '../widgets/thought_of_the_day.dart';

// ============================================================
// 🏠 HOME SCREEN
// Main discovery screen — scrollable, section-based layout.
//
// Sections:
//   Header → greeting + avatar + notifications
//   Active Now → online users with radar animation
//   Spotlight → curated high-match carousel
//   Daily Matches → horizontal scroll row
//   VIP Banner → shown only for non-premium users
//   Premium Matches → blurred for non-premium
//   Activity Update → profile visits card
//   Success Stories → couple testimonials
//   Thought of the Day → motivational quote
//
// TODO: Replace all dummy data with Riverpod providers:
//   userProvider.currentUser
//   matchesProvider.spotlightMatches
//   matchesProvider.dailyMatches
//   matchesProvider.premiumMatches
//   notificationsProvider.unreadCount
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

  // ── Dummy data — TODO: replace with providers ─────────────

  static const Map<String, dynamic> _currentUser = {
    'name':                 'Rahul Rathod',
    'image':                AppAssets.dummyMale1,
    'isPremium':            false,
    'profileVisits':        5,
    'unreadNotifications':  3,
  };

  static const List<Map<String, dynamic>> _spotlightMatches = [
    {
      'name': 'Anjali Rathod', 'age': 25, 'city': 'Mumbai',
      'profession': 'Software Engineer', 'match': 98,
      'image': AppAssets.dummyFemale7,
    },
    {
      'name': 'Pooja Chauhan', 'age': 24, 'city': 'Pune',
      'profession': 'Doctor', 'match': 95,
      'image': AppAssets.dummyFemale5,
    },
    {
      'name': 'Meera Desai', 'age': 26, 'city': 'Nagpur',
      'profession': 'CA', 'match': 91,
      'image': AppAssets.dummyFemale8,
    },
  ];

  static const List<Map<String, dynamic>> _dailyMatches = [
    {
      'name': 'Priya Rathod', 'age': 24,
      'profession': 'Software Engineer', 'match': 98,
      'image': AppAssets.dummyFemale1,
    },
    {
      'name': 'Sneha Pawar', 'age': 25,
      'profession': 'Doctor', 'match': 89,
      'image': AppAssets.dummyFemale3,
    },
    {
      'name': 'Riya Sharma', 'age': 23,
      'profession': 'Teacher', 'match': 85,
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

  // ── Lifecycle ─────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _radarController.dispose();
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
                    padding: EdgeInsets.only(bottom: 80 + bottomPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // ── Header ───────────────────────────
                        FadeAnimation(
                          delayInMs: 0,
                          child: HomeHeader(
                            userName: _currentUser['name'],
                            userImage: _currentUser['image'],
                            notificationCount:
                            _currentUser['unreadNotifications'],
                            onProfileTap: () {
                              HapticUtils.lightImpact();
                              context.push('/my_profile');
                            },
                            onNotificationTap: () {
                              HapticUtils.mediumImpact();
                              context.push('/notifications');
                            },
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Active Now ───────────────────────
                        FadeAnimation(
                          delayInMs: 80,
                          child: ActiveNowSection(
                            users: _activeNowUsers,
                            radarController: _radarController,
                            onUserTap: (_) {
                              HapticUtils.lightImpact();
                              context.push('/user_detail');
                            },
                            onLikedYouTap: () {
                              HapticUtils.mediumImpact();
                              context.push('/interests');
                            },
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Spotlight ────────────────────────
                        FadeAnimation(
                          delayInMs: 140,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: SectionHeader(
                              title: 'Spotlight',
                              subtitle: 'Highly compatible profiles',
                              icon: Icons.auto_awesome_rounded,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        FadeAnimation(
                          delayInMs: 160,
                          child: SpotlightCarousel(
                            matches: _spotlightMatches,
                            pageController: _pageController,
                            onMatchTap: (_) {
                              HapticUtils.mediumImpact();
                              context.push('/user_detail');
                            },
                            onLike: (_) => HapticUtils.heavyImpact(),
                            onReject: (_) => HapticUtils.lightImpact(),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Daily Matches ────────────────────
                        FadeAnimation(
                          delayInMs: 200,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: SectionHeader(
                              title: 'Daily Matches',
                              subtitle: 'Refreshed every morning',
                              actionText: 'See All',
                              onActionTap: () =>
                                  context.push('/matches'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        FadeAnimation(
                          delayInMs: 220,
                          child: DailyMatchesRow(
                            matches: _dailyMatches,
                            onMatchTap: (_) {
                              HapticUtils.lightImpact();
                              context.push('/user_detail');
                            },
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── VIP Banner — non-premium only ────
                        if (!_isPremium) ...[
                          FadeAnimation(
                            delayInMs: 260,
                            child: VipBannerCard(
                              onUpgradeTap: () {
                                HapticUtils.heavyImpact();
                                context.push('/premium');
                              },
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],

                        // ── Premium Matches ──────────────────
                        FadeAnimation(
                          delayInMs: 300,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
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
                        FadeAnimation(
                          delayInMs: 320,
                          child: PremiumMatchesRow(
                            matches: _premiumMatches,
                            isLocked: !_isPremium,
                            onMatchTap: (_) {
                              if (_isPremium) {
                                HapticUtils.lightImpact();
                                context.push('/user_detail');
                              } else {
                                HapticUtils.mediumImpact();
                                context.push('/premium');
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Activity Update ──────────────────
                        FadeAnimation(
                          delayInMs: 360,
                          child: ActivityUpdateCard(
                            visitorCount: _currentUser['profileVisits'],
                            visitorImages: _dailyMatches
                                .take(3)
                                .map((m) => m['image'] as String)
                                .toList(),
                            onTap: () {
                              HapticUtils.selectionClick();
                              context.push('/my_profile');
                            },
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Success Stories ──────────────────
                        FadeAnimation(
                          delayInMs: 400,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: SectionHeader(
                              title: 'Success Stories',
                              subtitle: 'Real couples, real love',
                              icon: Icons.favorite_rounded,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        FadeAnimation(
                          delayInMs: 420,
                          child: SuccessStoriesRow(
                            stories: _successStories,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ── Thought of the Day ───────────────
                        FadeAnimation(
                          delayInMs: 460,
                          child: const ThoughtOfTheDay(),
                        ),
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

  // ── Ambient background glow ───────────────────────────────
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
                color: Colors.blueAccent.withValues(alpha: 0.07),
              ),
            ),
          ),
        ),
      ],
    );
  }
}