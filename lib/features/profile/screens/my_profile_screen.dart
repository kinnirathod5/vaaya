import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../shared/animations/fade_animation.dart';
import '../../../../shared/widgets/custom_network_image.dart';

// ============================================================
// 👤 MY PROFILE SCREEN — Redesigned
// Menu-style profile screen (like screenshot reference)
// Sections:
//   • Avatar + Name + Member ID
//   • Upgrade Membership CTA
//   • Stats Row (Views / Interests / Matches)
//   • Profile Completion nudge
//   • Menu Groups: Profile, Discover, Account, Support
//   • Sign Out
//
// TODO: Replace dummy data with userProvider (Riverpod)
//       authProvider.signOut() on logout
// ============================================================
class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  // ── Dummy data — TODO: replace with userProvider ─────────
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
    'profileViews':        42,
    'interestsSent':        8,
    'interestsReceived':    5,
    'matches':              3,
  };

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final isPremium = _user['isPremium'] as bool;

    return Scaffold(
      backgroundColor: AppTheme.bgScaffold,
      body: Stack(
        children: [
          // ── Ambient top glow ─────────────────────────────
          Positioned(
            top: -60, right: -60,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.brandPrimary.withValues(alpha: 0.06),
              ),
            ),
          ),

          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(bottom: 32 + bottomPad),
              children: [

                // ── Top bar ─────────────────────────────────
                FadeAnimation(
                  delayInMs: 0,
                  child: _buildTopBar(context),
                ),

                // ── Profile hero card ────────────────────────
                FadeAnimation(
                  delayInMs: 60,
                  child: _buildProfileHero(context),
                ),

                const SizedBox(height: 16),

                // ── Upgrade banner (non-premium only) ────────
                if (!isPremium)
                  FadeAnimation(
                    delayInMs: 100,
                    child: _buildUpgradeBanner(context),
                  ),

                if (!isPremium) const SizedBox(height: 16),

                // ── Stats row ────────────────────────────────
                FadeAnimation(
                  delayInMs: 130,
                  child: _buildStatsRow(),
                ),

                const SizedBox(height: 16),

                // ── Profile completion ────────────────────────
                if ((_user['completionPct'] as int) < 100)
                  FadeAnimation(
                    delayInMs: 160,
                    child: _buildCompletionBar(context),
                  ),

                if ((_user['completionPct'] as int) < 100)
                  const SizedBox(height: 16),

                // ── Menu groups ──────────────────────────────
                FadeAnimation(
                  delayInMs: 190,
                  child: _buildMenuGroup(
                    title: 'MY PROFILE',
                    icon: Icons.person_outline_rounded,
                    items: [
                      _MenuItem(
                        icon: Icons.edit_outlined,
                        label: 'Edit Profile',
                        subtitle: 'Update your personal details',
                        onTap: () {
                          HapticUtils.lightImpact();
                          context.push('/edit_profile');
                        },
                      ),
                      _MenuItem(
                        icon: Icons.favorite_border_rounded,
                        label: 'Partner Preferences',
                        subtitle: 'Set your ideal match criteria',
                        onTap: () {
                          HapticUtils.lightImpact();
                          context.push('/edit_profile');
                        },
                      ),
                      _MenuItem(
                        icon: Icons.photo_library_outlined,
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

                FadeAnimation(
                  delayInMs: 230,
                  child: _buildMenuGroup(
                    title: 'DISCOVER',
                    icon: Icons.explore_outlined,
                    items: [
                      _MenuItem(
                        icon: Icons.auto_awesome_outlined,
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
                        label: 'Search by Keyword',
                        subtitle: 'Find profiles with specific traits',
                        onTap: () {
                          HapticUtils.lightImpact();
                          context.push('/matches');
                        },
                      ),
                      _MenuItem(
                        icon: Icons.grain_rounded,
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

                FadeAnimation(
                  delayInMs: 270,
                  child: _buildMenuGroup(
                    title: 'ACCOUNT',
                    icon: Icons.manage_accounts_outlined,
                    items: [
                      _MenuItem(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        subtitle: 'Manage your alerts',
                        onTap: () {
                          HapticUtils.lightImpact();
                          context.push('/notifications');
                        },
                      ),
                      _MenuItem(
                        icon: Icons.settings_outlined,
                        label: 'Account & Settings',
                        subtitle: 'Privacy, security & preferences',
                        onTap: () {
                          HapticUtils.lightImpact();
                          context.push('/settings');
                        },
                      ),
                      _MenuItem(
                        icon: Icons.shield_outlined,
                        label: 'Safety Center',
                        subtitle: 'Reporting & safe dating tips',
                        onTap: () => HapticUtils.lightImpact(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                FadeAnimation(
                  delayInMs: 310,
                  child: _buildMenuGroup(
                    title: 'SUPPORT',
                    icon: Icons.help_outline_rounded,
                    items: [
                      _MenuItem(
                        icon: Icons.headset_mic_outlined,
                        label: 'Help & Support',
                        subtitle: 'FAQs & contact our team',
                        onTap: () => HapticUtils.lightImpact(),
                      ),
                      _MenuItem(
                        icon: Icons.star_outline_rounded,
                        label: 'Rate the App',
                        subtitle: 'Tell us what you think',
                        onTap: () => HapticUtils.lightImpact(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Sign out ──────────────────────────────────
                FadeAnimation(
                  delayInMs: 350,
                  child: _buildSignOutButton(context),
                ),

                const SizedBox(height: 12),

                // ── App version ───────────────────────────────
                FadeAnimation(
                  delayInMs: 380,
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

  // ── Top bar ────────────────────────────────────────────────
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
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppTheme.brandDark,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
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
          // Settings shortcut
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
              child: const Icon(
                Icons.settings_outlined,
                color: AppTheme.brandDark,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Profile hero card ──────────────────────────────────────
  Widget _buildProfileHero(BuildContext context) {
    final isVerified = _user['isVerified'] as bool;
    final isPremium  = _user['isPremium']  as bool;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          // Avatar with premium ring
          Stack(
            children: [
              Container(
                padding: isPremium ? const EdgeInsets.all(3) : EdgeInsets.zero,
                decoration: isPremium
                    ? BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFC9962A)],
                  ),
                )
                    : null,
                child: ClipOval(
                  child: SizedBox(
                    width: 72, height: 72,
                    child: CustomNetworkImage(
                      imageUrl: _user['image'],
                      borderRadius: 36,
                    ),
                  ),
                ),
              ),
              if (isVerified)
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF2563EB),
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Name + ID + location
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
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFC9962A)],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'VIP',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'ID — ${_user['memberId']}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 3),
                    Text(
                      '${_user['city']}  ·  ${_user['profession']}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Edit icon
          GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              context.push('/edit_profile');
            },
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: AppTheme.brandPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.brandPrimary.withValues(alpha: 0.15),
                ),
              ),
              child: const Icon(
                Icons.edit_rounded,
                size: 16,
                color: AppTheme.brandPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Upgrade banner ─────────────────────────────────────────
  Widget _buildUpgradeBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticUtils.heavyImpact();
        context.push('/premium');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.brandPrimary, Color(0xFFFF6B84)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.brandPrimary.withValues(alpha: 0.30),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.diamond_rounded,
                color: Colors.white,
                size: 22,
              ),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'UPTO 75% OFF ALL MEMBERSHIP PLANS',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Upgrade',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.brandPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Stats row ──────────────────────────────────────────────
  Widget _buildStatsRow() {
    final items = [
      {
        'label': 'Views',
        'value': '${_stats['profileViews']}',
        'icon': Icons.visibility_outlined,
      },
      {
        'label': 'Interests',
        'value': '${_stats['interestsReceived']}',
        'icon': Icons.favorite_border_rounded,
      },
      {
        'label': 'Sent',
        'value': '${_stats['interestsSent']}',
        'icon': Icons.send_outlined,
      },
      {
        'label': 'Matches',
        'value': '${_stats['matches']}',
        'icon': Icons.people_outline_rounded,
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          return Expanded(
            child: Row(
              children: [
                if (i > 0)
                  Container(
                    width: 1, height: 32,
                    color: Colors.grey.shade100,
                  ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i]['icon'] as IconData,
                        size: 16,
                        color: AppTheme.brandPrimary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[i]['value'] as String,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.brandDark,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
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
          );
        }),
      ),
    );
  }

  // ── Profile completion bar ─────────────────────────────────
  Widget _buildCompletionBar(BuildContext context) {
    final pct = _user['completionPct'] as int;
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
            color: AppTheme.brandPrimary.withValues(alpha: 0.12),
          ),
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          children: [
            // Progress circle indicator
            SizedBox(
              width: 40, height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: pct / 100,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.brandPrimary,
                    ),
                    strokeWidth: 3.5,
                  ),
                  Text(
                    '$pct%',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.brandPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complete your profile',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.brandDark,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Get 3× more matches with a full profile',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // ── Menu group ─────────────────────────────────────────────
  Widget _buildMenuGroup({
    required String title,
    required IconData icon,
    required List<_MenuItem> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group label
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Row(
              children: [
                Icon(icon, size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 6),
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
                    _buildMenuTile(e.value),
                    if (!isLast)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          height: 1,
                          color: Colors.grey.shade100,
                        ),
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
  Widget _buildMenuTile(_MenuItem item) {
    return ListTile(
      onTap: item.onTap,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 4),
      leading: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: AppTheme.brandPrimary.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(item.icon, size: 18, color: AppTheme.brandPrimary),
      ),
      title: Text(
        item.label,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppTheme.brandDark,
        ),
      ),
      subtitle: item.subtitle != null
          ? Text(
        item.subtitle!,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          color: Colors.grey.shade400,
          height: 1.3,
        ),
      )
          : null,
      trailing: Row(
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
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 13,
            color: Colors.grey.shade300,
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  // ── Sign out button ────────────────────────────────────────
  Widget _buildSignOutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          HapticUtils.mediumImpact();
          _showSignOutDialog(context);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: AppTheme.brandPrimary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.brandPrimary.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                size: 17,
                color: AppTheme.brandPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                'Sign Out',
                style: const TextStyle(
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

  // ── Sign out dialog ────────────────────────────────────────
  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        title: const Text(
          'Sign Out?',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppTheme.brandDark,
          ),
        ),
        content: Text(
          'You will need to log in again to access your account.',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: Colors.grey.shade500,
            height: 1.55,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              HapticUtils.heavyImpact();
              // TODO: authProvider.signOut()
              context.go('/login');
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
                color: AppTheme.brandPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ══════════════════════════════════════════════════════════════
// HELPER MODEL
// ══════════════════════════════════════════════════════════════

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.badge,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final String? badge;
  final VoidCallback onTap;
}