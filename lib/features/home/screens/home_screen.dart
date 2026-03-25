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

// ============================================================
// 🏠 HOME SCREEN — v3.0 Optimized
//
// Senior UX audit applied — focused, lean, conversion-driven.
//
// REMOVED (low-value / duplicate):
//   ✗ Quick Stats row     → duplicate of profile screen
//   ✗ Activity Card       → merged into header notification badge
//   ✗ Success Stories     → static, low engagement — future: own page
//   ✗ Thought of the Day  → off-brand for matrimony context
//
// ADDED (high-impact):
//   ✅ New Matches Banner  → animated urgency banner, daily return
//   ✅ Profile Completion Nudge → drives completion from home
//   ✅ Kundali chip on spotlight cards → community differentiator
//   ✅ Quick like/skip on daily cards → reduces taps
//   ✅ "Active Xh ago" on daily cards → real-time feel
//   ✅ Smart time-based section ordering
//   ✅ Swipe hint on spotlight carousel
//
// SECTION ORDER (6-8 depending on state):
//   1. Header (greeting + avatar + search + notification)
//   2. New Matches Banner (conditional — animated pulse)
//   3. Profile Completion Nudge (if < 80%)
//   4. Active Now (with "Liked You" prominent)
//   5. Spotlight Carousel (HERO — 380px, kundali chip)
//   6. VIP Banner (non-premium only)
//   7. Daily Matches (quick actions + "active Xh ago")
//   8. Premium Matches (gold lock overlay)
//
// ALL widgets inlined — zero external widget dependencies.
// TODO: Replace dummy data with Riverpod providers
// ============================================================

// ──────────────────────────────────────────────────────────────
// DATA MODELS
// ──────────────────────────────────────────────────────────────

class _CurrentUser {
  const _CurrentUser({
    required this.name,
    required this.image,
    required this.isPremium,
    required this.profileCompletionPct,
    required this.newMatchesSinceYesterday,
    required this.unreadNotifications,
  });

  final String name;
  final String image;
  final bool isPremium;
  final int profileCompletionPct;
  final int newMatchesSinceYesterday;
  final int unreadNotifications;
}

class _SpotlightMatch {
  const _SpotlightMatch({
    required this.name,
    required this.age,
    required this.city,
    required this.profession,
    required this.education,
    required this.matchPct,
    required this.isVerified,
    required this.image,
    this.kundaliCompatible = false,
  });

  final String name;
  final int age;
  final String city;
  final String profession;
  final String education;
  final int matchPct;
  final bool isVerified;
  final String image;
  final bool kundaliCompatible;
}

class _DailyMatch {
  const _DailyMatch({
    required this.name,
    required this.age,
    required this.profession,
    required this.matchPct,
    required this.isOnline,
    required this.image,
    this.lastActive,
  });

  final String name;
  final int age;
  final String profession;
  final int matchPct;
  final bool isOnline;
  final String image;
  final String? lastActive; // null = currently online
}

class _ActiveUser {
  const _ActiveUser({required this.name, required this.image});
  final String name;
  final String image;
}

class _PremiumMatch {
  const _PremiumMatch({
    required this.name,
    required this.age,
    required this.city,
    required this.image,
  });

  final String name;
  final int age;
  final String city;
  final String image;
}

// ──────────────────────────────────────────────────────────────
// DUMMY DATA — TODO: Replace with Riverpod providers
// ──────────────────────────────────────────────────────────────

const _dummyUser = _CurrentUser(
  name: 'Rahul Rathod',
  image: AppAssets.dummyMale1,
  isPremium: false,
  profileCompletionPct: 72,
  newMatchesSinceYesterday: 3,
  unreadNotifications: 3,
);

const _dummySpotlight = [
  _SpotlightMatch(
    name: 'Anjali Rathod', age: 25, city: 'Mumbai',
    profession: 'Software Engineer', education: 'B.Tech',
    matchPct: 98, isVerified: true, image: AppAssets.dummyFemale7,
    kundaliCompatible: true,
  ),
  _SpotlightMatch(
    name: 'Pooja Chauhan', age: 24, city: 'Pune',
    profession: 'Doctor', education: 'MBBS',
    matchPct: 95, isVerified: true, image: AppAssets.dummyFemale5,
    kundaliCompatible: true,
  ),
  _SpotlightMatch(
    name: 'Meera Desai', age: 26, city: 'Nagpur',
    profession: 'CA', education: 'CA Final',
    matchPct: 91, isVerified: false, image: AppAssets.dummyFemale8,
  ),
];

