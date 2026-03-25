import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../shared/animations/fade_animation.dart';
import '../../../../shared/widgets/custom_network_image.dart';

// ============================================================
// 👤 MY PROFILE SCREEN — Fully Inlined + UI/UX Upgraded
//
// All widgets inlined — no separate widget files needed:
//   • _ProfileHeroCard
//   • _UpgradeBanner
//   • _StatsRow
//   • _CompletionBar
//   • _MenuGroup + _MenuTile
//   • _SignOutButton
//   • _SignOutDialog
//
// UI/UX Improvements:
//   • Bigger avatar with animated premium ring
//   • Glassmorphism upgrade banner
//   • Stats row with micro-animations
//   • Completion bar with milestone badges
//   • Menu tiles with color-coded icons
//   • Smooth sign out bottom sheet (not dialog)
//   • Ambient background glow
//
// TODO: Replace dummy data with userProvider (Riverpod)
// ============================================================

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen>
    with SingleTickerProviderStateMixin {

  late final AnimationController _shimmerCtrl;

  // ── Dummy data ─────────────────────────────────────────────
  static const Map<String, dynamic> _user = {
    'name':          'Rahul Rathod',
    'memberId':      'BV-7169',
    'age':           28,
    'city':          'Mumbai',
    'profession':    'Product Manager',
    'image':         'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=400&q=80',
    'isPremium':     false,
    'isVerified':    true,
    'completionPct': 72,
    'memberSince':   'March 2024',
  };

  static const Map<String, dynamic> _stats = {
    'profileViews':       42,
    'interestsSent':       8,
    'interestsReceived':   5,
    'matches':             3,
  };

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final isPremium = _user['isPremium'] as bool;

    return Scaffold(
      backgroundColor: AppTheme.bgScaffold,
      body: Stack(
        children: [
          // Ambient glow
          _buildAmbientGlow(),

          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(bottom: 32 + bottomPad),
              children: [

                // Top bar
                FadeAnimation(delayInMs: 0,
                    child: _buildTopBar(context)),

                // Hero card
                FadeAnimation(delayInMs: 60,
                    child: _buildProfileHero(context)),

                const SizedBox(height: 16),

                // Upgrade banner
                if (!isPremium) ...[
                  FadeAnimation(delayInMs: 100,
                      child: _buildUpgradeBanner(context)),
                  const SizedBox(height: 16),
                ],

                // Stats
                FadeAnimation(delayInMs: 130,
                    child: _buildStatsRow(context)),

                const SizedBox(height: 16),

                // Completion bar
                if ((_user['completionPct'] as int) < 100) ...[
                  FadeAnimation(delayInMs: 160,
                      child: _buildCompletionBar(context)),
                  const SizedBox(height: 16),
                ],

                // Menu groups
                FadeAnimation(delayInMs: 190,
                  child: _buildMenuGroup(
                    context,
                    title: 'MY PROFILE',
                    icon: Icons.person_outline_rounded,
                    iconColor: AppTheme.brandPrimary,
                    items: [
                      _MenuItem(
                        icon: Icons.edit_outlined,
                        iconColor: const Color(0xFF6366F1),
                        label: 'Edit Profile',
                        subtitle: 'Update your personal details',
                        onTap: () {
                          HapticUtils.lightImpact();
                          context.push('/edit_profile');
                        },
                      ),
                      _MenuItem(
                        icon: Icons.favorite_border_rounded,
                        iconColor: AppTheme.brandPrimary,
                        label: 'Partner Preferences',
                        subtitle: 'Set your ideal match criteria',
                        onTap: () {
                          HapticUtils.lightImpact();
                          context.push('/edit_profile');
                        },
                      ),
                      _MenuItem(
                        icon: Icons.photo_library_outlined,
                        iconColor: const Color(0xFF0EA5E9),
                        label: 'Manage Photos',
                        subtitle: 'Add or reorder your photos',
                        onTap: () {
                          HapticUtils.lightImpact();
                          context.push('/edit_profile');
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                FadeAnimation(delayInMs: 230,
                  child: _buildMenuGroup(
                    context,
                    title: 'DISCOVER',
                    icon: Icons.explore_outlined,
                    iconColor: const Color(0xFF8B5CF6),
                    items: [
                      _MenuItem(
                        icon: Icons.auto_awesome_outlined,
                        iconColor: const Color(0xFFF59E0B),
                        label: 'Spotlight',
                        subtitle: 'Get featured to top matches',
                        badge: isPremium ? null : 'PREMIUM',
                        onTap: () {
                          HapticUtils.mediumImpact();
                          if (!isPremium) context.push('/premium');
                        },
                      ),
                      _MenuItem(
                        icon: Icons.search_rounded,
                        iconColor: const Color(0xFF0EA5E9),
                        label: 'Search by Keyword',
                        subtitle: 'Find profiles with specific traits',
                        onTap: () {
                          HapticUtils.lightImpact();
                          context.push('/matches');
                        },
                      ),
                      _MenuItem(
                        icon: Icons.grain_rounded,
                        iconColor: const Color(0xFF8B5CF6),
                        label: 'Kundali Matches',
                        subtitle: 'Horoscope-based compatibility',
                        badge: isPremium ? null : 'PREMIUM',
                        onTap: () {
                          HapticUtils.mediumImpact();
                          if (!isPremium) context.push('/premium');
                        },
                      ),
                      _MenuItem(
                        icon: Icons.stars_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        label: 'Astrology Services',
                        subtitle: 'Consult our Jyotish experts',
                        badge: isPremium ? null : 'PREMIUM',
                        onTap: () {
                          HapticUtils.mediumImpact();
                          if (!isPremium) context.push('/premium');
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                FadeAnimation(delayInMs: 270,
                  child: _buildMenuGroup(
                    context,
                    title: 'ACCOUNT',
                    icon: Icons.manage_accounts_outlined,
                    iconColor: const Color(0xFF10B981),
                    items: [
                      _MenuItem(
                        icon: Icons.notifications_outlined,
                        iconColor: AppTheme.brandPrimary,
                        label: 'Notifications',
                        subtitle: 'Manage your alerts',
                        onTap: () {
                          HapticUtils.lightImpact();
                          context.push('/notifications');
                        },
                      ),
                      _MenuItem(
                        icon: Icons.settings_outlined,
                        iconColor: const Color(0xFF6B7280),
                        label: 'Account & Settings',
                        subtitle: 'Privacy, security & preferences',
                        onTap: () {
                          HapticUtils.lightImpact();
                          context.push('/settings');
                        },
                      ),
                      _MenuItem(
                        icon: Icons.shield_outlined,
                        iconColor: const Color(0xFF10B981),
                        label: 'Safety Center',
                        subtitle: 'Reporting & safe dating tips',
                        onTap: () => HapticUtils.lightImpact(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                FadeAnimation(delayInMs: 310,
                  child: _buildMenuGroup(
                    context,
                    title: 'SUPPORT',
                    icon: Icons.help_outline_rounded,
                    iconColor: const Color(0xFF0EA5E9),
                    items: [
                      _MenuItem(
                        icon: Icons.headset_mic_outlined,
                        iconColor: const Color(0xFF0EA5E9),
                        label: 'Help & Support',
                        subtitle: 'FAQs & contact our team',
                        onTap: () => HapticUtils.lightImpact(),
                      ),
                      _MenuItem(
                        icon: Icons.star_outline_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        label: 'Rate the App',
                        subtitle: 'Tell us what you think',
                        onTap: () => HapticUtils.lightImpact(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Sign out
                FadeAnimation(delayInMs: 350,
                    child: _buildSignOutButton(context)),

                const SizedBox(height: 12),

                // App version
                FadeAnimation(delayInMs: 380,
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
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // AMBIENT BACKGROUND
  // ══════════════════════════════════════════════════════════
  Widget _buildAmbientGlow() {
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
          top: 320, left: -80,
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

  // ══════════════════════════════════════════════════════════
  // TOP BAR
  // ══════════════════════════════════════════════════════════
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              context.pop();
            },
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: AppTheme.softShadow,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppTheme.brandDark, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'My Profile',
              style: TextStyle(
                fontFamily: 'Cormorant Garamond',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.brandDark,
                letterSpacing: -0.4,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              context.push('/settings');
            },
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: AppTheme.softShadow,
              ),
              child: const Icon(Icons.settings_outlined,
                  color: AppTheme.brandDark, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // PROFILE HERO CARD
  // ══════════════════════════════════════════════════════════
  Widget _buildProfileHero(BuildContext context) {
    final isVerified = _user['isVerified'] as bool;
    final isPremium  = _user['isPremium']  as bool;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [

          // ── Avatar ────────────────────────────────────
          Stack(
            children: [
              // Premium shimmer ring
              if (isPremium)
                AnimatedBuilder(
                  animation: _shimmerCtrl,
                  builder: (_, __) => Container(
                    width: 82, height: 82,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        transform: GradientRotation(
                            _shimmerCtrl.value * 2 * 3.14),
                        colors: const [
                          Color(0xFFFFD700),
                          Color(0xFFC9962A),
                          Color(0xFFF5C842),
                          Color(0xFFFFD700),
                        ],
                      ),
                    ),
                  ),
                ),
              if (!isPremium)
                Container(
                  width: 82, height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.grey.shade200, width: 2),
                  ),
                ),
              Positioned(
                top: 3, left: 3,
                child: ClipOval(
                  child: SizedBox(
                    width: 76, height: 76,
                    child: CustomNetworkImage(
                      imageUrl: _user['image'],
                      borderRadius: 38,
                    ),
                  ),
                ),
              ),
              // Verified badge
              if (isVerified)
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: const Icon(Icons.verified_rounded,
                        color: Color(0xFF2563EB), size: 20),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // ── Info ──────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _user['name'],
                        style: const TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.brandDark,
                          letterSpacing: -0.3,
                          height: 1.1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isPremium) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            Color(0xFFFFD700), Color(0xFFC9962A)
                          ]),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('VIP', style: TextStyle(
                          fontFamily: 'Poppins', fontSize: 8,
                          fontWeight: FontWeight.w800, color: Colors.white,
                        )),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                // Member ID chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.bgScaffold,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.badge_outlined,
                          size: 10, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        'ID — ${_user['memberId']}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        '${_user['city']}  ·  ${_user['profession']}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Edit button ───────────────────────────────
          GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              context.push('/edit_profile');
            },
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppTheme.brandPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppTheme.brandPrimary.withValues(alpha: 0.15)),
              ),
              child: const Icon(Icons.edit_rounded,
                  size: 16, color: AppTheme.brandPrimary),
            ),
          ),
        ],
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A0814), Color(0xFF2D1020)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: const Color(0xFFFFD700).withValues(alpha: 0.35)),
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
            // Icon
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.25)),
              ),
              child: const Icon(Icons.diamond_rounded,
                  color: Color(0xFFFFD700), size: 22),
            ),
            const SizedBox(width: 14),

            // Text
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
                    'UPTO 75% OFF — Limited Time',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFD700),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow chip
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Upgrade', style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A0814),
              )),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // STATS ROW
  // ══════════════════════════════════════════════════════════
  Widget _buildStatsRow(BuildContext context) {
    final items = [
      {
        'label': 'Views',
        'value': '${_stats['profileViews']}',
        'icon': Icons.visibility_outlined,
        'color': const Color(0xFF2563EB),
        'route': '/my_profile',
      },
      {
        'label': 'Interests',
        'value': '${_stats['interestsReceived']}',
        'icon': Icons.favorite_border_rounded,
        'color': AppTheme.brandPrimary,
        'route': '/interests',
      },
      {
        'label': 'Sent',
        'value': '${_stats['interestsSent']}',
        'icon': Icons.send_outlined,
        'color': const Color(0xFF8B5CF6),
        'route': '/interests',
      },
      {
        'label': 'Matches',
        'value': '${_stats['matches']}',
        'icon': Icons.people_outline_rounded,
        'color': const Color(0xFF10B981),
        'route': '/interests',
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final color = items[i]['color'] as Color;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticUtils.lightImpact();
                context.push(items[i]['route'] as String);
              },
              child: Row(
                children: [
                  if (i > 0)
                    Container(
                        width: 1, height: 36,
                        color: Colors.grey.shade100),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 34, height: 34,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                              items[i]['icon'] as IconData,
                              size: 16, color: color),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          items[i]['value'] as String,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: color,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          items[i]['label'] as String,
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
        }),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // COMPLETION BAR
  // ══════════════════════════════════════════════════════════
  Widget _buildCompletionBar(BuildContext context) {
    final pct = _user['completionPct'] as int;

    // Color based on progress
    final Color barColor = pct < 40
        ? const Color(0xFFEF4444)
        : pct < 70
        ? const Color(0xFFF59E0B)
        : AppTheme.brandPrimary;

    final String message = pct < 40
        ? 'Add your photo & bio to get noticed'
        : pct < 70
        ? 'Almost there! Fill in career details'
        : 'Just a few more details to complete';

    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        context.push('/edit_profile');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: barColor.withValues(alpha: 0.15)),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Circular progress
                SizedBox(
                  width: 44, height: 44,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: pct / 100,
                        backgroundColor: Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(barColor),
                        strokeWidth: 3.5,
                      ),
                      Text(
                        '$pct%',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9,
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
            const SizedBox(height: 12),
            // Linear progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: pct / 100,
                backgroundColor: Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 8),
            // Milestone markers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MilestoneDot(label: '25%', active: pct >= 25,
                    color: barColor),
                _MilestoneDot(label: '50%', active: pct >= 50,
                    color: barColor),
                _MilestoneDot(label: '75%', active: pct >= 75,
                    color: barColor),
                _MilestoneDot(label: '100%', active: pct >= 100,
                    color: barColor),
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
  Widget _buildMenuGroup(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color iconColor,
        required List<_MenuItem> items,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 11, color: iconColor),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade400,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.softShadow,
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: items.asMap().entries.map((e) {
                final isLast = e.key == items.length - 1;
                return Column(
                  children: [
                    _buildMenuTile(context, e.value),
                    if (!isLast)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(height: 1, color: Colors.grey.shade100),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Single menu tile ───────────────────────────────────────
  Widget _buildMenuTile(BuildContext context, _MenuItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: AppTheme.brandPrimary.withValues(alpha: 0.05),
        highlightColor: AppTheme.brandPrimary.withValues(alpha: 0.03),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              // Color-coded icon
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: item.iconColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, size: 18, color: item.iconColor),
              ),
              const SizedBox(width: 14),

              // Label + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.brandDark,
                      ),
                    ),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle!,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: Colors.grey.shade400,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.badge != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFC9962A)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.badge!,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 13, color: Colors.grey.shade300),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // SIGN OUT BUTTON
  // ══════════════════════════════════════════════════════════
  Widget _buildSignOutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          HapticUtils.mediumImpact();
          _showSignOutSheet(context);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppTheme.brandPrimary.withValues(alpha: 0.18)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded,
                  size: 17, color: AppTheme.brandPrimary),
              const SizedBox(width: 8),
              const Text(
                'Sign Out',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.brandPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // SIGN OUT BOTTOM SHEET (replaces dialog — feels more native)
  // ══════════════════════════════════════════════════════════
  void _showSignOutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(
          24, 12, 24,
          24 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 24),

            // Icon
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F3),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppTheme.brandPrimary.withValues(alpha: 0.20)),
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

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('Cancel', style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade500,
                    )),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      HapticUtils.heavyImpact();
                      // TODO: authProvider.signOut()
                      context.go('/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.brandPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Sign Out', style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    )),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// HELPER MODELS & WIDGETS
// ══════════════════════════════════════════════════════════════

/// Menu item data model
class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.badge,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final String? badge;
  final VoidCallback onTap;
}

/// Milestone dot for completion bar
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
          width: 8, height: 8,
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