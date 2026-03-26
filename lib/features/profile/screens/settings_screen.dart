import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../shared/animations/fade_animation.dart';
import '../../../../shared/widgets/custom_network_image.dart';

// ============================================================
// ⚙️ SETTINGS SCREEN — Redesigned
// Improvements:
//   • Mini profile card at top — avatar + name + plan badge
//   • Color-coded icon backgrounds per section (consistent with app)
//   • Toggle tiles — active state tints the row subtly
//   • Privacy section — added 2FA toggle
//   • Notifications — added Master toggle (all on/off)
//   • App section — added Clear Cache tile
//   • Danger zone — redesigned with icon + better spacing
//   • Sign out moved inside danger zone card
//   • App version tile at bottom with build number
//
// TODO: Replace dummy state with settingsProvider (Riverpod)
//       userProvider.logout() on sign out
// ============================================================
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  // ── Dummy user — TODO: replace with userProvider ─────────
  static const Map<String, dynamic> _user = {
    'name':      'Rahul Rathod',
    'phone':     '+91 98765 43210',
    'isPremium': false,
    'image':     'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=400&q=80',
  };

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

  bool _darkMode         = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final isPremium = _user['isPremium'] as bool;

    return Scaffold(
      backgroundColor: AppTheme.bgScaffold,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: 32 + bottomPad),
                children: [

                  // Mini profile card
                  FadeAnimation(
                    delayInMs: 0,
                    child: _buildProfileCard(context, isPremium),
                  ),

                  // Account
                  FadeAnimation(
                    delayInMs: 60,
                    child: _SettingsGroup(
                      title: 'ACCOUNT',
                      icon: Icons.person_outline_rounded,
                      iconColor: const Color(0xFF6366F1),
                      children: [
                        _NavTile(
                          icon: Icons.edit_outlined,
                          iconColor: const Color(0xFF6366F1),
                          label: 'Edit Profile',
                          onTap: () {
                            HapticUtils.lightImpact();
                            context.push('/edit_profile');
                          },
                        ),
                        _NavTile(
                          icon: Icons.phone_outlined,
                          iconColor: const Color(0xFF10B981),
                          label: 'Change Phone Number',
                          value: _user['phone'],
                          onTap: () => _showComingSoon(context),
                        ),
                        _NavTile(
                          icon: Icons.diamond_outlined,
                          iconColor: const Color(0xFFC9962A),
                          label: 'Subscription & Billing',
                          value: isPremium ? 'Premium' : 'Free Plan',
                          valueColor: isPremium
                              ? const Color(0xFFC9962A)
                              : Colors.grey.shade400,
                          onTap: () {
                            HapticUtils.lightImpact();
                            context.push('/premium');
                          },
                        ),
                        _NavTile(
                          icon: Icons.qr_code_rounded,
                          iconColor: AppTheme.brandPrimary,
                          label: 'My QR Code',
                          subtitle: 'Share your profile link',
                          onTap: () => _showComingSoon(context),
                        ),
                      ],
                    ),
                  ),

                  // Privacy
                  FadeAnimation(
                    delayInMs: 100,
                    child: _SettingsGroup(
                      title: 'PRIVACY',
                      icon: Icons.lock_outline_rounded,
                      iconColor: const Color(0xFF0EA5E9),
                      children: [
                        _ToggleTile(
                          icon: Icons.visibility_outlined,
                          iconColor: const Color(0xFF0EA5E9),
                          label: 'Show Online Status',
                          subtitle: 'Others can see when you\'re active',
                          value: _showOnlineStatus,
                          onChanged: (v) {
                            HapticUtils.selectionClick();
                            setState(() => _showOnlineStatus = v);
                          },
                        ),
                        _ToggleTile(
                          icon: Icons.access_time_rounded,
                          iconColor: const Color(0xFF0EA5E9),
                          label: 'Show Last Seen',
                          subtitle: 'Others can see your last active time',
                          value: _showLastSeen,
                          onChanged: (v) {
                            HapticUtils.selectionClick();
                            setState(() => _showLastSeen = v);
                          },
                        ),
                        _ToggleTile(
                          icon: Icons.person_search_outlined,
                          iconColor: const Color(0xFF0EA5E9),
                          label: 'Profile Visible in Search',
                          subtitle: 'Your profile appears in discovery',
                          value: _profileVisible,
                          onChanged: (v) {
                            HapticUtils.selectionClick();
                            setState(() => _profileVisible = v);
                          },
                        ),
                        _ToggleTile(
                          icon: Icons.security_rounded,
                          iconColor: const Color(0xFF0EA5E9),
                          label: 'Two-Factor Authentication',
                          subtitle: 'Extra security for your account',
                          value: _twoFactorAuth,
                          onChanged: (v) {
                            HapticUtils.selectionClick();
                            setState(() => _twoFactorAuth = v);
                          },
                        ),
                        _NavTile(
                          icon: Icons.block_rounded,
                          iconColor: Colors.orange.shade600,
                          label: 'Blocked Users',
                          onTap: () => _showComingSoon(context),
                        ),
                      ],
                    ),
                  ),

                  // Notifications
                  FadeAnimation(
                    delayInMs: 140,
                    child: _SettingsGroup(
                      title: 'NOTIFICATIONS',
                      icon: Icons.notifications_outlined,
                      iconColor: AppTheme.brandPrimary,
                      children: [
                        // Master toggle
                        _ToggleTile(
                          icon: Icons.notifications_active_outlined,
                          iconColor: AppTheme.brandPrimary,
                          label: 'All Notifications',
                          subtitle: 'Master switch for all alerts',
                          value: _masterNotif,
                          isMaster: true,
                          onChanged: (v) {
                            HapticUtils.mediumImpact();
                            setState(() {
                              _masterNotif      = v;
                              _pushInterests    = v;
                              _pushMessages     = v;
                              _pushMatches      = v;
                              _pushProfileViews = v;
                              _pushNewFeatures  = v;
                            });
                          },
                        ),
                        _ToggleTile(
                          icon: Icons.favorite_outline_rounded,
                          iconColor: AppTheme.brandPrimary,
                          label: 'Interests',
                          subtitle: 'When someone sends you an interest',
                          value: _pushInterests,
                          onChanged: (v) {
                            HapticUtils.selectionClick();
                            setState(() => _pushInterests = v);
                          },
                        ),
                        _ToggleTile(
                          icon: Icons.chat_bubble_outline_rounded,
                          iconColor: AppTheme.brandPrimary,
                          label: 'Messages',
                          subtitle: 'New messages from your matches',
                          value: _pushMessages,
                          onChanged: (v) {
                            HapticUtils.selectionClick();
                            setState(() => _pushMessages = v);
                          },
                        ),
                        _ToggleTile(
                          icon: Icons.people_outline_rounded,
                          iconColor: AppTheme.brandPrimary,
                          label: 'New Matches',
                          subtitle: 'When you get a new match',
                          value: _pushMatches,
                          onChanged: (v) {
                            HapticUtils.selectionClick();
                            setState(() => _pushMatches = v);
                          },
                        ),
                        _ToggleTile(
                          icon: Icons.visibility_outlined,
                          iconColor: AppTheme.brandPrimary,
                          label: 'Profile Views',
                          subtitle: 'When someone views your profile',
                          value: _pushProfileViews,
                          onChanged: (v) {
                            HapticUtils.selectionClick();
                            setState(() => _pushProfileViews = v);
                          },
                        ),
                        _ToggleTile(
                          icon: Icons.campaign_outlined,
                          iconColor: AppTheme.brandPrimary,
                          label: 'New Features & Offers',
                          subtitle: 'Product updates and promotions',
                          value: _pushNewFeatures,
                          onChanged: (v) {
                            HapticUtils.selectionClick();
                            setState(() => _pushNewFeatures = v);
                          },
                        ),
                      ],
                    ),
                  ),

                  // App
                  FadeAnimation(
                    delayInMs: 180,
                    child: _SettingsGroup(
                      title: 'APP',
                      icon: Icons.phone_iphone_rounded,
                      iconColor: const Color(0xFF8B5CF6),
                      children: [
                        _ToggleTile(
                          icon: Icons.dark_mode_outlined,
                          iconColor: const Color(0xFF8B5CF6),
                          label: 'Dark Mode',
                          subtitle: 'Switch to dark theme',
                          value: _darkMode,
                          onChanged: (v) {
                            HapticUtils.selectionClick();
                            setState(() => _darkMode = v);
                            // TODO: themeProvider.toggle()
                          },
                        ),
                        _NavTile(
                          icon: Icons.language_rounded,
                          iconColor: const Color(0xFF8B5CF6),
                          label: 'Language',
                          value: 'English',
                          onTap: () => _showComingSoon(context),
                        ),
                        _NavTile(
                          icon: Icons.cleaning_services_outlined,
                          iconColor: const Color(0xFF8B5CF6),
                          label: 'Clear Cache',
                          subtitle: 'Free up storage space',
                          onTap: () => _showClearCacheDialog(context),
                        ),
                        _NavTile(
                          icon: Icons.system_update_outlined,
                          iconColor: Colors.grey.shade400,
                          label: 'App Version',
                          value: 'v1.0.0 (100)',
                          valueColor: Colors.grey.shade400,
                          showArrow: false,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  // Support
                  FadeAnimation(
                    delayInMs: 220,
                    child: _SettingsGroup(
                      title: 'SUPPORT',
                      icon: Icons.help_outline_rounded,
                      iconColor: const Color(0xFF10B981),
                      children: [
                        _NavTile(
                          icon: Icons.help_center_outlined,
                          iconColor: const Color(0xFF10B981),
                          label: 'Help Center',
                          subtitle: 'FAQs and guides',
                          onTap: () => _showComingSoon(context),
                        ),
                        _NavTile(
                          icon: Icons.headset_mic_outlined,
                          iconColor: const Color(0xFF10B981),
                          label: 'Contact Us',
                          subtitle: 'Talk to our support team',
                          onTap: () => _showComingSoon(context),
                        ),
                        _NavTile(
                          icon: Icons.star_outline_rounded,
                          iconColor: const Color(0xFFFFD700),
                          label: 'Rate the App',
                          subtitle: 'Tell us what you think',
                          onTap: () => _showComingSoon(context),
                        ),
                        _NavTile(
                          icon: Icons.privacy_tip_outlined,
                          iconColor: const Color(0xFF10B981),
                          label: 'Privacy Policy',
                          onTap: () => _showComingSoon(context),
                        ),
                        _NavTile(
                          icon: Icons.description_outlined,
                          iconColor: const Color(0xFF10B981),
                          label: 'Terms of Service',
                          onTap: () => _showComingSoon(context),
                        ),
                      ],
                    ),
                  ),

                  // Danger zone
                  FadeAnimation(
                    delayInMs: 260,
                    child: _buildDangerZone(context),
                  ),

                  const SizedBox(height: 8),

                  // Footer
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
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () { HapticUtils.lightImpact(); context.pop(); },
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.white, shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: AppTheme.softShadow,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppTheme.brandDark, size: 16),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Settings', style: TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 30, fontWeight: FontWeight.w700,
                  color: AppTheme.brandDark,
                  letterSpacing: -0.5, height: 1.1,
                )),
                Text('Manage your account & preferences', style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 12,
                  color: Color(0xFF9CA3AF),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Mini profile card ─────────────────────────────────────
  Widget _buildProfileCard(BuildContext context, bool isPremium) {
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        context.push('/edit_profile');
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
            // Avatar
            ClipOval(
              child: SizedBox(
                width: 52, height: 52,
                child: CustomNetworkImage(
                  imageUrl: _user['image'],
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
                      Text(
                        _user['name'],
                        style: const TextStyle(
                          fontFamily: 'Poppins', fontSize: 14,
                          fontWeight: FontWeight.w800, color: AppTheme.brandDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isPremium
                              ? const Color(0xFFFFF3CD)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isPremium
                                ? const Color(0xFFFFD700).withValues(alpha: 0.40)
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Text(
                          isPremium ? '✦ Premium' : 'Free Plan',
                          style: TextStyle(
                            fontFamily: 'Poppins', fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: isPremium
                                ? const Color(0xFFC9962A)
                                : Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _user['phone'],
                    style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.brandPrimary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppTheme.brandPrimary.withValues(alpha: 0.14)),
              ),
              child: const Text('Edit', style: TextStyle(
                fontFamily: 'Poppins', fontSize: 11,
                fontWeight: FontWeight.w700, color: AppTheme.brandPrimary,
              )),
            ),
          ],
        ),
      ),
    );
  }

  // ── Danger zone ───────────────────────────────────────────
  Widget _buildDangerZone(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 13, color: Colors.grey.shade400),
              const SizedBox(width: 6),
              Text('DANGER ZONE', style: TextStyle(
                fontFamily: 'Poppins', fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade400, letterSpacing: 1.2,
              )),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.softShadow,
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: [
                // Sign out
                _DangerListTile(
                  icon: Icons.logout_rounded,
                  label: 'Sign Out',
                  subtitle: 'You can log back in anytime',
                  color: AppTheme.brandPrimary,
                  onTap: () => _showLogoutDialog(context),
                  showDivider: true,
                ),
                // Delete account
                _DangerListTile(
                  icon: Icons.delete_forever_rounded,
                  label: 'Delete Account',
                  subtitle: 'Permanently remove all your data',
                  color: Colors.red.shade500,
                  onTap: () => _showDeleteDialog(context),
                  showDivider: false,
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
        title: 'Sign Out?',
        body: 'You will need to log in again to access your account.',
        confirmLabel: 'Sign Out',
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
        title: 'Delete Account?',
        body: 'This will permanently delete your profile, photos, matches, and all data. This action cannot be undone.',
        confirmLabel: 'Delete Permanently',
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
        iconColor: const Color(0xFF8B5CF6),
        title: 'Clear Cache?',
        body: 'This will clear temporary files and images. Your data will not be affected.',
        confirmLabel: 'Clear Now',
        confirmColor: const Color(0xFF8B5CF6),
        onConfirm: () {
          Navigator.pop(context);
          HapticUtils.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text('Cache cleared successfully',
                    style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
              ],
            ),
            backgroundColor: const Color(0xFF8B5CF6),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ));
        },
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    HapticUtils.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Coming soon!',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
      backgroundColor: AppTheme.brandDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 1),
    ));
  }
}


