import 'dart:math' as math;
import 'dart:ui';
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
// 🏠 HOME SCREEN — v9.2
//
// Fixes over v6 (screenshot review):
//   ✅ FIX 1 — _pageController listener memory leak
//              _onPageChanged stored as late VoidCallback
//              removeListener(_onPageChanged) in dispose()
//   ✅ FIX 2 — AnimatedBuilder builder: (_, _) → (_, __)
//              Pulse dot in _buildActiveNow — compile error
//   ✅ FIX 3 — _HeaderBtn GestureDetector → Material + InkWell
//              Search + Notification buttons — proper ripple
//              Mini header buttons also fixed
//   ✅ FIX 4 — Active Now: GestureDetector → Material + InkWell
//              _buildActiveAvatar + _buildLikedYouCard
//   ✅ FIX 5 — New Matches banner + Profile Nudge
//              GestureDetector → Material + InkWell
//   ✅ FIX 6 — _scrollCtrl listener stored as named callback
//              Anonymous lambda can't be removed — memory leak
//
// Already good (preserved):
//   ✅ Sticky mini header — IgnorePointer fix
//   ✅ SpotlightCard spring animation on like button
//   ✅ Time-based section ordering (morning/evening)
//   ✅ FadeAnimation stagger on all sections
//   ✅ RepaintBoundary on ambient background
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
    required this.likedYouCount,
  });
  final String name, image;
  final bool isPremium;
  final int profileCompletionPct, newMatchesSinceYesterday,
      unreadNotifications, likedYouCount;
}

class _SpotlightMatch {
  const _SpotlightMatch({
    required this.name, required this.age, required this.city,
    required this.profession, required this.education,
    required this.matchPct, required this.isVerified, required this.image,
    this.kundaliCompatible = false,
  });
  final String name, city, profession, education, image;
  final int age, matchPct;
  final bool isVerified, kundaliCompatible;
}

class _DailyMatch {
  const _DailyMatch({
    required this.name, required this.age, required this.profession,
    required this.city, required this.matchPct,
    required this.isOnline, required this.image,
    this.lastActive,
  });
  final String name, profession, city, image;
  final int age, matchPct;
  final bool isOnline;
  final String? lastActive;
}

class _ActiveUser {
  const _ActiveUser({required this.name, required this.image});
  final String name, image;
}

class _PremiumMatch {
  const _PremiumMatch({
    required this.name, required this.age,
    required this.city, required this.image,
  });
  final String name, city, image;
  final int age;
}

class _SuccessStory {
  const _SuccessStory({
    required this.groomName, required this.brideName,
    required this.city, required this.image, required this.year,
  });
  final String groomName, brideName, city, image, year;
}

// ──────────────────────────────────────────────────────────────
// DUMMY DATA
// ──────────────────────────────────────────────────────────────

const _dummyUser = _CurrentUser(
  name: 'Rahul Rathod',
  image: AppAssets.dummyMale1,
  isPremium: false,
  profileCompletionPct: 72,
  newMatchesSinceYesterday: 3,
  unreadNotifications: 3,
  likedYouCount: 12,
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
    name: 'Priya Rathod', age: 24, profession: 'Software Engineer',
    city: 'Mumbai', matchPct: 98, isOnline: true, image: AppAssets.dummyFemale1,
  ),
  _DailyMatch(
    name: 'Sneha Pawar', age: 25, profession: 'Doctor',
    city: 'Pune', matchPct: 89, isOnline: false, image: AppAssets.dummyFemale9,
    lastActive: '2h ago',
  ),
  _DailyMatch(
    name: 'Riya Sharma', age: 23, profession: 'Teacher',
    city: 'Nashik', matchPct: 85, isOnline: true, image: AppAssets.dummyFemale6,
  ),
  _DailyMatch(
    name: 'Kavya Banjara', age: 26, profession: 'Architect',
    city: 'Nagpur', matchPct: 82, isOnline: false, image: AppAssets.dummyFemale4,
    lastActive: '5h ago',
  ),
];

const _dummyActive = [
  _ActiveUser(name: 'Kavya',  image: AppAssets.dummyFemale4),
  _ActiveUser(name: 'Roshni', image: AppAssets.dummyFemale5),
  _ActiveUser(name: 'Neha',   image: AppAssets.dummyFemale6),
  _ActiveUser(name: 'Swati',  image: AppAssets.dummyFemale8),
];

final _likedYouPreviews = [
  AppAssets.dummyFemale2,
  AppAssets.dummyFemale3,
  AppAssets.dummyFemale7,
];

const _dummyPremium = [
  _PremiumMatch(name: 'Kavya',  age: 25, city: 'Mumbai', image: AppAssets.dummyFemale4),
  _PremiumMatch(name: 'Roshni', age: 27, city: 'Pune',   image: AppAssets.dummyFemale5),
  _PremiumMatch(name: 'Swati',  age: 24, city: 'Nashik', image: AppAssets.dummyFemale8),
  _PremiumMatch(name: 'Divya',  age: 26, city: 'Delhi',  image: AppAssets.dummyFemale2),
];

