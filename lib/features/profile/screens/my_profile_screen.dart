import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/custom_toast.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../shared/animations/fade_animation.dart';
import '../../../../shared/widgets/custom_network_image.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/premium_list_tile.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/shimmer_loading_grid.dart';

// ============================================================
// 👤 MY PROFILE SCREEN — v3.0
//
// Fixes over v2:
//   ✅ FIX 1 — AnimatedOpacity bug: both branches were 1.0
//              Now: opacity 0.0 → 1.0 as user scrolls
//   ✅ FIX 2 — PageRouteBuilder duplicate `_` param
//              Changed (_, animation, _) → (ctx, animation, __)
//   ✅ FIX 3 — GestureDetector → InkWell on sign-out button
//              Proper ripple with borderRadius
//   ✅ FIX 4 — Pull-to-refresh implemented (was "TODO" comment)
//              RefreshIndicator wraps ListView
//   ✅ FIX 5 — Stats row: individual tappable cards per stat
//              Cleaner than divider-line approach
//   ✅ FIX 6 — Menu section headers: sentence case
//              "MY PROFILE" → "My profile" (architecture doc rule)
//   ✅ FIX 7 — Quick edit shortcut on hero card
//   ✅ FIX 8 — Profession text hierarchy (w700 + darker colour)
//
// TODO: Replace _dummyUser with userProvider (Riverpod)
//       Replace _dummyStats with statsProvider
// ============================================================

// ──────────────────────────────────────────────────────────────
// DATA MODELS — Type-safe, Riverpod-ready
// ──────────────────────────────────────────────────────────────

class _UserProfile {
  const _UserProfile({
    required this.name,
    required this.memberId,
    required this.age,
    required this.city,
    required this.profession,
    required this.imageUrl,
    required this.isPremium,
    required this.isVerified,
    required this.completionPct,
    required this.memberSince,
  });

  final String name;
  final String memberId;
  final int age;
  final String city;
  final String profession;
  final String imageUrl;
  final bool isPremium;
  final bool isVerified;
  final int completionPct;
  final String memberSince;
}

class _ProfileStats {
  const _ProfileStats({
    required this.profileViews,
    required this.interestsSent,
    required this.interestsReceived,
    required this.matches,
  });

  final int profileViews;
  final int interestsSent;
  final int interestsReceived;
  final int matches;
}

