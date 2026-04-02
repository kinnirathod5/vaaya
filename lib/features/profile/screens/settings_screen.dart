import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/utils/custom_toast.dart';
import '../../../../shared/animations/fade_animation.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_network_image.dart';
import '../../../../shared/widgets/premium_list_tile.dart';
import '../../../../shared/widgets/section_header.dart';

// ============================================================
// ⚙️ SETTINGS SCREEN — v3.0
//
// v2 → v3 changes:
//   ✅ Inline _NavTile       → PremiumListTile (TileVariant.nav)
//   ✅ Inline _ToggleTile    → PremiumListTile (TileVariant.toggle)
//   ✅ Inline _DangerListTile → PremiumListTile (TileVariant.danger)
//   ✅ Inline _SettingsGroup header → SectionHeader
//   ✅ Toggle feedback       → CustomToast.success / .info
//   ✅ Cache cleared / coming-soon → CustomToast (no inline SnackBar)
//   ✅ ~150 lines of duplicated tile code deleted
//
// TODO: Replace _dummyUser with userProvider (Riverpod)
//       settingsProvider for all toggle states
// ============================================================

// ──────────────────────────────────────────────────────────────
// DATA MODEL
// ──────────────────────────────────────────────────────────────
class _UserProfile {
  const _UserProfile({
    required this.name,
    required this.phone,
    required this.imageUrl,
    required this.isPremium,
  });

  final String name;
  final String phone;
  final String imageUrl;
  final bool isPremium;
}

const _dummyUser = _UserProfile(
  name: 'Rahul Rathod',
  phone: '+91 98765 43210',
  imageUrl:
      'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=400&q=80',
  isPremium: false,
);