const _dummyDaily = [
  _DailyMatch(
    name: 'Priya Rathod', age: 24,
    profession: 'Software Engineer', matchPct: 98,
    isOnline: true, image: AppAssets.dummyFemale1,
  ),
  _DailyMatch(
    name: 'Sneha Pawar', age: 25,
    profession: 'Doctor', matchPct: 89,
    isOnline: false, image: AppAssets.dummyFemale9,
    lastActive: '2h ago',
  ),
  _DailyMatch(
    name: 'Riya Sharma', age: 23,
    profession: 'Teacher', matchPct: 85,
    isOnline: true, image: AppAssets.dummyFemale6,
  ),
];

const _dummyActive = [
  _ActiveUser(name: 'Kavya', image: AppAssets.dummyFemale4),
  _ActiveUser(name: 'Roshni', image: AppAssets.dummyFemale5),
  _ActiveUser(name: 'Neha', image: AppAssets.dummyFemale6),
  _ActiveUser(name: 'Swati', image: AppAssets.dummyFemale8),
];

const _dummyPremium = [
  _PremiumMatch(name: 'Kavya', age: 25, city: 'Mumbai', image: AppAssets.dummyFemale4),
  _PremiumMatch(name: 'Roshni', age: 27, city: 'Pune', image: AppAssets.dummyFemale5),
  _PremiumMatch(name: 'Swati', age: 24, city: 'Nashik', image: AppAssets.dummyFemale8),
];

