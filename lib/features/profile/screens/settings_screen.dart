import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../shared/animations/fade_animation.dart';

// ============================================================
// ⚙️ SETTINGS SCREEN
// Account, Privacy, Notifications, App, Support, Logout
// TODO: Replace dummy state with settingsProvider (Riverpod)
//       userProvider.logout() on sign out
// ============================================================
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  // ── Toggle state ──────────────────────────────────────────
  // TODO: settingsProvider se replace karo
  bool _showOnlineStatus  = true;
  bool _showLastSeen      = true;
  bool _profileVisible    = true;
  bool _pushInterests     = true;
  bool _pushMessages      = true;
  bool _pushMatches       = true;
  bool _pushProfileViews  = false;
  bool _darkMode          = false;

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

                  // Account
                  FadeAnimation(
                    delayInMs: 0,
                    child: _SettingsGroup(
                      title: 'Account',
                      icon: Icons.person_outline_rounded,
                      children: [
                        _NavTile(
                          icon: Icons.edit_outlined,
                          label: 'Edit Profile',
                          onTap: () => context.push('/edit_profile'),
                        ),
                        _NavTile(
                          icon: Icons.phone_outlined,
                          label: 'Change Phone Number',
                          value: '+91 98765 43210',
                          onTap: () => _showComingSoon(context),
                        ),
                        _NavTile(
                          icon: Icons.diamond_outlined,
                          label: 'Subscription & Billing',
                          value: 'Free plan',
                          valueColor: Colors.grey.shade400,
                          onTap: () => context.push('/premium'),
                        ),
                      ],
                    ),
                  ),

                  // Privacy
                  FadeAnimation(
                    delayInMs: 80,
                    child: _SettingsGroup(
                      title: 'Privacy',
                      icon: Icons.lock_outline_rounded,
                      children: [
                        _ToggleTile(
                          icon: Icons.visibility_outlined,
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
                          label: 'Profile Visible in Search',
                          subtitle: 'Your profile appears in discovery',
                          value: _profileVisible,
                          onChanged: (v) {
                            HapticUtils.selectionClick();
                            setState(() => _profileVisible = v);
                          },
                        ),
                        _NavTile(
                          icon: Icons.block_rounded,
                          label: 'Blocked Users',
                          onTap: () => _showComingSoon(context),
                        ),
                      ],
                    ),
                  ),

                  // Notifications
                  FadeAnimation(
                    delayInMs: 160,
                    child: _SettingsGroup(
                      title: 'Notifications',
                      icon: Icons.notifications_outlined,
                      children: [
                        _ToggleTile(
                          icon: Icons.favorite_outline_rounded,
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
                          label: 'Matches',
                          subtitle: 'When you get a new match',
                          value: _pushMatches,
                          onChanged: (v) {
                            HapticUtils.selectionClick();
                            setState(() => _pushMatches = v);
                          },
                        ),
                        _ToggleTile(
                          icon: Icons.visibility_outlined,
                          label: 'Profile Views',
                          subtitle: 'When someone views your profile',
                          value: _pushProfileViews,
                          onChanged: (v) {
                            HapticUtils.selectionClick();
                            setState(() => _pushProfileViews = v);
                          },
                        ),
                      ],
                    ),
                  ),

                  // App
                  FadeAnimation(
                    delayInMs: 240,
                    child: _SettingsGroup(
                      title: 'App',
                      icon: Icons.phone_iphone_rounded,
                      children: [
                        _ToggleTile(
                          icon: Icons.dark_mode_outlined,
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
                          label: 'Language',
                          value: 'English',
                          onTap: () => _showComingSoon(context),
                        ),
                        _NavTile(
                          icon: Icons.system_update_outlined,
                          label: 'App Version',
                          value: '1.0.0',
                          valueColor: Colors.grey.shade400,
                          showArrow: false,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  // Support
                  FadeAnimation(
                    delayInMs: 320,
                    child: _SettingsGroup(
                      title: 'Support',
                      icon: Icons.help_outline_rounded,
                      children: [
                        _NavTile(
                          icon: Icons.help_center_outlined,
                          label: 'Help Center',
                          onTap: () => _showComingSoon(context),
                        ),
                        _NavTile(
                          icon: Icons.chat_outlined,
                          label: 'Contact Us',
                          onTap: () => _showComingSoon(context),
                        ),
                        _NavTile(
                          icon: Icons.star_outline_rounded,
                          label: 'Rate the App',
                          onTap: () => _showComingSoon(context),
                        ),
                        _NavTile(
                          icon: Icons.privacy_tip_outlined,
                          label: 'Privacy Policy',
                          onTap: () => _showComingSoon(context),
                        ),
                        _NavTile(
                          icon: Icons.description_outlined,
                          label: 'Terms of Service',
                          onTap: () => _showComingSoon(context),
                        ),
                      ],
                    ),
                  ),

                  // Danger zone
                  FadeAnimation(
                    delayInMs: 400,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: Column(
                        children: [
                          // Logout
                          _DangerTile(
                            icon: Icons.logout_rounded,
                            label: 'Sign Out',
                            color: AppTheme.brandPrimary,
                            onTap: () => _showLogoutDialog(context),
                          ),
                          const SizedBox(height: 10),
                          // Delete account
                          _DangerTile(
                            icon: Icons.delete_outline_rounded,
                            label: 'Delete Account',
                            color: Colors.red.shade500,
                            onTap: () => _showDeleteDialog(context),
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.brandDark,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              Text(
                'Manage your account & preferences',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
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
        title: 'Sign Out?',
        body: 'You will need to log in again to access your account.',
        confirmLabel: 'Sign Out',
        confirmColor: AppTheme.brandPrimary,
        onConfirm: () {
          Navigator.pop(context);
          HapticUtils.heavyImpact();
          // TODO: authProvider.signOut()
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
        title: 'Delete Account?',
        body: 'This will permanently delete your profile, photos, and all data. This action cannot be undone.',
        confirmLabel: 'Delete Permanently',
        confirmColor: Colors.red.shade500,
        onConfirm: () {
          Navigator.pop(context);
          HapticUtils.heavyImpact();
          // TODO: authProvider.deleteAccount()
          context.go('/login');
        },
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    HapticUtils.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Coming soon!',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.brandDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}


// ══════════════════════════════════════════════════════════
// REUSABLE SETTINGS WIDGETS
// ══════════════════════════════════════════════════════════

// Settings group with title + card container
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group label
          Row(
            children: [
              Icon(icon, size: 13, color: Colors.grey.shade400),
              const SizedBox(width: 6),
              Text(
                title.toUpperCase(),
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
          const SizedBox(height: 10),

          // Card
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
}


// Navigation tile — tap to go somewhere
class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
    this.valueColor,
    this.showArrow = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? value;
  final Color? valueColor;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        HapticUtils.lightImpact();
        onTap();
      },
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16, vertical: 2,
      ),
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Icon(icon, size: 17, color: AppTheme.brandDark),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.brandDark,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(
              value!,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: valueColor ?? Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (showArrow) ...[
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: Colors.grey.shade400,
            ),
          ],
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}


// Toggle tile — on/off switch
class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Icon(icon, size: 17, color: AppTheme.brandDark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.brandDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Colors.grey.shade400,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppTheme.brandPrimary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}


// Danger tile — logout, delete
class _DangerTile extends StatelessWidget {
  const _DangerTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 18, vertical: 14,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.14),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 19),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Confirm dialog — logout / delete account
class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirm,
  });

  final String title;
  final String body;
  final String confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: AppTheme.brandDark,
        ),
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
              color: Colors.grey.shade500,
            ),
          ),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text(
            confirmLabel,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              color: confirmColor,
            ),
          ),
        ),
      ],
    );
  }
}