// ──────────────────────────────────────────────────────────────
// SCREEN
// ──────────────────────────────────────────────────────────────
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _UserProfile _user = _dummyUser;

  // ── Toggle states ─────────────────────────────────────────
  bool _showOnlineStatus = true;
  bool _showLastSeen     = true;
  bool _profileVisible   = true;
  bool _twoFactorAuth    = false;

  bool _masterNotif      = true;
  bool _pushInterests    = true;
  bool _pushMessages     = true;
  bool _pushMatches      = true;
  bool _pushProfileViews = false;
  bool _pushNewFeatures  = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.bgScaffold,
      appBar: const CustomAppBar(
        title: 'Settings',
        subtitle: 'Manage your account & preferences',
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 32 + bottomPad),
        children: [

                  // ── Mini profile card ─────────────────────
                  FadeAnimation(
                    delayInMs: 0,
                    child: _buildProfileCard(context),
                  ),

                  // ══════════════════════════════════════════
                  // ACCOUNT
                  // ══════════════════════════════════════════
                  FadeAnimation(
                    delayInMs: 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: 'Account',
                          icon: Icons.person_outline_rounded,
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              PremiumListTile(
                                title: 'Edit Profile',
                                leadingIcon: Icons.edit_outlined,
                                iconColor: AppTheme.accentPurple,
                                onTap: () => context.push('/edit_profile'),
                              ),
                              PremiumListTile(
                                title: 'Change Phone Number',
                                leadingIcon: Icons.phone_outlined,
                                iconColor: AppTheme.accentGreen,
                                trailingValue: _user.phone,
                                onTap: () => _showComingSoon(context),
                              ),
                              PremiumListTile(
                                title: 'Subscription & Billing',
                                leadingIcon: Icons.diamond_outlined,
                                iconColor: AppTheme.goldPrimary,
                                trailingValue: _user.isPremium ? 'Premium' : 'Free Plan',
                                trailingValueColor: _user.isPremium
                                    ? AppTheme.goldPrimary
                                    : Colors.grey.shade400,
                                onTap: () => context.push('/premium'),
                              ),
                              PremiumListTile(
                                title: 'My QR Code',
                                subtitle: 'Share your profile link',
                                leadingIcon: Icons.qr_code_rounded,
                                iconColor: AppTheme.brandPrimary,
                                onTap: () => _showComingSoon(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ══════════════════════════════════════════
                  // PRIVACY
                  // ══════════════════════════════════════════
                  FadeAnimation(
                    delayInMs: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: 'Privacy',
                          icon: Icons.lock_outline_rounded,
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              PremiumListTile(
                                title: 'Show online status',
                                subtitle: 'Others can see when you\'re active',
                                leadingIcon: Icons.visibility_outlined,
                                iconColor: AppTheme.accentBlue,
                                variant: TileVariant.toggle,
                                toggleValue: _showOnlineStatus,
                                onToggleChanged: (v) {
                                  setState(() => _showOnlineStatus = v);
                                  CustomToast.success(
                                    context,
                                    v ? 'Online status is now visible' : 'Online status hidden',
                                  );
                                },
                              ),
                              PremiumListTile(
                                title: 'Show last seen',
                                subtitle: 'Others can see your last active time',
                                leadingIcon: Icons.access_time_rounded,
                                iconColor: AppTheme.accentBlue,
                                variant: TileVariant.toggle,
                                toggleValue: _showLastSeen,
                                onToggleChanged: (v) {
                                  setState(() => _showLastSeen = v);
                                  CustomToast.success(
                                    context,
                                    v ? 'Last seen is now visible' : 'Last seen hidden',
                                  );
                                },
                              ),
                              PremiumListTile(
                                title: 'Profile visible in search',
                                subtitle: 'Your profile appears in discovery',
                                leadingIcon: Icons.person_search_outlined,
                                iconColor: AppTheme.accentBlue,
                                variant: TileVariant.toggle,
                                toggleValue: _profileVisible,
                                onToggleChanged: (v) {
                                  setState(() => _profileVisible = v);
                                  CustomToast.success(
                                    context,
                                    v ? 'Profile is visible in search' : 'Profile hidden from search',
                                  );
                                },
                              ),
                              PremiumListTile(
                                title: 'Two-factor authentication',
                                subtitle: 'Extra security for your account',
                                leadingIcon: Icons.security_rounded,
                                iconColor: AppTheme.accentBlue,
                                variant: TileVariant.toggle,
                                toggleValue: _twoFactorAuth,
                                onToggleChanged: (v) {
                                  setState(() => _twoFactorAuth = v);
                                  CustomToast.success(
                                    context,
                                    v ? 'Two-factor auth enabled' : 'Two-factor auth disabled',
                                  );
                                },
                              ),
                              PremiumListTile(
                                title: 'Blocked users',
                                leadingIcon: Icons.block_rounded,
                                iconColor: Colors.orange.shade600,
                                onTap: () => _showComingSoon(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ══════════════════════════════════════════
                  // NOTIFICATIONS
                  // ══════════════════════════════════════════
                  FadeAnimation(
                    delayInMs: 140,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: 'Notifications',
                          icon: Icons.notifications_outlined,
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              PremiumListTile(
                                title: 'All notifications',
                                subtitle: 'Master switch for all alerts',
                                leadingIcon: Icons.notifications_active_outlined,
                                iconColor: AppTheme.brandPrimary,
                                variant: TileVariant.toggle,
                                toggleValue: _masterNotif,
                                onToggleChanged: (v) {
                                  HapticUtils.mediumImpact();
                                  setState(() {
                                    _masterNotif      = v;
                                    _pushInterests    = v;
                                    _pushMessages     = v;
                                    _pushMatches      = v;
                                    _pushProfileViews = v;
                                    _pushNewFeatures  = v;
                                  });
                                  CustomToast.info(
                                    context,
                                    v ? 'All notifications enabled' : 'All notifications muted',
                                  );
                                },
                              ),
                              PremiumListTile(
                                title: 'Interests',
                                subtitle: 'When someone sends you an interest',
                                leadingIcon: Icons.favorite_outline_rounded,
                                iconColor: AppTheme.brandPrimary,
                                variant: TileVariant.toggle,
                                toggleValue: _pushInterests,
                                onToggleChanged: (v) {
                                  setState(() => _pushInterests = v);
                                  CustomToast.success(
                                    context,
                                    v ? 'Interest notifications on' : 'Interest notifications off',
                                  );
                                },
                              ),
                              PremiumListTile(
                                title: 'Messages',
                                subtitle: 'New messages from your matches',
                                leadingIcon: Icons.chat_bubble_outline_rounded,
                                iconColor: AppTheme.brandPrimary,
                                variant: TileVariant.toggle,
                                toggleValue: _pushMessages,
                                onToggleChanged: (v) {
                                  setState(() => _pushMessages = v);
                                  CustomToast.success(
                                    context,
                                    v ? 'Message notifications on' : 'Message notifications off',
                                  );
                                },
                              ),
                              PremiumListTile(
                                title: 'New matches',
                                subtitle: 'When you get a new match',
                                leadingIcon: Icons.people_outline_rounded,
                                iconColor: AppTheme.brandPrimary,
                                variant: TileVariant.toggle,
                                toggleValue: _pushMatches,
                                onToggleChanged: (v) {
                                  setState(() => _pushMatches = v);
                                  CustomToast.success(
                                    context,
                                    v ? 'Match notifications on' : 'Match notifications off',
                                  );
                                },
                              ),
                              PremiumListTile(
                                title: 'Profile views',
                                subtitle: 'When someone views your profile',
                                leadingIcon: Icons.visibility_outlined,
                                iconColor: AppTheme.brandPrimary,
                                variant: TileVariant.toggle,
                                toggleValue: _pushProfileViews,
                                onToggleChanged: (v) {
                                  setState(() => _pushProfileViews = v);
                                  CustomToast.success(
                                    context,
                                    v ? 'Profile view alerts on' : 'Profile view alerts off',
                                  );
                                },
                              ),
                              PremiumListTile(
                                title: 'New features & offers',
                                subtitle: 'Product updates and promotions',
                                leadingIcon: Icons.campaign_outlined,
                                iconColor: AppTheme.brandPrimary,
                                variant: TileVariant.toggle,
                                toggleValue: _pushNewFeatures,
                                onToggleChanged: (v) {
                                  setState(() => _pushNewFeatures = v);
                                  CustomToast.success(
                                    context,
                                    v ? 'Feature updates on' : 'Feature updates off',
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ══════════════════════════════════════════
                  // APP
                  // ══════════════════════════════════════════
                  FadeAnimation(
                    delayInMs: 180,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: 'App',
                          icon: Icons.phone_iphone_rounded,
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              PremiumListTile(
                                title: 'Dark mode',
                                subtitle: 'Coming soon',
                                leadingIcon: Icons.dark_mode_outlined,
                                iconColor: AppTheme.accentViolet,
                                variant: TileVariant.info,
                                onTap: () => _showComingSoon(context),
                              ),
                              PremiumListTile(
                                title: 'Language',
                                leadingIcon: Icons.language_rounded,
                                iconColor: AppTheme.accentViolet,
                                trailingValue: 'English',
                                onTap: () => _showComingSoon(context),
                              ),
                              PremiumListTile(
                                title: 'Clear cache',
                                subtitle: 'Free up storage space',
                                leadingIcon: Icons.cleaning_services_outlined,
                                iconColor: AppTheme.accentViolet,
                                onTap: () => _showClearCacheDialog(context),
                              ),
                              PremiumListTile(
                                title: 'App version',
                                leadingIcon: Icons.system_update_outlined,
                                iconColor: Colors.grey.shade400,
                                variant: TileVariant.info,
                                trailingValue: 'v1.0.0 (100)',
                                trailingValueColor: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ══════════════════════════════════════════
                  // SUPPORT
                  // ══════════════════════════════════════════
                  FadeAnimation(
                    delayInMs: 220,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: 'Support',
                          icon: Icons.help_outline_rounded,
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              PremiumListTile(
                                title: 'Help center',
                                subtitle: 'FAQs and guides',
                                leadingIcon: Icons.help_center_outlined,
                                iconColor: AppTheme.accentGreen,
                                onTap: () => _showComingSoon(context),
                              ),
                              PremiumListTile(
                                title: 'Contact us',
                                subtitle: 'Talk to our support team',
                                leadingIcon: Icons.headset_mic_outlined,
                                iconColor: AppTheme.accentGreen,
                                onTap: () => _showComingSoon(context),
                              ),
                              PremiumListTile(
                                title: 'Rate the app',
                                subtitle: 'Tell us what you think',
                                leadingIcon: Icons.star_outline_rounded,
                                iconColor: AppTheme.goldLight,
                                onTap: () => _showComingSoon(context),
                              ),
                              PremiumListTile(
                                title: 'Privacy policy',
                                leadingIcon: Icons.privacy_tip_outlined,
                                iconColor: AppTheme.accentGreen,
                                onTap: () => _showComingSoon(context),
                              ),
                              PremiumListTile(
                                title: 'Terms of service',
                                leadingIcon: Icons.description_outlined,
                                iconColor: AppTheme.accentGreen,
                                onTap: () => _showComingSoon(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Danger zone ───────────────────────────
                  FadeAnimation(
                    delayInMs: 260,
                    child: _buildDangerZone(context),
                  ),

                  const SizedBox(height: 8),

                  FadeAnimation(
                    delayInMs: 300,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          Text(
                            'Banjara Vivah',
                            style: TextStyle(
                              fontFamily: 'Cormorant Garamond',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Made with ♥ for the Banjara community',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: Colors.grey.shade400,
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

  // ══════════════════════════════════════════════════════════
  // PROFILE CARD
  // ══════════════════════════════════════════════════════════
  Widget _buildProfileCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        context.push('/my_profile');
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.softShadow,
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            ClipOval(
              child: SizedBox(
                width: 52,
                height: 52,
                child: CustomNetworkImage(
                  imageUrl: _user.imageUrl,
                  borderRadius: 26,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _user.name,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.brandDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _user.isPremium
                              ? const Color(0xFFFFF3CD)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _user.isPremium
                                ? AppTheme.goldLight.withValues(alpha: 0.40)
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Text(
                          _user.isPremium ? '✦ Premium' : 'Free Plan',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: _user.isPremium
                                ? AppTheme.goldPrimary
                                : Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _user.phone,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticUtils.lightImpact();
                context.push('/edit_profile');
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.brandPrimary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.brandPrimary.withValues(alpha: 0.14),
                  ),
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.brandPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // DANGER ZONE
  // Red-bordered card wrapper kept; inner tiles → PremiumListTile
  // ══════════════════════════════════════════════════════════
  Widget _buildDangerZone(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.warning_amber_rounded,
                    size: 11, color: Colors.red.shade400),
              ),
              const SizedBox(width: 8),
              Text(
                'Danger zone',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 0.5,
                  color: Colors.red.shade100,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Red-bordered card — PremiumListTile(showDivider:true) strips
          // the per-tile card so they render cleanly inside this wrapper.
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.softShadow,
              border: Border.all(color: Colors.red.shade100),
            ),
            child: Column(
              children: [
                PremiumListTile(
                  title: 'Sign out',
                  subtitle: 'You can log back in anytime',
                  leadingIcon: Icons.logout_rounded,
                  iconColor: AppTheme.brandPrimary,
                  showDivider: true,
                  onTap: () => _showLogoutDialog(context),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: Colors.red.shade50),
                ),
                PremiumListTile(
                  title: 'Delete account',
                  subtitle: 'Permanently remove all your data',
                  leadingIcon: Icons.delete_forever_rounded,
                  variant: TileVariant.danger,
                  showDivider: true,
                  onTap: () => _showDeleteDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Dialogs ───────────────────────────────────────────────
  void _showLogoutDialog(BuildContext context) {
    HapticUtils.mediumImpact();
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        icon: Icons.logout_rounded,
        iconColor: AppTheme.brandPrimary,
        title: 'Sign out?',
        body: 'You will need to log in again to access your account.',
        confirmLabel: 'Sign out',
        confirmColor: AppTheme.brandPrimary,
        onConfirm: () {
          Navigator.pop(context);
          HapticUtils.heavyImpact();
          context.go('/login');
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    HapticUtils.heavyImpact();
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        icon: Icons.delete_forever_rounded,
        iconColor: Colors.red.shade500,
        title: 'Delete account?',
        body:
            'This will permanently delete your profile, photos, matches, and all data. This action cannot be undone.',
        confirmLabel: 'Delete permanently',
        confirmColor: Colors.red.shade500,
        onConfirm: () {
          Navigator.pop(context);
          HapticUtils.heavyImpact();
          context.go('/login');
        },
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    HapticUtils.lightImpact();
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        icon: Icons.cleaning_services_outlined,
        iconColor: AppTheme.accentViolet,
        title: 'Clear cache?',
        body:
            'This will clear temporary files and images. Your data will not be affected.',
        confirmLabel: 'Clear now',
        confirmColor: AppTheme.accentViolet,
        onConfirm: () {
          Navigator.pop(context);
          HapticUtils.mediumImpact();
          CustomToast.success(context, 'Cache cleared successfully');
        },
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    CustomToast.info(context, 'Coming soon!');
  }
}

// ══════════════════════════════════════════════════════════════
// CONFIRM DIALOG
// ══════════════════════════════════════════════════════════════
class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirm,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.brandDark,
            ),
          ),
        ],
      ),
      content: Text(
        body,
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
              color: Colors.grey.shade400,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: confirmColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextButton(
            onPressed: onConfirm,
            child: Text(
              confirmLabel,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
                color: confirmColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