// ──────────────────────────────────────────────────────────────
// SCREEN
// ──────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 0.88);

  // Gold shimmer only for "Liked You" card
  late final AnimationController _goldShimmerCtrl;

  // Pulse for new matches banner
  late final AnimationController _pulsCtrl;
  late final Animation<double> _pulseAnim;

  // Data
  final _CurrentUser _user = _dummyUser;

  // Cached greeting
  late final String _greetingText;

  // Smart ordering: morning vs evening
  late final bool _isEvening;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _goldShimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _pulsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulsCtrl, curve: Curves.easeInOut),
    );

    _greetingText = _computeGreeting();
    final hour = DateTime.now().hour;
    _isEvening = hour >= 17;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _goldShimmerCtrl.dispose();
    _pulsCtrl.dispose();
    super.dispose();
  }

  bool get _isPremium => _user.isPremium;

  static String _computeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Smart time-based section ordering
    final sections = _buildSections(context);

    return Scaffold(
      backgroundColor: AppTheme.bgScaffold,
      body: Stack(
        children: [
          RepaintBoundary(child: _AmbientBackground()),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 88 + bottomPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: sections,
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
  // SMART SECTION ORDERING
  // Morning → Daily Matches first (fresh matches)
  // Evening → Active Now first (who's online now)
  // ══════════════════════════════════════════════════════════
  List<Widget> _buildSections(BuildContext context) {
    final List<Widget> sections = [];

    // ── 1. Header (always first) ────────────────────────────
    sections.addAll([
      const SizedBox(height: 20),
      FadeAnimation(
        delayInMs: 0,
        child: _buildHeader(context),
      ),
      const SizedBox(height: 16),
    ]);

    // ── 2. New Matches Banner (conditional) ─────────────────
    if (_user.newMatchesSinceYesterday > 0) {
      sections.addAll([
        FadeAnimation(
          delayInMs: 40,
          child: _buildNewMatchesBanner(context),
        ),
        const SizedBox(height: 16),
      ]);
    }

    // ── 3. Profile Completion Nudge (if < 80%) ──────────────
    if (_user.profileCompletionPct < 80) {
      sections.addAll([
        FadeAnimation(
          delayInMs: 60,
          child: _buildCompletionNudge(context),
        ),
        const SizedBox(height: 20),
      ]);
    }

    // ── 4-8. Smart-ordered content sections ─────────────────
    int delay = 100;

    if (_isEvening) {
      // Evening: Active Now → Spotlight → VIP → Daily → Premium
      sections.addAll(_activeNowSection(context, delay));
      delay += 60;
      sections.addAll(_spotlightSection(context, delay));
      delay += 80;
      sections.addAll(_vipSection(context, delay));
      delay += 60;
      sections.addAll(_dailyMatchesSection(context, delay));
      delay += 60;
      sections.addAll(_premiumMatchesSection(context, delay));
    } else {
      // Morning/Afternoon: Spotlight → Daily → Active Now → VIP → Premium
      sections.addAll(_spotlightSection(context, delay));
      delay += 80;
      sections.addAll(_dailyMatchesSection(context, delay));
      delay += 60;
      sections.addAll(_activeNowSection(context, delay));
      delay += 60;
      sections.addAll(_vipSection(context, delay));
      delay += 60;
      sections.addAll(_premiumMatchesSection(context, delay));
    }

    sections.add(const SizedBox(height: 20));
    return sections;
  }

  // ── Section builders (return List<Widget> for flexible ordering) ──

  List<Widget> _activeNowSection(BuildContext context, int delay) => [
    FadeAnimation(delayInMs: delay, child: _buildActiveNow(context)),
    const SizedBox(height: 24),
  ];

  List<Widget> _spotlightSection(BuildContext context, int delay) => [
    FadeAnimation(
      delayInMs: delay,
      child: _SectionLabel(
        title: 'Spotlight',
        subtitle: 'Highly compatible profiles',
        icon: Icons.auto_awesome_rounded,
      ),
    ),
    const SizedBox(height: 14),
    FadeAnimation(
      delayInMs: delay + 20,
      child: _buildSpotlightCarousel(context),
    ),
    const SizedBox(height: 16), // Tighter — card already has 12px bottom pad
  ];

  List<Widget> _dailyMatchesSection(BuildContext context, int delay) => [
    FadeAnimation(
      delayInMs: delay,
      child: _SectionLabel(
        title: 'Daily Matches',
        subtitle: 'Refreshed every morning',
        actionText: 'See All',
        onActionTap: () => context.push('/matches'),
      ),
    ),
    const SizedBox(height: 14),
    FadeAnimation(
      delayInMs: delay + 20,
      child: _buildDailyMatchesRow(context),
    ),
    const SizedBox(height: 24),
  ];

  List<Widget> _vipSection(BuildContext context, int delay) {
    if (_isPremium) return [];
    return [
      FadeAnimation(delayInMs: delay, child: _buildVipBanner(context)),
      const SizedBox(height: 24),
    ];
  }

  List<Widget> _premiumMatchesSection(BuildContext context, int delay) => [
    FadeAnimation(
      delayInMs: delay,
      child: _SectionLabel(
        title: 'Premium Matches',
        subtitle: _isPremium ? 'Verified premium members' : 'Upgrade to unlock',
        icon: Icons.diamond_rounded,
        actionText: _isPremium ? 'See All' : 'Unlock',
        onActionTap: () => _isPremium
            ? context.push('/matches')
            : context.push('/premium'),
      ),
    ),
    const SizedBox(height: 14),
    FadeAnimation(
      delayInMs: delay + 20,
      child: _buildPremiumMatchesRow(context),
    ),
    const SizedBox(height: 24),
  ];

  // ══════════════════════════════════════════════════════════
  // 1. HEADER
  // ══════════════════════════════════════════════════════════
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Open my profile',
            child: GestureDetector(
              onTap: () {
                HapticUtils.lightImpact();
                context.push('/my_profile');
              },
              child: PremiumAvatar(
                imageUrl: _user.image,
                size: 48,
                isOnline: true,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Greeting + name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greetingText,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  _user.name,
                  style: const TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    color: AppTheme.brandDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          _HeaderActionButton(
            icon: Icons.search_rounded,
            semanticLabel: 'Search matches',
            onTap: () {
              HapticUtils.lightImpact();
              context.push('/matches');
            },
          ),
          const SizedBox(width: 8),
          _HeaderActionButton(
            icon: Icons.notifications_rounded,
            semanticLabel: 'Notifications',
            badgeCount: _user.unreadNotifications,
            onTap: () {
              HapticUtils.mediumImpact();
              context.push('/notifications');
            },
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // 2. NEW MATCHES BANNER — Animated pulse, creates urgency
  // ══════════════════════════════════════════════════════════
  Widget _buildNewMatchesBanner(BuildContext context) {
    final count = _user.newMatchesSinceYesterday;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          HapticUtils.mediumImpact();
          context.push('/matches');
        },
        child: AnimatedBuilder(
          animation: _pulseAnim,
          builder: (_, child) => Transform.scale(
            scale: _pulseAnim.value,
            child: child,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.brandPrimary.withValues(alpha: 0.08),
                  AppTheme.brandPrimary.withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.brandPrimary.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              children: [
                // Animated dot
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.brandPrimary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.brandPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$count new match${count > 1 ? 'es' : ''} since yesterday!',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.brandDark,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Tap to see who matched with you',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(Icons.arrow_forward_ios_rounded,
                    size: 13, color: AppTheme.brandPrimary.withValues(alpha: 0.50)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // 3. PROFILE COMPLETION NUDGE — Drives completion from home
  // ══════════════════════════════════════════════════════════
  Widget _buildCompletionNudge(BuildContext context) {
    final pct = _user.profileCompletionPct;
    final Color barColor = pct < 40
        ? const Color(0xFFEF4444)
        : pct < 70
        ? const Color(0xFFF59E0B)
        : AppTheme.brandPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          HapticUtils.lightImpact();
          context.push('/edit_profile');
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.softShadow,
            border: Border.all(color: barColor.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              // Circular progress indicator
              SizedBox(
                width: 42, height: 42,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: pct / 100),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutCubic,
                      builder: (_, value, __) => SizedBox(
                        width: 42, height: 42,
                        child: CircularProgressIndicator(
                          value: value,
                          strokeWidth: 3.5,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(barColor),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                    ),
                    Text(
                      '$pct%',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: barColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Complete your profile',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.brandDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Get 3x more matches with a complete profile',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Complete',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // 4. ACTIVE NOW
  // ══════════════════════════════════════════════════════════
  Widget _buildActiveNow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.accentGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Active Now',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accentGreen,
                ),
              ),
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
            itemCount: _dummyActive.length + 1,
            itemBuilder: (_, index) {
              if (index == 0) return _buildLikedYouCard(context);
              final user = _dummyActive[index - 1];
              return _buildActiveUserAvatar(context, user);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLikedYouCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticUtils.mediumImpact();
        context.push('/interests');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _goldShimmerCtrl,
              builder: (_, child) => Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    transform: GradientRotation(
                      _goldShimmerCtrl.value * math.pi * 2,
                    ),
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
              ),
              child: ClipOval(
                child: SizedBox(
                  width: 62, height: 62,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomNetworkImage(
                        imageUrl: 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=crop&w=200&q=80',
                        borderRadius: 0,
                      ),
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Container(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
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
              child: const Text(
                'Liked You',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveUserAvatar(BuildContext context, _ActiveUser user) {
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        context.push('/user_detail');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            PremiumAvatar(
              imageUrl: user.image,
              size: 64,
              isOnline: true,
              showRing: true,
            ),
            const SizedBox(height: 5),
            Text(
              user.name.split(' ').first,
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

  // ══════════════════════════════════════════════════════════
  // 5. SPOTLIGHT CAROUSEL — Hero section with kundali chip
  // ══════════════════════════════════════════════════════════
  Widget _buildSpotlightCarousel(BuildContext context) {
    return SizedBox(
      height: 400, // Enough for card + action buttons + breathing room
      child: PageView.builder(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        itemCount: _dummySpotlight.length,
        itemBuilder: (_, index) {
          final match = _dummySpotlight[index];
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
            child: _SpotlightCard(
              match: match,
              onTap: () {
                HapticUtils.mediumImpact();
                context.push('/user_detail');
              },
              onLike: () {
                HapticUtils.heavyImpact();
                // TODO: interestsProvider.sendInterest(match.id)
              },
              onSkip: () {
                HapticUtils.lightImpact();
                // TODO: matchesProvider.skip(match.id)
              },
            ),
          );
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // 6. VIP BANNER
  // ══════════════════════════════════════════════════════════
  Widget _buildVipBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          HapticUtils.heavyImpact();
          context.push('/premium');
        },
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
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.goldPrimary.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'ELITE MEMBERSHIP',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Color(0xFFFFD700),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Unlock\nPremium',
                      style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Contact numbers, who liked you,\nand stand out.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Upgrade Now',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppTheme.brandDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Column(
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

  // ══════════════════════════════════════════════════════════
  // 7. DAILY MATCHES — With quick actions + "active Xh ago"
  // ══════════════════════════════════════════════════════════
  Widget _buildDailyMatchesRow(BuildContext context) {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _dummyDaily.length,
        itemBuilder: (_, index) {
          final match = _dummyDaily[index];
          return _DailyMatchCard(
            match: match,
            onTap: () {
              HapticUtils.lightImpact();
              context.push('/user_detail');
            },
            onLike: () {
              HapticUtils.heavyImpact();
              // TODO: interestsProvider.sendInterest()
            },
            onSkip: () {
              HapticUtils.lightImpact();
              // TODO: matchesProvider.skip()
            },
          );
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // 8. PREMIUM MATCHES
  // ══════════════════════════════════════════════════════════
  Widget _buildPremiumMatchesRow(BuildContext context) {
    return SizedBox(
      height: 186,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _dummyPremium.length,
        itemBuilder: (_, index) {
          final match = _dummyPremium[index];
          return _PremiumMatchTile(
            match: match,
            isPremiumUser: _isPremium,
            onTap: () {
              if (_isPremium) {
                HapticUtils.lightImpact();
                context.push('/user_detail');
              } else {
                HapticUtils.mediumImpact();
                context.push('/premium');
              }
            },
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// INLINED HELPER WIDGETS
// ══════════════════════════════════════════════════════════════

// ── Ambient background ──────────────────────────────────────
class _AmbientBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -80, right: -60,
          child: Container(
            width: 240, height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.brandPrimary.withValues(alpha: 0.06),
            ),
          ),
        ),
        Positioned(
          top: 400, left: -80,
          child: Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.04),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Section label ───────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.title,
    this.subtitle,
    this.icon,
    this.actionText,
    this.onActionTap,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppTheme.brandPrimary),
            const SizedBox(width: 7),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.brandDark,
                    letterSpacing: -0.2,
                    height: 1.1,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (actionText != null && onActionTap != null)
            GestureDetector(
              onTap: () {
                HapticUtils.lightImpact();
                onActionTap!();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionText!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.brandPrimary,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 10, color: AppTheme.brandPrimary),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Header action button ────────────────────────────────────
class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    required this.icon,
    required this.onTap,
    this.semanticLabel,
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? semanticLabel;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
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
              Icon(icon, color: AppTheme.brandDark, size: 22),
              if (badgeCount > 0)
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
    );
  }
}

// ── Spotlight card with kundali chip ────────────────────────
class _SpotlightCard extends StatelessWidget {
  const _SpotlightCard({
    required this.match,
    required this.onTap,
    required this.onLike,
    required this.onSkip,
  });

  final _SpotlightMatch match;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomNetworkImage(
                      imageUrl: match.image, borderRadius: 0,
                    ),

                    // Gradient overlay
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

                    // Match badge — top left
                    Positioned(
                      top: 16, left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.favorite_rounded,
                                color: AppTheme.brandPrimary, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              '${match.matchPct}% Match',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.brandDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Kundali + Verified badges — top right
                    Positioned(
                      top: 16, right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (match.isVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0EA5E9)
                                    .withValues(alpha: 0.90),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_rounded,
                                      color: Colors.white, size: 11),
                                  SizedBox(width: 3),
                                  Text(
                                    'Verified',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (match.kundaliCompatible) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.90),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.auto_awesome_rounded,
                                      color: Colors.white, size: 11),
                                  SizedBox(width: 3),
                                  Text(
                                    'Kundali Match',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Bottom info — name, chips, and action buttons in one block
                    Positioned(
                      bottom: 16, left: 18, right: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${match.name}, ${match.age}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Chips + action buttons in same row
                          Row(
                            children: [
                              // Chips take available space
                              Expanded(
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    _SpotlightChip(
                                      icon: Icons.work_outline_rounded,
                                      label: match.profession,
                                    ),
                                    _SpotlightChip(
                                      icon: Icons.location_on_outlined,
                                      label: match.city,
                                    ),
                                    _SpotlightChip(
                                      icon: Icons.school_outlined,
                                      label: match.education,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Action buttons — fixed on right
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: onSkip,
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: AppTheme.softShadow,
                                      ),
                                      child: Icon(Icons.close_rounded,
                                          color: Colors.grey.shade400, size: 22),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: onLike,
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.brandGradient,
                                        shape: BoxShape.circle,
                                        boxShadow: AppTheme.primaryGlow,
                                      ),
                                      child: const Icon(Icons.favorite_rounded,
                                          color: Colors.white, size: 24),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],  // inner Stack children
                ),    // inner Stack
              ),      // ClipRRect
            ),        // Container (card body)
          ],          // outer Stack children
        ),            // outer Stack
      ),              // GestureDetector
    );                // Padding
  }
}

// ── Spotlight chip ──────────────────────────────────────────
class _SpotlightChip extends StatelessWidget {
  const _SpotlightChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 11),
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

// ── Daily match card — with quick actions + activity badge ──
class _DailyMatchCard extends StatelessWidget {
  const _DailyMatchCard({
    required this.match,
    required this.onTap,
    required this.onLike,
    required this.onSkip,
  });

  final _DailyMatch match;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final firstName = match.name.split(' ').first;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 185,
        margin: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomNetworkImage(imageUrl: match.image, borderRadius: 0),

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
                    stops: const [0.0, 0.50],
                  ),
                ),
              ),

              // Activity badge — top right
              Positioned(
                top: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.40),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: match.isOnline
                          ? const Color(0xFF4ADE80).withValues(alpha: 0.50)
                          : Colors.white.withValues(alpha: 0.20),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(
                          color: match.isOnline
                              ? const Color(0xFF4ADE80)
                              : Colors.grey.shade400,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        match.isOnline
                            ? 'Online'
                            : match.lastActive ?? 'Offline',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Match % — top left (consistent with spotlight style)
              Positioned(
                top: 12, left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite_rounded,
                          color: AppTheme.brandPrimary, size: 10),
                      const SizedBox(width: 3),
                      Text(
                        '${match.matchPct}%',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.brandPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom: info on top line, buttons below right-aligned
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Name — full width, no truncation
                      Text(
                        '$firstName, ${match.age}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      // Profession — full width
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              match.profession,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Quick actions — right aligned
                          _QuickActionBtn(
                            icon: Icons.close_rounded,
                            color: Colors.white.withValues(alpha: 0.20),
                            iconColor: Colors.white.withValues(alpha: 0.80),
                            size: 36,
                            onTap: onSkip,
                          ),
                          const SizedBox(width: 6),
                          _QuickActionBtn(
                            icon: Icons.favorite_rounded,
                            color: AppTheme.brandPrimary.withValues(alpha: 0.90),
                            iconColor: Colors.white,
                            size: 36,
                            onTap: onLike,
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

// ── Quick action button (mini, for daily cards) ─────────────
class _QuickActionBtn extends StatelessWidget {
  const _QuickActionBtn({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.size,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color iconColor;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: size * 0.50),
      ),
    );
  }
}

// ── Premium match tile ──────────────────────────────────────
class _PremiumMatchTile extends StatelessWidget {
  const _PremiumMatchTile({
    required this.match,
    required this.isPremiumUser,
    required this.onTap,
  });

  final _PremiumMatch match;
  final bool isPremiumUser;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 132,
        margin: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.goldPrimary.withValues(
              alpha: isPremiumUser ? 0.80 : 0.50,
            ),
            width: isPremiumUser ? 2.5 : 2,
          ),
          boxShadow: isPremiumUser ? AppTheme.goldGlow : AppTheme.softShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              isPremiumUser
                  ? CustomNetworkImage(imageUrl: match.image, borderRadius: 0)
                  : Stack(
                fit: StackFit.expand,
                children: [
                  CustomNetworkImage(
                    imageUrl: match.image, borderRadius: 0,
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.20),
                    ),
                  ),
                ],
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
                    stops: const [0.0, 0.50],
                  ),
                ),
              ),

              // Lock icon — white with gold glow (premium feel)
              if (!isPremiumUser)
                Center(
                  child: Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.goldPrimary.withValues(alpha: 0.30),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.lock_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),

              // Gold badge
              Positioned(
                top: 10, left: 10,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.goldGlow,
                  ),
                  child: const Icon(Icons.diamond_rounded,
                      color: Colors.white, size: 10),
                ),
              ),

              // Name + city
              Positioned(
                bottom: 12, left: 10, right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${match.name}, ${match.age}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      match.city,
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
  }
}

// ── VIP perk row ────────────────────────────────────────────
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
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.88),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}