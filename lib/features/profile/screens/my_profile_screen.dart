import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../shared/animations/fade_animation.dart';
import '../../../../shared/widgets/custom_network_image.dart';

import '../widgets/profile_header_card.dart';
import '../widgets/profile_completion_bar.dart';
import '../widgets/profile_info_section.dart';
import '../widgets/profile_stats_row.dart';
import '../widgets/profile_action_tile.dart';

// ============================================================
// 👤 MY PROFILE SCREEN
// User's own profile — view, edit, settings
// TODO: Replace dummy data with userProvider (Riverpod)
// ============================================================
class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  static const Map<String, dynamic> _user = {
    'name': 'Rahul Rathod',
    'age': 28,
    'city': 'Mumbai',
    'profession': 'Product Manager',
    'education': 'MBA',
    'height': "5'10\"",
    'gotra': 'Rathod',
    'community': 'Banjara',
    'about': 'Looking for a sincere, family-oriented partner. I love travelling and good food. Family comes first.',
    'image': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=800&q=80',
    'isPremium': false,
    'isVerified': true,
    'memberSince': 'March 2024',
    'completionPct': 72,
    'photos': [
      'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
    ],
  };

  static const Map<String, dynamic> _stats = {
    'profileViews': 42,
    'interestsSent': 8,
    'interestsReceived': 5,
    'matches': 3,
  };

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.bgScaffold,
      body: Stack(
        children: [
          // Ambient glow
          Positioned(
            top: -80, right: -80,
            child: Container(
              width: 240, height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.brandPrimary.withValues(alpha: 0.05),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [

              // ── Collapsible hero ─────────────────────────
              SliverAppBar(
                expandedHeight: 300,
                collapsedHeight: 64,
                pinned: true,
                backgroundColor: AppTheme.bgScaffold,
                elevation: 0,
                systemOverlayStyle: SystemUiOverlayStyle.dark,
                leading: GestureDetector(
                  onTap: () {
                    HapticUtils.lightImpact();
                    context.pop();
                  },
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppTheme.brandDark,
                      size: 16,
                    ),
                  ),
                ),
                actions: [
                  GestureDetector(
                    onTap: () {
                      HapticUtils.lightImpact();
                      context.push('/settings');
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: const Icon(
                        Icons.settings_rounded,
                        color: AppTheme.brandDark,
                        size: 18,
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomNetworkImage(
                        imageUrl: _user['image'],
                        borderRadius: 0,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.40),
                            ],
                            stops: const [0.5, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── All content sections ─────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 32 + bottomPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Name + badges + edit button
                      FadeAnimation(
                        delayInMs: 100,
                        child: ProfileHeaderCard(
                          user: _user,
                          onEditTap: () {
                            HapticUtils.lightImpact();
                            context.push('/edit_profile');
                          },
                          onUpgradeTap: () {
                            HapticUtils.mediumImpact();
                            context.push('/premium');
                          },
                        ),
                      ),

                      // Completion nudge
                      if ((_user['completionPct'] as int) < 100)
                        FadeAnimation(
                          delayInMs: 160,
                          child: ProfileCompletionBar(
                            percent: _user['completionPct'] as int,
                            onTap: () {
                              HapticUtils.lightImpact();
                              context.push('/edit_profile');
                            },
                          ),
                        ),

                      // Stats
                      FadeAnimation(
                        delayInMs: 220,
                        child: ProfileStatsRow(stats: _stats),
                      ),

                      // About
                      FadeAnimation(
                        delayInMs: 280,
                        child: ProfileInfoSection(
                          title: 'About Me',
                          child: Text(
                            _user['about'],
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              height: 1.65,
                            ),
                          ),
                        ),
                      ),

                      // Basic details
                      FadeAnimation(
                        delayInMs: 340,
                        child: ProfileInfoSection(
                          title: 'Basic Details',
                          child: _DetailsGrid(user: _user),
                        ),
                      ),

                      // Photos
                      FadeAnimation(
                        delayInMs: 400,
                        child: ProfileInfoSection(
                          title: 'Photos',
                          trailing: GestureDetector(
                            onTap: () => context.push('/edit_profile'),
                            child: const Text(
                              'Add More',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.brandPrimary,
                              ),
                            ),
                          ),
                          child: _PhotosRow(photos: _user['photos'] as List),
                        ),
                      ),

                      // Quick actions
                      FadeAnimation(
                        delayInMs: 460,
                        child: _QuickActions(
                          onEdit: () => context.push('/edit_profile'),
                          onUpgrade: () => context.push('/premium'),
                          onNotifications: () => context.push('/notifications'),
                          onSettings: () => context.push('/settings'),
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
    );
  }
}


// ── Details Grid ─────────────────────────────────────────────
class _DetailsGrid extends StatelessWidget {
  const _DetailsGrid({required this.user});
  final Map<String, dynamic> user;

  @override
  Widget build(BuildContext context) {
    final cardWidth = (MediaQuery.of(context).size.width - 68) / 2;
    final details = [
      {'icon': Icons.cake_rounded,        'label': 'Age',        'value': '${user['age']} years'},
      {'icon': Icons.height_rounded,       'label': 'Height',     'value': user['height']},
      {'icon': Icons.work_outline_rounded, 'label': 'Profession', 'value': user['profession']},
      {'icon': Icons.school_outlined,      'label': 'Education',  'value': user['education']},
      {'icon': Icons.location_on_outlined, 'label': 'City',       'value': user['city']},
      {'icon': Icons.diversity_1_rounded,  'label': 'Gotra',      'value': user['gotra']},
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: details.map((d) {
        return SizedBox(
          width: cardWidth,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(d['icon'] as IconData,
                    size: 15, color: AppTheme.brandPrimary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d['label'] as String,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        d['value'] as String,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.brandDark,
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
        );
      }).toList(),
    );
  }
}


// ── Photos Row ───────────────────────────────────────────────
class _PhotosRow extends StatelessWidget {
  const _PhotosRow({required this.photos});
  final List photos;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: photos.length + 1,
        itemBuilder: (context, index) {
          if (index == photos.length) {
            return GestureDetector(
              onTap: () => context.push('/edit_profile'),
              child: Container(
                width: 80,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.brandPrimary.withValues(alpha: 0.20),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: AppTheme.brandPrimary.withValues(alpha: 0.45),
                  size: 22,
                ),
              ),
            );
          }
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CustomNetworkImage(
                imageUrl: photos[index],
                borderRadius: 14,
              ),
            ),
          );
        },
      ),
    );
  }
}


// ── Quick Actions ────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onEdit,
    required this.onUpgrade,
    required this.onNotifications,
    required this.onSettings,
  });

  final VoidCallback onEdit, onUpgrade, onNotifications, onSettings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACCOUNT',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade400,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              children: [
                ProfileActionTile(
                  icon: Icons.edit_rounded,
                  label: 'Edit Profile',
                  onTap: () { HapticUtils.lightImpact(); onEdit(); },
                  showDivider: true,
                ),
                ProfileActionTile(
                  icon: Icons.diamond_rounded,
                  label: 'Upgrade to Premium',
                  iconColor: const Color(0xFFC9962A),
                  onTap: () { HapticUtils.mediumImpact(); onUpgrade(); },
                  showDivider: true,
                ),
                ProfileActionTile(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  onTap: () { HapticUtils.lightImpact(); onNotifications(); },
                  showDivider: true,
                ),
                ProfileActionTile(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () { HapticUtils.lightImpact(); onSettings(); },
                  showDivider: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}