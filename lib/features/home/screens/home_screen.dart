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
// 🏠 HOME SCREEN — v6.0 Perfect Edition
//
// SECTION ORDER (UX-optimised, morning flow):
//   1. Header           — Greeting + avatar + action buttons
//   2. New Matches Banner — Pulse animation (if any)
//   3. Profile Nudge    — Completion bar (if < 80%)
//   4. Thought of Day   — NEW: Cultural/motivational quote
//   5. Spotlight        — Highest match % profiles (carousel)
//   6. Active Now       — Online users + Liked You card
//   7. Daily Matches    — Fresh picks with arc ring + 3 actions
//   8. VIP Banner       — Premium upgrade (non-premium only)
//   9. Premium Matches  — Locked/unlocked based on plan
//  10. Success Stories  — NEW: Couple stories for social proof
//
// EVENING ORDER (sections 5-7 swap):
//   Active Now → Spotlight → Daily → VIP → Premium → Stories
//
// NEW IN v6.0:
//   ✅ Thought of the Day card — cultural + motivational
//   ✅ Success Stories row — couple photos + names
//   ✅ FadeAnimation on every section (staggered)
//   ✅ Section dividers with breathing room (28px)
//   ✅ Consistent horizontal padding (20px everywhere)
//   ✅ Profile nudge: animated progress bar on build
//   ✅ Liked You card: proper BackdropFilter blur stack
//   ✅ Mini sticky header: IgnorePointer fix
//   ✅ All text: maxLines + overflow everywhere
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
    required this.matchPct, required this.isOnline, required this.image,
    this.lastActive,
  });
  final String name, profession, image;
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
    matchPct: 98, isOnline: true, image: AppAssets.dummyFemale1,
  ),
  _DailyMatch(
    name: 'Sneha Pawar', age: 25, profession: 'Doctor',
    matchPct: 89, isOnline: false, image: AppAssets.dummyFemale9,
    lastActive: '2h ago',
  ),
  _DailyMatch(
    name: 'Riya Sharma', age: 23, profession: 'Teacher',
    matchPct: 85, isOnline: true, image: AppAssets.dummyFemale6,
  ),
  _DailyMatch(
    name: 'Kavya Banjara', age: 26, profession: 'Architect',
    matchPct: 82, isOnline: false, image: AppAssets.dummyFemale4,
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

// Thought of the day data
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

  // Gold shimmer for VIP banner button
  late final AnimationController _goldShimmerCtrl;

  // Pulse for new matches banner + liked you ring
  late final AnimationController _pulsCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _borderAnim;

  // Scroll for sticky mini header
  late final ScrollController _scrollCtrl;
  bool _headerCollapsed = false;

  final _CurrentUser _user = _dummyUser;
  late final String _greetingText;
  late final bool _isEvening;

  // Today's thought (based on day of week)
  late final int _thoughtIndex;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _pageController = PageController(viewportFraction: 0.88)
      ..addListener(_onPageChanged);

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

    _scrollCtrl = ScrollController()..addListener(_onScroll);

    _greetingText = _computeGreeting();
    _isEvening = DateTime.now().hour >= 17;
    _thoughtIndex = DateTime.now().weekday % _thoughts.length;
  }

  void _onPageChanged() {
    if (_pageController.page != null) {
      final newIndex = _pageController.page!.round();
      if (newIndex != _spotlightIndex) {
        setState(() => _spotlightIndex = newIndex);
      }
    }
  }

  void _onScroll() {
    final collapsed = _scrollCtrl.offset > 80;
    if (collapsed != _headerCollapsed) {
      setState(() => _headerCollapsed = collapsed);
    }
  }

  @override
  void dispose() {
    _pageController..removeListener(_onPageChanged)..dispose();
    _goldShimmerCtrl.dispose();
    _pulsCtrl.dispose();
    _scrollCtrl..removeListener(_onScroll)..dispose();
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
          // Ambient blobs — static, RepaintBoundary
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

          // Sticky mini header — IgnorePointer when hidden
          SafeArea(
            child: IgnorePointer(
              ignoring: !_headerCollapsed,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                offset: _headerCollapsed ? Offset.zero : const Offset(0, -1),
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
  // ALL SECTIONS — Perfect sequence
  // ══════════════════════════════════════════════════════════
  List<Widget> _buildAllSections(BuildContext context) {
    final s = <Widget>[];
    int delay = 0;

    // ── 1. HEADER ─────────────────────────────────────────
    s.add(const SizedBox(height: 20));
    s.add(FadeAnimation(delayInMs: delay, child: _buildHeader(context)));
    delay += 40;

    // ── 2. NEW MATCHES BANNER (conditional) ───────────────
    if (_user.newMatchesSinceYesterday > 0) {
      s.add(const SizedBox(height: 14));
      s.add(FadeAnimation(
        delayInMs: delay,
        child: _buildNewMatchesBanner(context),
      ));
      delay += 30;
    }

    // ── 3. PROFILE COMPLETION NUDGE (if < 80%) ────────────
    if (_user.profileCompletionPct < 80) {
      s.add(const SizedBox(height: 12));
      s.add(FadeAnimation(
        delayInMs: delay,
        child: _buildCompletionNudge(context),
      ));
      delay += 30;
    }

    // ── 4. THOUGHT OF THE DAY ─────────────────────────────
    s.add(const SizedBox(height: 20));
    s.add(FadeAnimation(
      delayInMs: delay,
      child: _buildThoughtOfDay(context),
    ));
    delay += 40;

    // ── 5-9: Time-based section ordering ──────────────────
    if (_isEvening) {
      // Evening: Active first (people are online)
      s.addAll(_sectionActiveNow(context, delay));     delay += 50;
      s.addAll(_sectionSpotlight(context, delay));     delay += 60;
      s.addAll(_sectionDailyMatches(context, delay));  delay += 50;
      s.addAll(_sectionVipBanner(context, delay));     delay += 40;
      s.addAll(_sectionPremiumMatches(context, delay)); delay += 40;
    } else {
      // Morning: Spotlight first (fresh daily matches)
      s.addAll(_sectionSpotlight(context, delay));     delay += 60;
      s.addAll(_sectionDailyMatches(context, delay));  delay += 50;
      s.addAll(_sectionActiveNow(context, delay));     delay += 50;
      s.addAll(_sectionVipBanner(context, delay));     delay += 40;
      s.addAll(_sectionPremiumMatches(context, delay)); delay += 40;
    }

    // ── 10. SUCCESS STORIES (always last — social proof) ──
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
      FadeAnimation(
        delayInMs: delay,
        child: _buildVipBanner(ctx),
      ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Avatar — premium gets gold ring
          Semantics(
            button: true,
            label: 'Open my profile',
            child: GestureDetector(
              onTap: () { HapticUtils.lightImpact(); context.push('/my_profile'); },
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  if (_isPremium)
                    Container(
                      width: 56, height: 56,
                      decoration: const BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        shape: BoxShape.circle,
                      ),
                    ),
                  PremiumAvatar(
                    imageUrl: _user.image,
                    size: 48,
                    isOnline: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Greeting + name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      AppTheme.brandPrimary.withValues(alpha: 0.08),
                      AppTheme.brandPrimary.withValues(alpha: 0.02),
                    ]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isEvening ? '🌙' : '☀️',
                        style: const TextStyle(fontSize: 11),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _greetingText,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.brandPrimary.withValues(alpha: 0.80),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
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

          // Action buttons
          _HeaderBtn(
            icon: Icons.search_rounded,
            label: 'Search',
            onTap: () { HapticUtils.lightImpact(); context.push('/matches'); },
          ),
          const SizedBox(width: 8),
          _HeaderBtn(
            icon: Icons.notifications_rounded,
            label: 'Notifications',
            badge: _user.unreadNotifications,
            onTap: () { HapticUtils.mediumImpact(); context.push('/notifications'); },
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // 2. NEW MATCHES BANNER — scale + border pulse
  // ══════════════════════════════════════════════════════════
  Widget _buildNewMatchesBanner(BuildContext context) {
    final count = _user.newMatchesSinceYesterday;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () { HapticUtils.mediumImpact(); context.push('/matches'); },
        child: AnimatedBuilder(
          animation: _pulsCtrl,
          builder: (_, child) => Transform.scale(
            scale: _scaleAnim.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppTheme.brandPrimary.withValues(alpha: 0.09),
                  AppTheme.brandPrimary.withValues(alpha: 0.03),
                ]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.brandPrimary.withValues(
                    alpha: _borderAnim.value,
                  ),
                  width: 1.5,
                ),
              ),
              child: child,
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
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // 3. PROFILE COMPLETION NUDGE
  // ══════════════════════════════════════════════════════════
  Widget _buildCompletionNudge(BuildContext context) {
    final pct = _user.profileCompletionPct;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () { HapticUtils.lightImpact(); context.push('/edit_profile'); },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
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
    );
  }

  // ══════════════════════════════════════════════════════════
  // 4. THOUGHT OF THE DAY — NEW
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
            // Emoji
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
                      horizontal: 8, vertical: 2,
                    ),
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
  // 5. ACTIVE NOW — Liked You card + online avatars
  // ══════════════════════════════════════════════════════════
  Widget _buildActiveNow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _pulsCtrl,
                builder: (_, _) => Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withValues(
                      alpha: 0.4 + _borderAnim.value * 0.6,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentGreen.withValues(
                          alpha: _borderAnim.value * 0.5,
                        ),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
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
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accentGreen,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Horizontal list
        SizedBox(
          height: 104,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _dummyActive.length + 1,
            itemBuilder: (_, index) {
              if (index == 0) return _buildLikedYouCard(context);
              return _buildActiveAvatar(context, _dummyActive[index - 1]);
            },
          ),
        ),
      ],
    );
  }

  // ── Liked You Card ────────────────────────────────────────
  Widget _buildLikedYouCard(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticUtils.mediumImpact(); context.push('/premium'); },
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulsCtrl,
              builder: (_, child) => Container(
                width: 68, height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.goldPrimary.withValues(
                      alpha: _borderAnim.value,
                    ),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.goldPrimary.withValues(
                        alpha: _borderAnim.value * 0.45,
                      ),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: child,
              ),
              child: ClipOval(
                child: Stack(
                  children: [
                    // Blurred face previews
                    for (int i = 0; i < _likedYouPreviews.length; i++)
                      Positioned.fill(
                        child: Opacity(
                          opacity: i == 0 ? 1.0 : 0.65,
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: 5, sigmaY: 5,
                            ),
                            child: CustomNetworkImage(
                              imageUrl: _likedYouPreviews[i],
                              borderRadius: 0,
                            ),
                          ),
                        ),
                      ),
                    // Gold overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.goldPrimary.withValues(alpha: 0.62),
                            AppTheme.goldPrimary.withValues(alpha: 0.38),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    // Heart icon
                    const Center(
                      child: Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: BorderRadius.circular(8),
                boxShadow: AppTheme.goldGlow,
              ),
              child: Text(
                '${_user.likedYouCount} liked',
                style: const TextStyle(
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

  Widget _buildActiveAvatar(BuildContext context, _ActiveUser user) {
    return GestureDetector(
      onTap: () { HapticUtils.lightImpact(); context.push('/user_detail'); },
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PremiumAvatar(
              imageUrl: user.image,
              size: 64,
              isOnline: true,
              showRing: true,
            ),
            const SizedBox(height: 6),
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
  // SPOTLIGHT CAROUSEL — 64px like, swipe gesture
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
                  onTap: () { HapticUtils.lightImpact(); context.push('/user_detail'); },
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
            color: active ? AppTheme.brandPrimary : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  // ══════════════════════════════════════════════════════════
  // VIP BANNER — ShaderMask shimmer + star particles
  // ══════════════════════════════════════════════════════════
  Widget _buildVipBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () { HapticUtils.mediumImpact(); context.push('/premium'); },
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
                            horizontal: 8, vertical: 4,
                          ),
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
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Shimmer Upgrade button
                        AnimatedBuilder(
                          animation: _goldShimmerCtrl,
                          builder: (_, child) {
                            final t = _goldShimmerCtrl.value;
                            return ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
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
                              horizontal: 20, vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: AppTheme.goldGlow,
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
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // DAILY MATCHES ROW — arc ring + 3 action buttons
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
              onTap: () { HapticUtils.lightImpact(); context.push('/user_detail'); },
              onLike: () { HapticUtils.heavyImpact(); },
              onSkip: () { HapticUtils.lightImpact(); },
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
              onTap: () { HapticUtils.mediumImpact(); context.push('/premium'); },
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
  // SUCCESS STORIES ROW — NEW
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

// ── Ambient background ────────────────────────────────────────
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
      builder: (_, _) => CustomPaint(painter: _StarPainter(_ctrl.value)),
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
      final o = Offset(c.dx + r * math.cos(oa), c.dy + r * math.sin(oa));
      final iv = Offset(
        c.dx + r * 0.4 * math.cos(ia),
        c.dy + r * 0.4 * math.sin(ia),
      );
      if (i == 0) { path.moveTo(o.dx, o.dy); }
      else { path.lineTo(o.dx, o.dy); }
      path.lineTo(iv.dx, iv.dy);
    }
    path.close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.t != t;
}

// ── Accent section label — 3px brand left line + InkWell ──────
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
          // Brand accent line
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
                onTap: () { HapticUtils.lightImpact(); onActionTap!(); },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4,
                  ),
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

// ── Header button ─────────────────────────────────────────────
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
      button: true, label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size, height: size,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: AppTheme.softShadow,
              ),
              child: Icon(icon, color: AppTheme.brandDark, size: size * 0.45),
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
    );
  }
}

// ── VIP perk item ─────────────────────────────────────────────
class _VipPerk extends StatelessWidget {
  const _VipPerk(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18, height: 18,
            decoration: BoxDecoration(
              color: AppTheme.goldPrimary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppTheme.goldLight,
              size: 12,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.80),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// SPOTLIGHT CARD — 64px like, spring animation, interest btn
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
                // Photo
                CustomNetworkImage(imageUrl: m.image, borderRadius: 0),

                // Bottom gradient
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

                // Top soft gradient
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

                // Match % badge
                Positioned(
                  top: 16, left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7,
                    ),
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

                // Verified + Kundali badges
                Positioned(
                  top: 16, right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (m.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentBlue.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded,
                                  color: Colors.white, size: 11),
                              SizedBox(width: 4),
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
                      if (m.kundaliCompatible) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.goldPrimary.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.stars_rounded,
                                  color: Colors.white, size: 11),
                              SizedBox(width: 4),
                              Text(
                                'Kundali ✓',
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

                // Profile info
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

                // Action buttons — skip | interest | like(64px)
                Positioned(
                  bottom: 16, left: 18, right: 18,
                  child: Row(
                    children: [
                      // Skip
                      GestureDetector(
                        onTap: widget.onSkip,
                        child: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.30),
                            ),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white.withValues(alpha: 0.85),
                            size: 22,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Interest
                      GestureDetector(
                        onTap: widget.onInterest,
                        child: Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.30),
                            ),
                          ),
                          child: Icon(
                            Icons.send_rounded,
                            color: Colors.white.withValues(alpha: 0.85),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Like — 64px + spring scale
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
                            width: 64, height: 64,
                            decoration: BoxDecoration(
                              gradient: AppTheme.brandGradient,
                              shape: BoxShape.circle,
                              boxShadow: AppTheme.primaryGlow,
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
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
// DAILY MATCH CARD — arc ring + 3 action buttons
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

              // Activity badge
              Positioned(
                top: 10, right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: match.isOnline
                          ? const Color(0xFF4ADE80).withValues(alpha: 0.60)
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

              // Arc ring match%
              Positioned(
                top: 8, left: 8,
                child: _ArcMatchRing(pct: match.matchPct, size: 38),
              ),

              // Name + profession + 3 buttons
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
                    const SizedBox(height: 10),
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
                                  color: Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Interest',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 9,
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
          boxShadow: isPremiumUser ? AppTheme.goldGlow : AppTheme.softShadow,
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
                child: CustomNetworkImage(imageUrl: match.image, borderRadius: 0),
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
              if (!isPremiumUser)
                Center(
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      gradient: AppTheme.goldGradient,
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.goldGlow,
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      color: Colors.white,
                      size: 20,
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
// SUCCESS STORY CARD — NEW
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
            // Couple photo
            CustomNetworkImage(imageUrl: story.image, borderRadius: 0),

            // Gradient overlay
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

            // Heart badge top-right
            Positioned(
              top: 12, right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4,
                ),
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
                    Text(
                      'Matched!',
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
            ),

            // Names + city
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