// ══════════════════════════════════════════════════════════════
// PRIVATE WIDGETS
// ══════════════════════════════════════════════════════════════

// Group card with label
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              Text(title, style: TextStyle(
                fontFamily: 'Poppins', fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade400, letterSpacing: 1.2,
              )),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.softShadow,
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: children.asMap().entries.map((e) {
                final isLast = e.key == children.length - 1;
                return Column(
                  children: [
                    e.value,
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
}

// Nav tile
class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.value,
    this.valueColor,
    this.showArrow = true,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  final String? subtitle;
  final String? value;
  final Color? valueColor;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () { HapticUtils.lightImpact(); onTap(); },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 17, color: iconColor),
      ),
      title: Text(label, style: const TextStyle(
        fontFamily: 'Poppins', fontSize: 13,
        fontWeight: FontWeight.w600, color: AppTheme.brandDark,
      )),
      subtitle: subtitle != null
          ? Text(subtitle!, style: TextStyle(
        fontFamily: 'Poppins', fontSize: 11,
        color: Colors.grey.shade400, height: 1.3,
      ))
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(value!, style: TextStyle(
              fontFamily: 'Poppins', fontSize: 12,
              color: valueColor ?? Colors.grey.shade400,
              fontWeight: FontWeight.w600,
            )),
          if (showArrow) ...[
            const SizedBox(width: 6),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 12, color: Colors.grey.shade300),
          ],
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

