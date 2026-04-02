import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/custom_toast.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../shared/animations/fade_animation.dart';
import '../../../../shared/widgets/custom_network_image.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/guest_lock_widget.dart';
import '../../../../shared/widgets/match_badge.dart';
import '../../../../shared/widgets/premium_avatar.dart';
import '../../../../shared/widgets/premium_glass_app_bar.dart';
import '../../../../shared/widgets/premium_icon_button.dart';
import '../../../../shared/widgets/premium_match_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/shimmer_loading_grid.dart';

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
  late final Animation<double> _borderAnim;

  late final ScrollController _scrollCtrl;
  bool _headerCollapsed = false;
  bool _isInitialLoading = true;
  // TODO: replace with auth state provider (Riverpod)
  static const bool _isGuest = false;

  final _CurrentUser _user = _dummyUser;
  late final String _greetingText;
  late final bool _isEvening;

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

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isInitialLoading = false);
    });
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
  // ── Mini sticky header — PremiumGlassAppBar (shared widget) ─
  Widget _buildMiniHeader(BuildContext context) {
    return PremiumGlassAppBar(
      title: 'Hi, ${_user.name.split(' ').first} 👋',
      centerTitle: false,
      leading: PremiumAvatar(imageUrl: _user.image, size: 34, isOnline: true),
      actions: [
        PremiumIconButton(
          icon: Icons.search_rounded,
          shape: ButtonShape.rounded,
          iconSize: 16,
          padding: 10,
          onTap: () => context.push('/matches'),
        ),
        const SizedBox(width: 8),
        PremiumIconButton(
          icon: Icons.notifications_rounded,
          shape: ButtonShape.rounded,
          iconSize: 16,
          padding: 10,
          badge: _user.unreadNotifications,
          onTap: () => context.push('/notifications'),
        ),
      ],
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
    s.addAll(_sectionLikedYou(context, delay));       delay += 40;
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
      child: SectionHeader(
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
      child: SectionHeader(
        title: 'Daily Matches',
        subtitle: 'Refreshed every morning for you',
        actionText: 'See All',
        onActionTap: () => ctx.push('/matches'),
      ),
    ),
    const SizedBox(height: 16),
    FadeAnimation(
      delayInMs: delay + 20,
      child: _isInitialLoading
          ? const ShimmerLoadingGrid(mode: ShimmerMode.row, itemCount: 4)
          : _dummyDaily.isEmpty
              ? EmptyStateWidget.noMatches(onRefresh: () => ctx.push('/matches'))
              : _buildDailyMatchesRow(ctx),
    ),
  ];

  List<Widget> _sectionLikedYou(BuildContext ctx, int delay) {
    if (_isPremium) return const [];
    return [
      const SizedBox(height: 24),
      FadeAnimation(
        delayInMs: delay,
        child: _isGuest
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: 96,
                  child: GuestLockedCard(
                    borderRadius: AppTheme.cardRadius,
                    child: _buildLikedYouBanner(ctx),
                  ),
                ),
              )
            : _buildLikedYouBanner(ctx),
      ),
    ];
  }

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
      child: SectionHeader(
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
      child: SectionHeader(
        title: 'Success Stories',
        subtitle: 'Couples who found love on Banjara Vivah',
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
              PremiumIconButton(
                icon: Icons.search_rounded,
                shape: ButtonShape.rounded,
                onTap: () => context.push('/matches'),
              ),
              const SizedBox(width: 8),
              PremiumIconButton(
                icon: Icons.notifications_rounded,
                shape: ButtonShape.rounded,
                badge: _user.unreadNotifications,
                onTap: () => context.push('/notifications'),
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
            itemCount: _dummyActive.length,
            itemBuilder: (_, index) =>
                _buildActiveAvatar(context, _dummyActive[index]),
          ),
        ),
      ],
    );
  }

  // ── Liked You Banner ───────────────────────────────────
  // Full-width animated gold banner — placed after daily matches
  // Blurred face previews + dark/gold gradient + pulsing border
  Widget _buildLikedYouBanner(BuildContext context) {
    final count = _user.likedYouCount;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: InkWell(
          onTap: () {
            HapticUtils.mediumImpact();
            context.push('/premium');
          },
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          child: AnimatedBuilder(
            animation: _pulsCtrl,
            builder: (_, child) => Container(
              height: 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                border: Border.all(
                  color: AppTheme.goldPrimary.withValues(
                      alpha: 0.38 + _borderAnim.value * 0.42),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.goldPrimary
                        .withValues(alpha: _borderAnim.value * 0.22),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: child,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.cardRadius - 1.5),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Blurred face previews as background
                  Row(
                    children: _likedYouPreviews.map((url) => Expanded(
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: CustomNetworkImage(imageUrl: url, borderRadius: 0),
                      ),
                    )).toList(),
                  ),
                  // Dark + gold gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1A0814).withValues(alpha: 0.92),
                          AppTheme.goldPrimary.withValues(alpha: 0.55),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                  // Content row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    child: Row(
                      children: [
                        // Heart badge
                        Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            gradient: AppTheme.goldGradient,
                            shape: BoxShape.circle,
                            boxShadow: AppTheme.goldGlow,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.favorite_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              Positioned(
                                bottom: 4, right: 3,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppTheme.brandPrimary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$count people liked you',
                                style: const TextStyle(
                                  fontFamily: 'Cormorant Garamond',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.1,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Upgrade to see who',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  color: AppTheme.goldLight
                                      .withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Arrow
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.goldPrimary
                                .withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.goldLight
                                  .withValues(alpha: 0.35),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 14,
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
      ),
    );
  }

  // ── Active User Avatar ─────────────────────────────────
  // Story-style: brand pink ring, 68px photo,
  // vivid green dot, name below
  Widget _buildActiveAvatar(BuildContext context, _ActiveUser user) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(40),
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
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
                  onLike: () {
                    HapticUtils.heavyImpact();
                    CustomToast.match(context, match.name.split(' ').first);
                  },
                  onSkip: () {
                    HapticUtils.lightImpact();
                    if (_spotlightIndex < _dummySpotlight.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  onInterest: () {
                    HapticUtils.mediumImpact();
                    CustomToast.interestSent(
                        context, match.name.split(' ').first);
                  },
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
                              'BANJARA VIVAH PREMIUM',
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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _dummyDaily.length,
        itemBuilder: (_, index) {
          final match = _dummyDaily[index];
          final card = PremiumMatchCard(
            name:       match.name.split(' ').first,
            age:        match.age,
            imageUrl:   match.image,
            matchPct:   match.matchPct,
            profession: match.profession,
            city:       match.city,
            isOnline:   match.isOnline,
            onTap:      () => context.push('/user_detail'),
            onLike:     () => CustomToast.interestSent(
                context, match.name.split(' ').first),
            onSkip:     () {},
          );
          return FadeAnimation(
            delayInMs: index * 60,
            child: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: SizedBox(
                width: 160,
                // Guests see first 3 cards freely; beyond that — blurred lock
                child: !_isPremium && index >= 3
                    ? GuestLockedCard(borderRadius: 20, child: card)
                    : card,
              ),
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
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  child: MatchBadge(percent: m.matchPct),
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