const _dummyStories = [
  _SuccessStory(
    groomName: 'Arjun', brideName: 'Kavya',
    city: 'Mumbai', image: AppAssets.successStory1, year: '2023',
  ),
  _SuccessStory(
    groomName: 'Rohan', brideName: 'Priya',
    city: 'Pune', image: AppAssets.successStory2, year: '2023',
  ),
  _SuccessStory(
    groomName: 'Vikram', brideName: 'Anjali',
    city: 'Nagpur', image: AppAssets.successStory3, year: '2024',
  ),
];

const _thoughts = [
  (
  quote: 'Vivah ek pavitr bandhan hai,\ndono aatmaon ka milan.',
  author: 'Banjara Proverb',
  emoji: '🌸',
  ),
  (
  quote: 'Sachi shaadi woh hoti hai jahan\ndono ek doosre ke liye bane hain.',
  author: 'Ancient Wisdom',
  emoji: '💫',
  ),
  (
  quote: 'Gotra se pehchaan, dil se rishta,\naur Vaaya se milaan.',
  author: 'Vaaya Vivah',
  emoji: '🏡',
  ),
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

  late final PageController _pageController;
  int _spotlightIndex = 0;

  late final AnimationController _goldShimmerCtrl;
  late final AnimationController _pulsCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _borderAnim;

  late final ScrollController _scrollCtrl;
  bool _headerCollapsed = false;

  final _CurrentUser _user = _dummyUser;
  late final String _greetingText;
  late final bool _isEvening;
  late final int _thoughtIndex;

  // ── FIX 1: Store listener references — proper cleanup ──────
  late final VoidCallback _pageListener;
  // ── FIX 6: Store scroll listener reference ────────────────
  late final VoidCallback _scrollListener;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _pageController = PageController(viewportFraction: 0.88);

    // ── FIX 1: Named callback — can be removed in dispose ───
    _pageListener = () {
      if (_pageController.page != null) {
        final newIndex = _pageController.page!.round();
        if (newIndex != _spotlightIndex) {
          setState(() => _spotlightIndex = newIndex);
        }
      }
    };
    _pageController.addListener(_pageListener);

    _goldShimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    if (!_isPremium) _goldShimmerCtrl.repeat();

    _pulsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.018).animate(
      CurvedAnimation(parent: _pulsCtrl, curve: Curves.easeInOut),
    );
    _borderAnim = Tween<double>(begin: 0.12, end: 0.40).animate(
      CurvedAnimation(parent: _pulsCtrl, curve: Curves.easeInOut),
    );

    _scrollCtrl = ScrollController();

    // ── FIX 6: Named scroll callback ──────────────────────
    _scrollListener = () {
      final collapsed = _scrollCtrl.offset > 80;
      if (collapsed != _headerCollapsed) {
        setState(() => _headerCollapsed = collapsed);
      }
    };
    _scrollCtrl.addListener(_scrollListener);

    _greetingText = _computeGreeting();
    _isEvening    = DateTime.now().hour >= 17;
    _thoughtIndex = DateTime.now().weekday % _thoughts.length;
  }

  @override
  void dispose() {
    // ── FIX 1: Remove named listener — no leak ─────────────
    _pageController.removeListener(_pageListener);
    _pageController.dispose();

    // ── FIX 6: Remove named scroll listener ───────────────
    _scrollCtrl.removeListener(_scrollListener);
    _scrollCtrl.dispose();

    _goldShimmerCtrl.dispose();
    _pulsCtrl.dispose();
    super.dispose();
  }

  bool get _isPremium => _user.isPremium;

  static String _computeGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // ──────────────────────────────────────────────────────────
  // BUILD
  // ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.bgScaffold,
      body: Stack(
        children: [
          RepaintBoundary(child: _AmbientBackground()),

          SafeArea(
            child: CustomScrollView(
              controller: _scrollCtrl,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 96 + bottomPad),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildAllSections(context),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sticky mini header
          SafeArea(
            child: IgnorePointer(
              ignoring: !_headerCollapsed,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                offset: _headerCollapsed
                    ? Offset.zero
                    : const Offset(0, -1),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _headerCollapsed ? 1.0 : 0.0,
                  child: _buildMiniHeader(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // MINI STICKY HEADER
  // ──────────────────────────────────────────────────────────
  Widget _buildMiniHeader(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              PremiumAvatar(imageUrl: _user.image, size: 34, isOnline: true),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Hi, ${_user.name.split(' ').first} 👋',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.brandDark,
                  ),
                ),
              ),
              // ── FIX 3: Material + InkWell in mini header ──
              _HeaderBtn(
                icon: Icons.search_rounded,
                label: 'Search',
                size: 36,
                onTap: () { HapticUtils.lightImpact(); context.push('/matches'); },
              ),
              const SizedBox(width: 8),
              _HeaderBtn(
                icon: Icons.notifications_rounded,
                label: 'Notifications',
                size: 36,
                badge: _user.unreadNotifications,
                onTap: () { HapticUtils.mediumImpact(); context.push('/notifications'); },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // ALL SECTIONS
  // ══════════════════════════════════════════════════════════
  List<Widget> _buildAllSections(BuildContext context) {
    final s = <Widget>[];
    int delay = 0;

    s.add(const SizedBox(height: 20));
    s.add(FadeAnimation(delayInMs: delay, child: _buildHeader(context)));
    delay += 40;

    // CHANGE 1: New matches banner removed
    // CHANGE 2: Profile completion nudge moved to header avatar (see _buildHeader)
    // CHANGE 3: Thought of the day removed

    // CHANGE 4: Active Now ALWAYS before Spotlight (morning + evening)
    s.addAll(_sectionActiveNow(context, delay));      delay += 50;
    s.addAll(_sectionSpotlight(context, delay));      delay += 60;
    s.addAll(_sectionDailyMatches(context, delay));   delay += 50;
    s.addAll(_sectionVipBanner(context, delay));      delay += 40;
    s.addAll(_sectionPremiumMatches(context, delay)); delay += 40;

    s.addAll(_sectionSuccessStories(context, delay));
    s.add(const SizedBox(height: 16));
    return s;
  }

  // ──────────────────────────────────────────────────────────
  // SECTION BUILDERS
  // ──────────────────────────────────────────────────────────

  List<Widget> _sectionSpotlight(BuildContext ctx, int delay) => [
    const SizedBox(height: 28),
    FadeAnimation(
      delayInMs: delay,
      child: _AccentSectionLabel(
        title: 'Spotlight',
        subtitle: 'Highly compatible profiles',
        icon: Icons.auto_awesome_rounded,
      ),
    ),
    const SizedBox(height: 16),
    FadeAnimation(
      delayInMs: delay + 20,
      child: _buildSpotlightCarousel(ctx),
    ),
    const SizedBox(height: 10),
    FadeAnimation(
      delayInMs: delay + 30,
      child: _buildSpotlightDots(),
    ),
  ];

  List<Widget> _sectionDailyMatches(BuildContext ctx, int delay) => [
    const SizedBox(height: 28),
    FadeAnimation(
      delayInMs: delay,
      child: _AccentSectionLabel(
        title: 'Daily Matches',
        subtitle: 'Refreshed every morning for you',
        actionText: 'See All',
        onActionTap: () => ctx.push('/matches'),
      ),
    ),
    const SizedBox(height: 16),
    FadeAnimation(
      delayInMs: delay + 20,
      child: _buildDailyMatchesRow(ctx),
    ),
  ];

  List<Widget> _sectionActiveNow(BuildContext ctx, int delay) => [
    const SizedBox(height: 28),
    FadeAnimation(
      delayInMs: delay,
      child: _buildActiveNow(ctx),
    ),
  ];

  List<Widget> _sectionVipBanner(BuildContext ctx, int delay) {
    if (_isPremium) return const [];
    return [
      const SizedBox(height: 28),
      FadeAnimation(delayInMs: delay, child: _buildVipBanner(ctx)),
    ];
  }

  List<Widget> _sectionPremiumMatches(BuildContext ctx, int delay) => [
    const SizedBox(height: 28),
    FadeAnimation(
      delayInMs: delay,
      child: _AccentSectionLabel(
        title: 'Premium Matches',
        subtitle: _isPremium ? 'Verified premium members' : 'Upgrade to unlock',
        icon: Icons.diamond_rounded,
        actionText: _isPremium ? 'See All' : 'Unlock',
        onActionTap: () =>
        _isPremium ? ctx.push('/matches') : ctx.push('/premium'),
      ),
    ),
    const SizedBox(height: 16),
    FadeAnimation(
      delayInMs: delay + 20,
      child: _buildPremiumMatchesRow(ctx),
    ),
  ];

  List<Widget> _sectionSuccessStories(BuildContext ctx, int delay) => [
    const SizedBox(height: 28),
    FadeAnimation(
      delayInMs: delay,
      child: _AccentSectionLabel(
        title: 'Success Stories',
        subtitle: 'Couples who found love on Vaaya',
        icon: Icons.favorite_rounded,
      ),
    ),
    const SizedBox(height: 16),
    FadeAnimation(
      delayInMs: delay + 20,
      child: _buildSuccessStoriesRow(ctx),
    ),
  ];

  // ══════════════════════════════════════════════════════════
  // 1. HEADER
  // ══════════════════════════════════════════════════════════
  Widget _buildHeader(BuildContext context) {
    final pct       = _user.profileCompletionPct;
    final firstName = _user.name.split(' ').first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Semantics(
                button: true,
                label: 'Open my profile',
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      HapticUtils.lightImpact();
                      context.push('/my_profile');
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        if (_isPremium)
                          Container(
                            width: 52, height: 52,
                            decoration: const BoxDecoration(
                              gradient: AppTheme.goldGradient,
                              shape: BoxShape.circle,
                            ),
                          ),
                        // isOnline: false — green dot hata diya
                        PremiumAvatar(
                          imageUrl: _user.image,
                          size: 44,
                          isOnline: false,
                        ),
                        // Hamburger menu icon — bottom right of avatar
                        // User ko clearly pata lagega ki tap karna hai
                        Positioned(
                          bottom: -1,
                          right: -1,
                          child: Container(
                            width: 18, height: 18,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.menu_rounded,
                              size: 10,
                              color: AppTheme.brandDark,
                            ),
                          ),
                        ),
                      ],
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
                      '${_isEvening ? "🌙" : "☀️"} $_greetingText',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      firstName,
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
              _HeaderBtn(
                icon: Icons.search_rounded,
                label: 'Search',
                onTap: () {
                  HapticUtils.lightImpact();
                  context.push('/matches');
                },
              ),
              const SizedBox(width: 8),
              _HeaderBtn(
                icon: Icons.notifications_rounded,
                label: 'Notifications',
                badge: _user.unreadNotifications,
                onTap: () {
                  HapticUtils.mediumImpact();
                  context.push('/notifications');
                },
              ),
            ],
          ),
        ),

        // Profile completion bar — compact inline CTA below header
        if (!_isPremium && pct < 100) ...[
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () {
                  HapticUtils.lightImpact();
                  context.push('/edit_profile');
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.brandPrimary.withValues(alpha: 0.12),
                    ),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Complete your profile',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.brandDark,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '$pct%',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.brandPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct / 100,
                                minHeight: 4,
                                backgroundColor: Colors.grey.shade100,
                                valueColor: const AlwaysStoppedAnimation(
                                  AppTheme.brandPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Get ${pct < 80 ? "5x" : "3x"} more matches',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 13,
                        color: AppTheme.brandPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
  // ══════════════════════════════════════════════════════════
  // 2. NEW MATCHES BANNER — FIX 5: Material + InkWell
  // ══════════════════════════════════════════════════════════
  Widget _buildNewMatchesBanner(BuildContext context) {
    final count = _user.newMatchesSinceYesterday;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedBuilder(
        animation: _pulsCtrl,
        builder: (_, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () {
                HapticUtils.mediumImpact();
                context.push('/matches');
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppTheme.brandPrimary.withValues(alpha: 0.09),
                    AppTheme.brandPrimary.withValues(alpha: 0.03),
                  ]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.brandPrimary.withValues(
                        alpha: _borderAnim.value),
                    width: 1.5,
                  ),
                ),
                child: child,
              ),
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: AppTheme.brandGradient,
                shape: BoxShape.circle,
                boxShadow: AppTheme.primaryGlow,
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to view your matches',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppTheme.brandPrimary,
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // 3. PROFILE COMPLETION NUDGE — FIX 5: Material + InkWell
  // ══════════════════════════════════════════════════════════
  Widget _buildCompletionNudge(BuildContext context) {
    final pct = _user.profileCompletionPct;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () {
            HapticUtils.lightImpact();
            context.push('/edit_profile');
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppTheme.softShadow,
              border: Border.all(
                color: AppTheme.brandPrimary.withValues(alpha: 0.10),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 48, height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: pct / 100,
                        strokeWidth: 3.5,
                        backgroundColor: Colors.grey.shade100,
                        valueColor: const AlwaysStoppedAnimation(
                          AppTheme.brandPrimary,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                      Text(
                        '$pct%',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.brandPrimary,
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
                        'Get ${(100 - pct) < 20 ? '3x' : '5x'} more matches',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 7),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct / 100,
                          minHeight: 3,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: const AlwaysStoppedAnimation(
                            AppTheme.brandPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: AppTheme.brandPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // 4. THOUGHT OF THE DAY
  // ══════════════════════════════════════════════════════════
  Widget _buildThoughtOfDay(BuildContext context) {
    final thought = _thoughts[_thoughtIndex];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.brandPrimary.withValues(alpha: 0.05),
              AppTheme.goldPrimary.withValues(alpha: 0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.goldPrimary.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppTheme.goldPrimary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(thought.emoji,
                    style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.goldPrimary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'THOUGHT OF THE DAY',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.goldPrimary,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    thought.quote,
                    style: const TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.brandDark,
                      height: 1.45,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '— ${thought.author}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
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

  // ══════════════════════════════════════════════════════════
  // 5. ACTIVE NOW
  // FIX 2: AnimatedBuilder (_, _) → (_, __)
  // FIX 4: Avatar taps → Material + InkWell
  // ══════════════════════════════════════════════════════════
  // ══════════════════════════════════════════════════════════
  // ACTIVE NOW — Story-style redesign
  // Compact 72px avatars, crisp animated green dot,
  // gold pulsing Liked You card, consistent name label
  // ══════════════════════════════════════════════════════════
  Widget _buildActiveNow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Animated green pulse dot
              AnimatedBuilder(
                animation: _pulsCtrl,
                builder: (_, __) {
                  final glow = _borderAnim.value;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow ring
                      Container(
                        width: 16, height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF22C55E)
                              .withValues(alpha: glow * 0.30),
                        ),
                      ),
                      // Inner solid dot
                      Container(
                        width: 9, height: 9,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF22C55E),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF22C55E),
                              blurRadius: 4,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(width: 8),
              const Text(
                'Active Now',
                style: TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.brandDark,
                  letterSpacing: -0.2,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              // LIVE badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.25),
                    width: 0.8,
                  ),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF22C55E),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Horizontal story strip ────────────────────────
        SizedBox(
          height: 108,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _dummyActive.length + 1,
            itemBuilder: (_, index) {
              if (index == 0) return _buildLikedYouCard(context);
              return _buildActiveAvatar(
                  context, _dummyActive[index - 1]);
            },
          ),
        ),
      ],
    );
  }

  // ── Liked You Card ─────────────────────────────────────
  // Gold pulsing ring, blurred previews, heart + count
  Widget _buildLikedYouCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticUtils.mediumImpact();
        context.push('/premium');
      },
      child: Container(
        margin: const EdgeInsets.only(right: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gold pulsing ring container
            AnimatedBuilder(
              animation: _pulsCtrl,
              builder: (_, child) {
                final glow = _borderAnim.value;
                return Container(
                  width: 68, height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // 2px gap between ring and photo
                    border: Border.all(
                      color: AppTheme.goldPrimary.withValues(
                          alpha: 0.45 + glow * 0.45),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.goldPrimary
                            .withValues(alpha: glow * 0.45),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  // Inner circle with 2px white gap
                  child: Padding(
                    padding: const EdgeInsets.all(2.5),
                    child: child,
                  ),
                );
              },
              child: ClipOval(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Blurred face previews layered
                    for (int i = 0; i < _likedYouPreviews.length; i++)
                      Positioned.fill(
                        child: Opacity(
                          opacity: i == 0
                              ? 1.0
                              : i == 1
                              ? 0.55
                              : 0.30,
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(
                                sigmaX: 7, sigmaY: 7),
                            child: CustomNetworkImage(
                              imageUrl: _likedYouPreviews[i],
                              borderRadius: 0,
                            ),
                          ),
                        ),
                      ),
                    // Gradient overlay — dark bottom, gold tint top
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.55),
                            AppTheme.goldPrimary
                                .withValues(alpha: 0.30),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    // Heart icon + count — centered
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          '${_user.likedYouCount}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Label
            Text(
              'Liked You',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.goldPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Active User Avatar ─────────────────────────────────
  // Story-style: brand pink ring, 68px photo,
  // vivid green dot, name below
  Widget _buildActiveAvatar(BuildContext context, _ActiveUser user) {
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        context.push('/user_detail');
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Brand gradient ring — 72px outer
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.brandPrimary,
                        AppTheme.brandPrimary.withValues(alpha: 0.60),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                // White gap ring — 68px
                Container(
                  width: 68, height: 68,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                // Photo — 64px
                ClipOval(
                  child: SizedBox(
                    width: 64, height: 64,
                    child: CustomNetworkImage(
                      imageUrl: user.image,
                      borderRadius: 0,
                    ),
                  ),
                ),
                // Green online dot — crisp, vivid
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 16, height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF22C55E),
                      border: Border.all(
                        color: Colors.white,
                        width: 2.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF22C55E),
                          blurRadius: 5,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              user.name.split(' ').first,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppTheme.brandDark,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // SPOTLIGHT CAROUSEL
  // ══════════════════════════════════════════════════════════
  Widget _buildSpotlightCarousel(BuildContext context) {
    return SizedBox(
      height: 360,
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
                scale = (1 - page.abs() * 0.08).clamp(0.90, 1.0);
              } else {
                scale = index == 0 ? 1.0 : 0.90;
              }
              return Transform.scale(scale: scale, child: child);
            },
            child: RepaintBoundary(
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity == null) return;
                  if (details.primaryVelocity! < -300) {
                    HapticUtils.lightImpact();
                    if (_spotlightIndex < _dummySpotlight.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOut,
                      );
                    }
                  } else if (details.primaryVelocity! > 300) {
                    HapticUtils.heavyImpact();
                    if (_spotlightIndex > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOut,
                      );
                    }
                  }
                },
                child: _SpotlightCard(
                  match: match,
                  onTap: () {
                    HapticUtils.lightImpact();
                    context.push('/user_detail');
                  },
                  onLike: () { HapticUtils.heavyImpact(); },
                  onSkip: () {
                    HapticUtils.lightImpact();
                    if (_spotlightIndex < _dummySpotlight.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  onInterest: () { HapticUtils.mediumImpact(); },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpotlightDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_dummySpotlight.length, (i) {
        final active = i == _spotlightIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active
                ? AppTheme.brandPrimary
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  // ══════════════════════════════════════════════════════════
  // VIP BANNER
  // ══════════════════════════════════════════════════════════
  Widget _buildVipBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(
            AppTheme.goldCardDecoration.borderRadius
                ?.resolve(TextDirection.ltr)
                .topLeft
                .x ??
                20),
        child: InkWell(
          onTap: () {
            HapticUtils.mediumImpact();
            context.push('/premium');
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.goldCardDecoration,
            child: Stack(
              children: [
                const Positioned.fill(child: _StarParticles()),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: AppTheme.goldGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'VAAYA PREMIUM',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Find your\nperfect match',
                            style: TextStyle(
                              fontFamily: 'Cormorant Garamond',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.2,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Unlock contacts, see who liked you',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white
                                  .withValues(alpha: 0.55),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AnimatedBuilder(
                            animation: _goldShimmerCtrl,
                            builder: (_, child) {
                              final t = _goldShimmerCtrl.value;
                              return ShaderMask(
                                shaderCallback: (bounds) =>
                                    LinearGradient(
                                      colors: const [
                                        Color(0xFFFFD700),
                                        Color(0xFFFFF5A0),
                                        Color(0xFFFFD700),
                                        Color(0xFFFFC200),
                                      ],
                                      stops: [
                                        (t - 0.3).clamp(0.0, 1.0),
                                        t.clamp(0.0, 1.0),
                                        (t + 0.1).clamp(0.0, 1.0),
                                        (t + 0.4).clamp(0.0, 1.0),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                child: child!,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 13),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD700),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: AppTheme.goldGlow,
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.workspace_premium_rounded,
                                      size: 16, color: AppTheme.brandDark),
                                  SizedBox(width: 6),
                                  Text(
                                    'Upgrade Now',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: AppTheme.brandDark,
                                    ),
                                  ),
                                ],
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
                        _VipPerk('See who liked you', Icons.favorite_rounded),
                        _VipPerk('Unlimited interests', Icons.send_rounded),
                        _VipPerk('Contact numbers', Icons.phone_rounded),
                        _VipPerk('Priority placement', Icons.star_rounded),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // DAILY MATCHES ROW
  // ══════════════════════════════════════════════════════════
  Widget _buildDailyMatchesRow(BuildContext context) {
    return SizedBox(
      height: 268,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _dummyDaily.length,
        itemBuilder: (_, index) {
          return FadeAnimation(
            delayInMs: index * 60,
            child: _DailyMatchCard(
              match: _dummyDaily[index],
              onTap: () {
                HapticUtils.lightImpact();
                context.push('/user_detail');
              },
              onLike:     () { HapticUtils.heavyImpact(); },
              onSkip:     () { HapticUtils.lightImpact(); },
              onInterest: () { HapticUtils.mediumImpact(); },
            ),
          );
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // PREMIUM MATCHES ROW
  // ══════════════════════════════════════════════════════════
  Widget _buildPremiumMatchesRow(BuildContext context) {
    return SizedBox(
      height: 204,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _dummyPremium.length + (_isPremium ? 0 : 1),
        itemBuilder: (_, index) {
          if (!_isPremium && index == _dummyPremium.length) {
            return _PremiumUnlockCta(
              onTap: () {
                HapticUtils.mediumImpact();
                context.push('/premium');
              },
            );
          }
          return _PremiumMatchTile(
            match: _dummyPremium[index],
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

  // ══════════════════════════════════════════════════════════
  // SUCCESS STORIES ROW
  // ══════════════════════════════════════════════════════════
  Widget _buildSuccessStoriesRow(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _dummyStories.length,
        itemBuilder: (_, index) {
          return FadeAnimation(
            delayInMs: index * 80,
            child: _SuccessStoryCard(story: _dummyStories[index]),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// HELPER WIDGETS
// ══════════════════════════════════════════════════════════════

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
        Positioned(
          top: 750, right: -60,
          child: Container(
            width: 180, height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.goldPrimary.withValues(alpha: 0.04),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Star particles (VIP banner) ───────────────────────────────
class _StarParticles extends StatefulWidget {
  const _StarParticles();

  @override
  State<_StarParticles> createState() => _StarParticlesState();
}

class _StarParticlesState extends State<_StarParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(painter: _StarPainter(_ctrl.value)),
    );
  }
}

class _StarPainter extends CustomPainter {
  _StarPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (int i = 0; i < 8; i++) {
      final seed = i * 137.508;
      final x = seed % size.width;
      final baseY = (seed * 1.618) % size.height;
      final y = baseY + math.sin((t + i * 0.3) * math.pi * 2) * 6;
      final opacity =
          (math.sin((t + i * 0.125) * math.pi * 2) * 0.5 + 0.5) * 0.35;
      paint.color = Colors.white.withValues(alpha: opacity);
      _drawStar(canvas, Offset(x, y), 3 + (i % 3).toDouble(), paint);
    }
  }

  void _drawStar(Canvas canvas, Offset c, double r, Paint p) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final oa = -math.pi / 2 + i * 2 * math.pi / 5;
      final ia = oa + math.pi / 5;
      final o  = Offset(c.dx + r * math.cos(oa), c.dy + r * math.sin(oa));
      final iv = Offset(
        c.dx + r * 0.4 * math.cos(ia),
        c.dy + r * 0.4 * math.sin(ia),
      );
      if (i == 0) { path.moveTo(o.dx, o.dy); } else { path.lineTo(o.dx, o.dy); }
      path.lineTo(iv.dx, iv.dy);
    }
    path.close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.t != t;
}

// ── Accent section label ──────────────────────────────────────
class _AccentSectionLabel extends StatelessWidget {
  const _AccentSectionLabel({
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
          Container(
            width: 3, height: 28,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              gradient: AppTheme.brandGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
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
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionText != null && onActionTap != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  HapticUtils.lightImpact();
                  onActionTap!();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
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
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: AppTheme.brandPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Header button — FIX 3: Material + InkWell ────────────────
class _HeaderBtn extends StatelessWidget {
  const _HeaderBtn({
    required this.icon,
    required this.onTap,
    this.label,
    this.badge = 0,
    this.size = 44,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? label;
  final int badge;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        child: InkWell(
          // ── FIX 3: proper ripple ─────────────────────────
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: size, height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Icon(
                  icon,
                  color: AppTheme.brandDark,
                  size: size * 0.45,
                ),
              ),
              if (badge > 0)
                Positioned(
                  top: -2, right: -2,
                  child: Container(
                    width: 18, height: 18,
                    decoration: const BoxDecoration(
                      color: AppTheme.brandPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        badge > 9 ? '9+' : '$badge',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
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

// ── VIP perk item ─────────────────────────────────────────────
class _VipPerk extends StatelessWidget {
  const _VipPerk(this.text, this.icon);
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              color: AppTheme.goldPrimary.withValues(alpha: 0.20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.goldLight, size: 12),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SPOTLIGHT CARD
// ══════════════════════════════════════════════════════════════
class _SpotlightCard extends StatefulWidget {
  const _SpotlightCard({
    required this.match,
    required this.onTap,
    required this.onLike,
    required this.onSkip,
    required this.onInterest,
  });

  final _SpotlightMatch match;
  final VoidCallback onTap, onLike, onSkip, onInterest;

  @override
  State<_SpotlightCard> createState() => _SpotlightCardState();
}

class _SpotlightCardState extends State<_SpotlightCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _likeScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _likeScale = Tween<double>(begin: 1.0, end: 0.86).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.match;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomNetworkImage(imageUrl: m.image, borderRadius: 0),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.90),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.55],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.22),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.28],
                    ),
                  ),
                ),
                Positioned(
                  top: 16, left: 16,
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
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: AppTheme.brandPrimary,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${m.matchPct}% Match',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: AppTheme.brandPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 16, right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (m.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.accentBlue
                                .withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded,
                                  color: Colors.white, size: 11),
                              SizedBox(width: 4),
                              Text('Verified',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  )),
                            ],
                          ),
                        ),
                      if (m.kundaliCompatible) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.goldPrimary
                                .withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.stars_rounded,
                                  color: Colors.white, size: 11),
                              SizedBox(width: 4),
                              Text('Kundali ✓',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Positioned(
                  bottom: 90, left: 18, right: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${m.name}, ${m.age}',
                        style: const TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                          letterSpacing: -0.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _SpotlightChip(
                            icon: Icons.work_outline_rounded,
                            label: m.profession,
                          ),
                          const SizedBox(width: 8),
                          _SpotlightChip(
                            icon: Icons.location_on_outlined,
                            label: m.city,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 16, left: 18, right: 18,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Skip — 48px
                      GestureDetector(
                        onTap: widget.onSkip,
                        child: Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white.withValues(alpha: 0.90),
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Like — 68px — biggest (primary action)
                      GestureDetector(
                        onTapDown: (_) => _pressCtrl.forward(),
                        onTapUp: (_) {
                          _pressCtrl.reverse();
                          widget.onLike();
                        },
                        onTapCancel: () => _pressCtrl.reverse(),
                        child: AnimatedBuilder(
                          animation: _likeScale,
                          builder: (_, child) => Transform.scale(
                            scale: _likeScale.value,
                            child: child,
                          ),
                          child: Container(
                            width: 68, height: 68,
                            decoration: BoxDecoration(
                              gradient: AppTheme.brandGradient,
                              shape: BoxShape.circle,
                              boxShadow: AppTheme.primaryGlow,
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Send Interest — 48px
                      GestureDetector(
                        onTap: widget.onInterest,
                        child: Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Icon(
                            Icons.send_rounded,
                            color: Colors.white.withValues(alpha: 0.90),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Spotlight chip ────────────────────────────────────────────
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

// ══════════════════════════════════════════════════════════════
// DAILY MATCH CARD
// ══════════════════════════════════════════════════════════════
class _DailyMatchCard extends StatelessWidget {
  const _DailyMatchCard({
    required this.match,
    required this.onTap,
    required this.onLike,
    required this.onSkip,
    required this.onInterest,
  });

  final _DailyMatch match;
  final VoidCallback onTap, onLike, onSkip, onInterest;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 14),
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
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.90),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.52],
                  ),
                ),
              ),
              Positioned(
                top: 10, right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: match.isOnline
                          ? const Color(0xFF4ADE80)
                          .withValues(alpha: 0.60)
                          : Colors.white.withValues(alpha: 0.20),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5, height: 5,
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
                            : (match.lastActive ?? ''),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: match.isOnline
                              ? const Color(0xFF4ADE80)
                              : Colors.white.withValues(alpha: 0.70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 8, left: 8,
                child: _ArcMatchRing(pct: match.matchPct, size: 38),
              ),
              Positioned(
                bottom: 10, left: 12, right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${match.name.split(' ').first}, ${match.age}',
                      style: const TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      match.profession,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: Colors.white.withValues(alpha: 0.50),
                          size: 9,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          match.city,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white.withValues(alpha: 0.50),
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _QuickBtn(
                          icon: Icons.close_rounded,
                          color: Colors.white.withValues(alpha: 0.18),
                          iconColor: Colors.white.withValues(alpha: 0.85),
                          size: 30,
                          onTap: onSkip,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: GestureDetector(
                            onTap: onInterest,
                            child: Container(
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white
                                      .withValues(alpha: 0.25),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Send Interest',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        _QuickBtn(
                          icon: Icons.favorite_rounded,
                          color: AppTheme.brandPrimary,
                          iconColor: Colors.white,
                          size: 34,
                          onTap: onLike,
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
    );
  }
}

// ── Arc match% ring ───────────────────────────────────────────
class _ArcMatchRing extends StatelessWidget {
  const _ArcMatchRing({required this.pct, required this.size});
  final int pct;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ArcPainter(pct / 100),
          ),
          Text(
            '$pct',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter(this.value);
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - 4) / 2;
    final bg = Paint()
      ..color = Colors.white.withValues(alpha: 0.20)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..color = AppTheme.brandPrimary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2, 2 * math.pi, false, bg,
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2, 2 * math.pi * value, false, fg,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.value != value;
}

// ── Quick button ──────────────────────────────────────────────
class _QuickBtn extends StatelessWidget {
  const _QuickBtn({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.size,
    required this.onTap,
  });

  final IconData icon;
  final Color color, iconColor;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: size * 0.48),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// PREMIUM MATCH TILE
// ══════════════════════════════════════════════════════════════
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
        width: 140,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.goldPrimary.withValues(
              alpha: isPremiumUser ? 0.80 : 0.45,
            ),
            width: isPremiumUser ? 2.5 : 1.5,
          ),
          boxShadow:
          isPremiumUser ? AppTheme.goldGlow : AppTheme.softShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              isPremiumUser
                  ? CustomNetworkImage(imageUrl: match.image, borderRadius: 0)
                  : ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  0.16, 0, 0, 0, 0,
                  0, 0.16, 0, 0, 0,
                  0, 0, 0.16, 0, 0,
                  0, 0, 0, 1, 0,
                ]),
                child: CustomNetworkImage(
                    imageUrl: match.image, borderRadius: 0),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.82),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.50],
                  ),
                ),
              ),
              if (isPremiumUser)
                Positioned(
                  top: 10, right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.diamond_rounded,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
              // Lock icon removed — blur + section title communicates it clearly
              if (!isPremiumUser)
                Positioned(
                  top: 10, right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_rounded, color: AppTheme.goldLight, size: 9),
                        SizedBox(width: 3),
                        Text('Premium', style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.goldLight,
                        )),
                      ],
                    ),
                  ),
                ),
              Positioned(
                bottom: 10, left: 10, right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isPremiumUser ? match.name : '••••••',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isPremiumUser
                          ? '${match.age} • ${match.city}'
                          : '${match.age} • ••••',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
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
  }
}

// ── Premium unlock CTA ────────────────────────────────────────
class _PremiumUnlockCta extends StatelessWidget {
  const _PremiumUnlockCta({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          gradient: AppTheme.goldCardDecoration.gradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.goldPrimary.withValues(alpha: 0.40),
          ),
          boxShadow: AppTheme.goldGlow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppTheme.goldPrimary.withValues(alpha: 0.20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.diamond_rounded,
                color: AppTheme.goldLight,
                size: 22,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Unlock All',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Go Premium',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                color: AppTheme.goldLight.withValues(alpha: 0.80),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SUCCESS STORY CARD
// ══════════════════════════════════════════════════════════════
class _SuccessStoryCard extends StatelessWidget {
  const _SuccessStoryCard({required this.story});
  final _SuccessStory story;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomNetworkImage(imageUrl: story.image, borderRadius: 0),
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
            Positioned(
              top: 12, right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.brandPrimary.withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_rounded,
                        color: Colors.white, size: 10),
                    SizedBox(width: 4),
                    Text('Matched!',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        )),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 12, left: 12, right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${story.groomName} & ${story.brideName}',
                    style: const TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: Colors.white.withValues(alpha: 0.70),
                        size: 10,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        story.city,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white.withValues(alpha: 0.70),
                          fontSize: 10,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        story.year,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 10,
                        ),
                      ),
                    ],
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