// Toggle tile
class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isMaster = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isMaster;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: (isMaster && value)
            ? AppTheme.brandPrimary.withValues(alpha: 0.04)
            : Colors.transparent,
        borderRadius: isMaster ? BorderRadius.circular(20) : BorderRadius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: value
                    ? iconColor.withValues(alpha: 0.12)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 17,
                  color: value ? iconColor : Colors.grey.shade400),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 13,
                    fontWeight: isMaster ? FontWeight.w800 : FontWeight.w600,
                    color: AppTheme.brandDark,
                  )),
                  Text(subtitle, style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 11,
                    color: Colors.grey.shade400, height: 1.3,
                  )),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Transform.scale(
              scale: 0.85,
              child: Switch(
                value: value, onChanged: onChanged,
                activeThumbColor: iconColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Danger list tile (inside card)
class _DangerListTile extends StatelessWidget {
  const _DangerListTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
    required this.showDivider,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          title: Text(label, style: TextStyle(
            fontFamily: 'Poppins', fontSize: 13,
            fontWeight: FontWeight.w700, color: color,
          )),
          subtitle: Text(subtitle, style: TextStyle(
            fontFamily: 'Poppins', fontSize: 11,
            color: Colors.grey.shade400, height: 1.3,
          )),
          trailing: Icon(Icons.arrow_forward_ios_rounded,
              size: 12, color: Colors.grey.shade300),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: Colors.grey.shade100),
          ),
      ],
    );
  }
}

// Confirm dialog — with icon
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
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(
            fontFamily: 'Poppins', fontSize: 16,
            fontWeight: FontWeight.w800, color: AppTheme.brandDark,
          )),
        ],
      ),
      content: Text(body, style: TextStyle(
        fontFamily: 'Poppins', fontSize: 13,
        color: Colors.grey.shade500, height: 1.55,
      )),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(
            fontFamily: 'Poppins', fontWeight: FontWeight.w700,
            color: Colors.grey.shade400,
          )),
        ),
        Container(
          decoration: BoxDecoration(
            color: confirmColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextButton(
            onPressed: onConfirm,
            child: Text(confirmLabel, style: TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.w800,
              color: confirmColor,
            )),
          ),
        ),
      ],
    );
  }
}