class _MenuItemData {
  const _MenuItemData({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.route,
    this.subtitle,
    this.badge,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String? route;
  final String? subtitle;
  final String? badge;
}

class _MenuGroupData {
  const _MenuGroupData({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final List<_MenuItemData> items;
}

// ──────────────────────────────────────────────────────────────
// DUMMY DATA — TODO: Replace with Riverpod providers
// ──────────────────────────────────────────────────────────────

const _dummyUser = _UserProfile(
  name: 'Rahul Rathod',
  memberId: 'BV-7169',
  age: 28,
  city: 'Mumbai',
  profession: 'Product Manager',
  imageUrl:
  AppAssets.dummyMale1,
  isPremium: false,
  isVerified: true,
  completionPct: 72,
  memberSince: 'March 2024',
);

const _dummyStats = _ProfileStats(
  profileViews: 42,
  interestsSent: 8,
  interestsReceived: 5,
  matches: 3,
);

// ──────────────────────────────────────────────────────────────
// SCREEN
// ──────────────────────────────────────────────────────────────

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _shimmerCtrl;

  final ScrollController _scrollCtrl = ScrollController();
  double _scrollOffset = 0;

  bool _isRefreshing = false;
  bool _isLoading = true;

  final _UserProfile _user = _dummyUser;
  final _ProfileStats _stats = _dummyStats;

  late final List<_MenuGroupData> _menuGroups;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    if (_user.isPremium) {
      _shimmerCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1800),
      )..repeat();
    }

    _scrollCtrl.addListener(_onScroll);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isLoading = false);
    });

    // ── FIX 6: sentence case titles ──────────────────────────
    _menuGroups = [
      _MenuGroupData(
        title: 'My profile',           // was: 'MY PROFILE'
        icon: Icons.person_outline_rounded,
        iconColor: AppTheme.brandPrimary,
        items: [
          _MenuItemData(
            icon: Icons.edit_outlined,
            iconColor: AppTheme.accentPurple,
            label: 'Edit Profile',
            subtitle: 'Update your personal details',
            route: '/edit_profile',
          ),
          _MenuItemData(
            icon: Icons.photo_library_outlined,
            iconColor: AppTheme.accentOrange,
            label: 'Manage Photos',
            subtitle: 'Add, reorder or delete photos',
            route: '/edit_profile',
            badge: 'NEW',
          ),
          _MenuItemData(
            icon: Icons.verified_outlined,
            iconColor: AppTheme.accentGreen,
            label: 'Verify Profile',
            subtitle: 'Get the blue badge',
            route: null,
          ),
        ],
      ),
      _MenuGroupData(
        title: 'Activity',             // was: 'ACTIVITY'
        icon: Icons.insights_rounded,
        iconColor: AppTheme.accentViolet,
        items: [
          _MenuItemData(
            icon: Icons.visibility_outlined,
            iconColor: AppTheme.accentViolet,
            label: 'Who Viewed Me',
            subtitle: '${_dummyStats.profileViews} views this week',
            route: '/premium',
            badge: 'VIP',
          ),
          _MenuItemData(
            icon: Icons.favorite_border_rounded,
            iconColor: AppTheme.brandPrimary,
            label: 'My Interests',
            subtitle: 'Sent & received interests',
            route: '/dashboard',
          ),
          _MenuItemData(
            icon: Icons.bookmark_border_rounded,
            iconColor: const Color(0xFFF59E0B),
            label: 'Shortlisted',
            subtitle: 'Profiles you saved',
            route: null,
          ),
        ],
      ),
      _MenuGroupData(
        title: 'More',                 // was: 'MORE'
        icon: Icons.grid_view_rounded,
        iconColor: AppTheme.accentBlue,
        items: [
          _MenuItemData(
            icon: Icons.headset_mic_outlined,
            iconColor: AppTheme.accentBlue,
            label: 'Help & Support',
            subtitle: 'FAQs & contact our team',
            route: null,
          ),
          _MenuItemData(
            icon: Icons.share_outlined,
            iconColor: AppTheme.accentGreen,
            label: 'Invite Friends',
            subtitle: 'Share the app with family',
            route: null,
          ),
          _MenuItemData(
            icon: Icons.star_outline_rounded,
            iconColor: const Color(0xFFF59E0B),
            label: 'Rate the App',
            subtitle: 'Tell us what you think',
            route: null,
          ),
        ],
      ),
    ];
  }

  void _onScroll() {
    if (!mounted) return;
    setState(() => _scrollOffset = _scrollCtrl.offset);
  }

  @override
  void dispose() {
    _shimmerCtrl?.dispose();
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── FIX 4: Pull-to-refresh handler ───────────────────────
  Future<void> _onRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    HapticUtils.lightImpact();
    // TODO: Trigger Riverpod provider refresh here
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _isRefreshing = false);
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.bgScaffold,
      body: Stack(
        children: [
          RepaintBoundary(child: _AmbientGlow()),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),

                Expanded(
                  // ── FIX 4: RefreshIndicator wrapping ListView ──
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: AppTheme.brandPrimary,
                    backgroundColor: Colors.white,
                    strokeWidth: 2.5,
                    child: ListView(
                      controller: _scrollCtrl,
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      padding: EdgeInsets.only(bottom: 32 + bottomPad),
                      children: [
                        FadeAnimation(
                          delayInMs: 60,
                          child: _buildProfileHero(context),
                        ),
                        const SizedBox(height: 16),

                        if (!_user.isPremium) ...[
                          FadeAnimation(
                            delayInMs: 100,
                            child: _buildUpgradeBanner(context),
                          ),
                          const SizedBox(height: 16),
                        ],

                        FadeAnimation(
                          delayInMs: 130,
                          child: _isLoading
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: ShimmerLoadingGrid(
                                    mode: ShimmerMode.row,
                                    itemCount: 4,
                                  ),
                                )
                              : Semantics(
                                  label:
                                  'Profile statistics: ${_stats.profileViews} views, ${_stats.matches} matches',
                                  child: _buildStatsRow(context),
                                ),
                        ),
                        const SizedBox(height: 16),

                        if (_user.completionPct < 100) ...[
                          FadeAnimation(
                            delayInMs: 160,
                            child: Semantics(
                              label:
                              'Profile completion ${_user.completionPct} percent',
                              child: _buildCompletionBar(context),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        ..._menuGroups.asMap().entries.map((entry) {
                          final delay = 190 + (entry.key * 60);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: FadeAnimation(
                              delayInMs: delay,
                              child: _buildMenuGroup(context, entry.value),
                            ),
                          );
                        }),

                        const SizedBox(height: 4),

                        FadeAnimation(
                          delayInMs: 380,
                          child: _buildSignOutButton(context),
                        ),
                        const SizedBox(height: 12),

                        FadeAnimation(
                          delayInMs: 410,
                          child: Center(
                            child: Text(
                              'Banjara Vivah  •  v1.0.0',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ),
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
  // TOP BAR
  // ── FIX 1: AnimatedOpacity was always 1.0 → now 0.0 to 1.0
  // ══════════════════════════════════════════════════════════
  Widget _buildTopBar(BuildContext context) {
    final bgOpacity = (_scrollOffset / 80).clamp(0.0, 1.0);

    // FIX 1: was `bgOpacity > 0.5 ? 1.0 : 1.0` — both identical!
    // Now title fades in from 0 → 1 as user scrolls
    final titleOpacity = (_scrollOffset / 60).clamp(0.0, 1.0);

    return Container(
      color: AppTheme.bgScaffold.withValues(alpha: bgOpacity),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            size: 16,
            onTap: () {
              HapticUtils.lightImpact();
              context.pop();
            },
            semanticLabel: 'Go back',
          ),
          const SizedBox(width: 14),
          Expanded(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: titleOpacity,              // ← FIX 1
              child: const Text(
                'My Profile',
                style: TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.brandDark,
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ),
          _CircleIconButton(
            icon: Icons.settings_outlined,
            size: 20,
            onTap: () {
              HapticUtils.lightImpact();
              context.push('/settings');
            },
            semanticLabel: 'Open settings',
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // PROFILE HERO CARD
  // ── FIX 7: Quick edit button in top-right corner
  // ── FIX 8: Profession has stronger visual weight
  // ══════════════════════════════════════════════════════════
  Widget _buildProfileHero(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: GlassContainer(
        blur: 12,
        opacity: 0.82,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // ── Avatar ────────────────────────────────────────
          GestureDetector(
            onTap: () => _showFullScreenPhoto(context),
            child: Semantics(
              label: 'Profile photo of ${_user.name}. Tap to view.',
              button: true,
              child: Hero(
                tag: 'profile-avatar',
                child: _buildAvatar(),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // ── Info — Expanded, no overflow possible ─────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + verified badge
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _user.name,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.brandDark,
                          letterSpacing: -0.2,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_user.isVerified) ...[
                      const SizedBox(width: 6),
                      const _VerifiedBadge(),
                    ],
                  ],
                ),
                const SizedBox(height: 4),

                // Age + city
                Text(
                  '${_user.age} yrs  •  ${_user.city}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),

                // Profession
                Text(
                  _user.profession,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppTheme.brandDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),

                // ── Bottom row: Member ID + Edit button ───────
                // "March 2024" pill hataya, Edit button yahan rakha
                // Dono ek hi Row mein — fit rahenge, overflow nahi
                Row(
                  children: [
                    // Member ID pill
                    _InfoPill(
                      icon: Icons.badge_outlined,
                      text: _user.memberId,
                    ),
                    const SizedBox(width: 8),

                    // ── Edit button (March 2024 ki jagah) ─────
                    GestureDetector(
                      onTap: () {
                        HapticUtils.lightImpact();
                        context.push('/edit_profile');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.brandPrimary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.brandPrimary.withValues(alpha: 0.20),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit_outlined,
                                size: 12, color: AppTheme.brandPrimary),
                            const SizedBox(width: 4),
                            const Text(
                              'Edit',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.brandPrimary,
                              ),
                            ),
                          ],
                        ),
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

  // ── Avatar builder ────────────────────────────────────────
  Widget _buildAvatar() {
    const double size = 82;
    const double photoSize = 74;
    const double photoOffset = (size - photoSize) / 2;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          if (_user.isPremium && _shimmerCtrl != null)
            ListenableBuilder(
              listenable: _shimmerCtrl!,
              builder: (_, __) => Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    transform:
                    GradientRotation(_shimmerCtrl!.value * 2 * 3.14159),
                    colors: const [
                      AppTheme.goldLight,
                      Color(0xFFC9962A),
                      Color(0xFFF5C842),
                      AppTheme.goldLight,
                    ],
                  ),
                ),
              ),
            )
          else
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 2.5,
                ),
              ),
            ),

          Positioned(
            top: photoOffset,
            left: photoOffset,
            child: ClipOval(
              child: SizedBox(
                width: photoSize,
                height: photoSize,
                child: CustomNetworkImage(
                  imageUrl: _user.imageUrl,
                  borderRadius: photoSize / 2,
                ),
              ),
            ),
          ),

          if (_user.isVerified)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: AppTheme.softShadow,
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  size: 15,
                  color: Color(0xFF0EA5E9),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Full screen photo viewer ──────────────────────────────
  void _showFullScreenPhoto(BuildContext context) {
    HapticUtils.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.92),
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        // ── FIX 2: was (_, animation, _) — duplicate underscore param
        pageBuilder: (ctx, animation, __) {
          return FadeTransition(
            opacity: animation,
            child: _FullScreenPhotoView(
              imageUrl: _user.imageUrl,
              heroTag: 'profile-avatar',
              userName: _user.name,
            ),
          );
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // UPGRADE BANNER
  // ══════════════════════════════════════════════════════════
  Widget _buildUpgradeBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticUtils.heavyImpact();
        context.push('/premium');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A0814), Color(0xFF2D1020)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.goldLight.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppTheme.goldLight.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.goldLight.withValues(alpha: 0.25),
                ),
              ),
              child: const Icon(Icons.diamond_rounded,
                  color: AppTheme.goldLight, size: 22),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upgrade Membership',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'UP TO 75% OFF — Limited Time',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.goldLight,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.goldLight.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: AppTheme.goldLight.withValues(alpha: 0.80),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // STATS ROW
  // ── FIX 5: Individual tappable cards per stat
  //           Cleaner than divider-line approach
  // ══════════════════════════════════════════════════════════
  Widget _buildStatsRow(BuildContext context) {
    final items = [
      _StatItem(
        icon: Icons.visibility_outlined,
        value: '${_stats.profileViews}',
        label: 'Views',
        color: AppTheme.accentViolet,
        route: '/premium',
      ),
      _StatItem(
        icon: Icons.favorite_border_rounded,
        value: '${_stats.interestsSent}',
        label: 'Sent',
        color: AppTheme.brandPrimary,
        route: '/dashboard',
      ),
      _StatItem(
        icon: Icons.inbox_rounded,
        value: '${_stats.interestsReceived}',
        label: 'Received',
        color: const Color(0xFFF59E0B),
        route: '/dashboard',
      ),
      _StatItem(
        icon: Icons.handshake_outlined,
        value: '${_stats.matches}',
        label: 'Matches',
        color: AppTheme.accentGreen,
        route: '/dashboard',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Expanded(
            child: Padding(
              // Small gap between cards
              padding: EdgeInsets.only(left: i == 0 ? 0 : 6),
              child: GestureDetector(
                onTap: () {
                  HapticUtils.lightImpact();
                  if (item.route != null) context.push(item.route!);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.softShadow,
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon, size: 15, color: item.color),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.value,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: item.color,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // COMPLETION BAR
  // ══════════════════════════════════════════════════════════
  Widget _buildCompletionBar(BuildContext context) {
    final pct = _user.completionPct;

    final Color barColor = pct < 40
        ? const Color(0xFFEF4444)
        : pct < 70
        ? const Color(0xFFF59E0B)
        : AppTheme.brandPrimary;

    final String message = pct < 40
        ? 'Add your photo & bio to get noticed'
        : pct < 70
        ? 'Almost there! Complete for 3x more matches'
        : 'Just a few steps away from 100%';

    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        context.push('/edit_profile');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.softShadow,
          border: Border.all(color: barColor.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: barColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '$pct%',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: barColor,
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
                        'Profile $pct% complete',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.brandDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 13, color: Colors.grey.shade300),
              ],
            ),
            const SizedBox(height: 14),

            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: pct / 100),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (_, value, __) => LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MilestoneDot(label: '25%', active: pct >= 25, color: barColor),
                _MilestoneDot(label: '50%', active: pct >= 50, color: barColor),
                _MilestoneDot(label: '75%', active: pct >= 75, color: barColor),
                _MilestoneDot(label: '100%', active: pct >= 100, color: barColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // MENU GROUP
  // ══════════════════════════════════════════════════════════
  Widget _buildMenuGroup(BuildContext context, _MenuGroupData group) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: group.title,
            icon: group.icon,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 10),

          ...group.items.map((item) => PremiumListTile(
            title: item.label,
            subtitle: item.subtitle,
            leadingIcon: item.icon,
            iconColor: item.iconColor,
            trailingValue: item.badge,
            trailingValueColor: AppTheme.goldPrimary,
            onTap: () {
              if (item.route != null) {
                context.push(item.route!);
              } else {
                _showComingSoon(context);
              }
            },
          )),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // SIGN OUT BUTTON
  // ── FIX 3: GestureDetector → InkWell for proper ripple
  // ══════════════════════════════════════════════════════════
  Widget _buildSignOutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: PrimaryButton(
        text: 'Sign Out',
        icon: Icons.logout_rounded,
        variant: ButtonVariant.outlined,
        height: 50,
        onTap: () => _showSignOutSheet(context),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // SIGN OUT BOTTOM SHEET
  // ══════════════════════════════════════════════════════════
  void _showSignOutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SignOutSheet(
        onConfirm: () async {
          Navigator.pop(context);
          HapticUtils.heavyImpact();
          final router = GoRouter.of(context);
          await Future.delayed(const Duration(milliseconds: 180));
          if (!mounted) return;
          router.go('/login');
        },
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    CustomToast.info(context, 'Coming soon!');
  }
}

// ══════════════════════════════════════════════════════════════
// HELPER WIDGETS
// ══════════════════════════════════════════════════════════════

class _AmbientGlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -60,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.brandPrimary.withValues(alpha: 0.06),
            ),
          ),
        ),
        Positioned(
          top: 320,
          left: -80,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentViolet.withValues(alpha: 0.04),
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.size,
    required this.onTap,
    this.semanticLabel,
  });

  final IconData icon;
  final double size;
  final VoidCallback onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: AppTheme.softShadow,
            ),
            child: Icon(icon, color: AppTheme.brandDark, size: size),
          ),
        ),
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Verified profile',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.accentBlue.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_rounded, size: 12, color: Color(0xFF0EA5E9)),
            SizedBox(width: 3),
            Text(
              'Verified',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0EA5E9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.grey.shade400),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.route,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final String? route;
}

class _MilestoneDot extends StatelessWidget {
  const _MilestoneDot({
    required this.label,
    required this.active,
    required this.color,
  });

  final String label;
  final bool active;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? color : Colors.grey.shade200,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 9,
            color: active ? color : Colors.grey.shade300,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SignOutSheet extends StatelessWidget {
  const _SignOutSheet({required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 24),

          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F3),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.brandPrimary.withValues(alpha: 0.20),
              ),
            ),
            child: const Icon(Icons.logout_rounded,
                color: AppTheme.brandPrimary, size: 28),
          ),
          const SizedBox(height: 16),

          const Text(
            'Sign Out?',
            style: TextStyle(
              fontFamily: 'Cormorant Garamond',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppTheme.brandDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You will need to log in again\nto access your account.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  text: 'Cancel',
                  variant: ButtonVariant.ghost,
                  height: 50,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  text: 'Sign Out',
                  variant: ButtonVariant.filled,
                  height: 50,
                  onTap: onConfirm,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FullScreenPhotoView extends StatelessWidget {
  const _FullScreenPhotoView({
    required this.imageUrl,
    required this.heroTag,
    required this.userName,
  });

  final String imageUrl;
  final String heroTag;
  final String userName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity!.abs() > 200) {
            Navigator.pop(context);
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: heroTag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.82,
                    height: MediaQuery.of(context).size.width * 0.82,
                    child: CustomNetworkImage(
                      imageUrl: imageUrl,
                      borderRadius: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                userName,
                style: const TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Tap anywhere to close',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}