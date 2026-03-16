import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 🔥 Humare Premium Lego Blocks
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../shared/widgets/custom_network_image.dart';
import '../../../shared/animations/fade_animation.dart';
import '../../../shared/widgets/premium_list_tile.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🌟 Dummy User Data
    const String userName = 'Rahul Rathod';
    const String userAge = '28';
    const String userProfilePic = 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=800&q=80';
    const String userId = 'BV-987654';
    const double profileCompletion = 0.75; // 75% complete

    return Scaffold(
      backgroundColor: AppTheme.bgScaffold,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // 🎩 1. HEADER & PROFILE INFO
              _buildProfileHeader(context, userName, userAge, userId, userProfilePic),

              const SizedBox(height: 25),

              // 📊 2. PROFILE COMPLETION CARD
              _buildProfileCompletionCard(profileCompletion),

              const SizedBox(height: 25),

              // 📈 3. QUICK STATS ROW
              _buildQuickStats(),

              const SizedBox(height: 35),

              // ⚙️ 4. MENU ITEMS (Using PremiumListTile)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 5, bottom: 15),
                      child: Text('Account Settings', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                    FadeAnimation(
                      delayInMs: 400,
                      child: PremiumListTile(
                        title: 'Edit Profile',
                        subtitle: 'Update your photos, bio & family details',
                        leadingIcon: Icons.edit_note_rounded,
                        onTap: () => context.push('/edit_profile'),
                      ),
                    ),
                    FadeAnimation(
                      delayInMs: 450,
                      child: PremiumListTile(
                        title: 'Partner Preferences',
                        subtitle: 'Set age, height, community & location',
                        leadingIcon: Icons.tune_rounded,
                        iconColor: Colors.blueAccent,
                        onTap: () {
                          HapticUtils.lightImpact();
                          // Navigate to Preferences
                        },
                      ),
                    ),
                    FadeAnimation(
                      delayInMs: 500,
                      child: PremiumListTile(
                        title: 'My VIP Subscription',
                        subtitle: 'Manage your premium benefits',
                        leadingIcon: Icons.workspace_premium_rounded,
                        iconColor: Colors.amber.shade600,
                        onTap: () {
                          HapticUtils.lightImpact();
                          // Navigate to Subscription / Upgrade
                        },
                      ),
                    ),
                    FadeAnimation(
                      delayInMs: 550,
                      child: PremiumListTile(
                        title: 'Privacy & Security',
                        subtitle: 'Password, blocked users & visibility',
                        leadingIcon: Icons.security_rounded,
                        iconColor: Colors.green,
                        onTap: () {
                          HapticUtils.lightImpact();
                          // Navigate to Privacy Settings
                        },
                      ),
                    ),
                    FadeAnimation(
                      delayInMs: 600,
                      child: PremiumListTile(
                        title: 'Help & Support',
                        subtitle: 'Contact us or read FAQs',
                        leadingIcon: Icons.support_agent_rounded,
                        iconColor: Colors.orange,
                        onTap: () {
                          HapticUtils.lightImpact();
                          // Navigate to Support
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 🚪 5. LOGOUT BUTTON
              FadeAnimation(
                delayInMs: 700,
                child: GestureDetector(
                  onTap: () {
                    HapticUtils.heavyImpact();
                    // TODO: Implement Logout Logic
                    context.go('/login');
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded, color: Colors.red.shade400, size: 20),
                          const SizedBox(width: 8),
                          Text('Log Out', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red.shade400)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 120), // Spacer for bottom navigation bar
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET BUILDERS
  // ==========================================

  Widget _buildProfileHeader(BuildContext context, String name, String age, String id, String imageUrl) {
    return FadeAnimation(
      delayInMs: 100,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Top Curved Background
          Container(
            height: 120,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.brandPrimary, Color(0xFFFF5E7E)]),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
            ),
          ),
          // Settings Icon Top Right
          Positioned(
            top: 15, right: 20,
            child: GestureDetector(
              onTap: () {
                HapticUtils.lightImpact();
                context.push('/settings');
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.settings_rounded, color: Colors.white, size: 22),
              ),
            ),
          ),
          // Profile Details Column
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Column(
              children: [
                // Profile Picture with Edit Icon
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: CustomNetworkImage(imageUrl: imageUrl, width: 110, height: 110, borderRadius: 55),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: GestureDetector(
                        onTap: () {
                          HapticUtils.mediumImpact();
                          // Open image picker
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppTheme.brandDark, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text('$name, $age', style: const TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.brandDark)),
                const SizedBox(height: 4),
                Text('ID: $id', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                // VIP Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.amber.shade300)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 16),
                      const SizedBox(width: 5),
                      Text('VIP Member', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber.shade700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompletionCard(double progress) {
    return FadeAnimation(
      delayInMs: 200,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.softShadow,
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Profile Completeness', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.brandDark)),
                Text('${(progress * 100).toInt()}%', style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.brandPrimary)),
              ],
            ),
            const SizedBox(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.brandPrimary),
              ),
            ),
            const SizedBox(height: 15),
            Text('Add your family details and hobbies to get up to 2x more matches!', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey.shade600)),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () {
                HapticUtils.mediumImpact();
                // Navigate to edit profile details
              },
              child: const Text('Complete Profile Now ->', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.brandPrimary)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return FadeAnimation(
      delayInMs: 300,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            _statBox('124', 'Profile Views', Icons.visibility_rounded, Colors.purple),
            const SizedBox(width: 15),
            _statBox('45', 'Interests Sent', Icons.favorite_rounded, AppTheme.brandPrimary),
            const SizedBox(width: 15),
            _statBox('12', 'Shortlisted', Icons.star_rounded, Colors.amber),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.brandDark)),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}