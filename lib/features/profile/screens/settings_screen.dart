import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

// 🔥 Humare Premium Lego Blocks
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../shared/animations/fade_animation.dart';
import '../../../shared/widgets/premium_list_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 🌟 Toggle States (Asli app mein yeh backend/local storage se aayenge)
  bool _pushNotifications = true;
  bool _emailAlerts = false;
  bool _incognitoMode = false; // VIP Feature

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgScaffold,
      appBar: AppBar(
        backgroundColor: AppTheme.bgScaffold,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.brandDark, size: 20),
          onPressed: () {
            HapticUtils.lightImpact();
            context.pop();
          },
        ),
        title: const Text(
          'Settings',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.brandDark),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👤 1. ACCOUNT SECTION
            _buildSectionTitle('Account'),
            FadeAnimation(
              delayInMs: 100,
              child: PremiumListTile(
                title: 'Phone Number',
                subtitle: '+91 98765 43210',
                leadingIcon: Icons.phone_iphone_rounded,
                iconColor: Colors.blueAccent,
                onTap: () => HapticUtils.lightImpact(),
              ),
            ),
            FadeAnimation(
              delayInMs: 150,
              child: PremiumListTile(
                title: 'Email Address',
                subtitle: 'rahul.rathod@example.com',
                leadingIcon: Icons.email_rounded,
                iconColor: Colors.orange,
                onTap: () => HapticUtils.lightImpact(),
              ),
            ),

            const SizedBox(height: 25),

            // 🔔 2. NOTIFICATIONS SECTION
            _buildSectionTitle('Notifications'),
            FadeAnimation(
              delayInMs: 200,
              child: _buildToggleTile(
                title: 'Push Notifications',
                subtitle: 'Match alerts and messages',
                icon: Icons.notifications_active_rounded,
                iconColor: AppTheme.brandPrimary,
                value: _pushNotifications,
                onChanged: (val) {
                  HapticUtils.selectionClick();
                  setState(() => _pushNotifications = val);
                },
              ),
            ),
            FadeAnimation(
              delayInMs: 250,
              child: _buildToggleTile(
                title: 'Email Alerts',
                subtitle: 'Weekly match summaries',
                icon: Icons.mail_rounded,
                iconColor: Colors.purpleAccent,
                value: _emailAlerts,
                onChanged: (val) {
                  HapticUtils.selectionClick();
                  setState(() => _emailAlerts = val);
                },
              ),
            ),

            const SizedBox(height: 25),

            // 🛡️ 3. PRIVACY & SAFETY
            _buildSectionTitle('Privacy & Safety'),
            FadeAnimation(
              delayInMs: 300,
              child: _buildToggleTile(
                title: 'Incognito Mode (VIP)',
                subtitle: 'Hide profile from people you haven\'t liked',
                icon: Icons.visibility_off_rounded,
                iconColor: Colors.amber.shade600,
                value: _incognitoMode,
                isPremium: true,
                onChanged: (val) {
                  HapticUtils.selectionClick();
                  // VIP check logic yahan aayega
                  setState(() => _incognitoMode = val);
                },
              ),
            ),
            FadeAnimation(
              delayInMs: 350,
              child: PremiumListTile(
                title: 'Blocked Users',
                subtitle: 'Manage blocked profiles',
                leadingIcon: Icons.block_rounded,
                iconColor: Colors.redAccent,
                onTap: () => HapticUtils.lightImpact(),
              ),
            ),

            const SizedBox(height: 25),

            // ℹ️ 4. ABOUT & SUPPORT
            _buildSectionTitle('About'),
            FadeAnimation(
              delayInMs: 400,
              child: PremiumListTile(
                title: 'Privacy Policy',
                leadingIcon: Icons.privacy_tip_rounded,
                iconColor: Colors.grey.shade600,
                onTap: () => HapticUtils.lightImpact(),
              ),
            ),
            FadeAnimation(
              delayInMs: 450,
              child: PremiumListTile(
                title: 'Terms of Service',
                leadingIcon: Icons.description_rounded,
                iconColor: Colors.grey.shade600,
                onTap: () => HapticUtils.lightImpact(),
              ),
            ),

            const SizedBox(height: 40),

            // 🗑️ 5. DANGER ZONE
            FadeAnimation(
              delayInMs: 500,
              child: GestureDetector(
                onTap: () {
                  HapticUtils.heavyImpact();
                  // TODO: Delete account confirmation dialog
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade100),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Center(
                    child: Text(
                      'Delete Account',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red.shade400),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // App Version
            Center(
              child: Text(
                'Banjara Vivah v1.0.0\nMade with ❤️ in India',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 📝 Helper: Section Title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey
        ),
      ),
    );
  }

  // 🔘 Helper: Custom Toggle Tile (Switch wala card)
  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isPremium = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.brandDark)),
                    if (isPremium) ...[
                      const SizedBox(width: 5),
                      const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 16),
                    ]
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          // iOS style smooth switch
          CupertinoSwitch(
            value: value,
            activeColor: AppTheme.brandPrimary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}