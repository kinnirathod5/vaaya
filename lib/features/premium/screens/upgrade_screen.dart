import 'dart:ui';
import 'package:flutter/material.dart';

// 🔥 Humare Premium Lego Blocks
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/animations/fade_animation.dart';
import '../../../shared/widgets/primary_button.dart';

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  // 🌟 State for selected plan (Default 3 Months selected)
  int _selectedPlanIndex = 1;

  // 💎 Dummy Data: Premium Plans
  final List<Map<String, dynamic>> _plans = [
    {
      'months': '1',
      'duration': 'Month',
      'price': '₹999',
      'pricePerMonth': '₹999/mo',
      'save': '',
      'isPopular': false,
    },
    {
      'months': '3',
      'duration': 'Months',
      'price': '₹1,497',
      'pricePerMonth': '₹499/mo',
      'save': 'SAVE 50%',
      'isPopular': true,
    },
    {
      'months': '6',
      'duration': 'Months',
      'price': '₹1,794',
      'pricePerMonth': '₹299/mo',
      'save': 'SAVE 70%',
      'isPopular': false,
    },
  ];

  // 💎 Dummy Data: Premium Features
  final List<Map<String, dynamic>> _features = [
    {'icon': Icons.visibility_rounded, 'title': 'See Who Likes You', 'subtitle': 'Instantly match with people who already liked you.'},
    {'icon': Icons.star_rounded, 'title': 'Unlimited Super Matches', 'subtitle': 'Stand out and get noticed 3x faster.'},
    {'icon': Icons.tune_rounded, 'title': 'Advanced Filters', 'subtitle': 'Find exactly who you are looking for.'},
    {'icon': Icons.replay_circle_filled_rounded, 'title': 'Unlimited Rewinds', 'subtitle': 'Accidentally swiped left? Bring them back.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🌌 Dark Premium Background
      backgroundColor: AppTheme.brandDark,
      body: Stack(
        children: [
          // ✨ LUXURY AMBIENT GLOW (Gold/Purple)
          Positioned(
            top: -100, right: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: Container(width: 300, height: 300, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x40FFD700))), // Gold
            ),
          ),
          Positioned(
            bottom: 100, left: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: Container(width: 250, height: 250, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x309C27B0))), // Purple
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 🎩 HEADER SECTION
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Premium',
                        style: AppTheme.lightTheme.textTheme.displayLarge?.copyWith(fontSize: 32, color: Colors.white),
                      ),
                      GlassContainer(
                        blur: 15, opacity: 0.2,
                        padding: const EdgeInsets.all(12),
                        borderRadius: BorderRadius.circular(30),
                        child: const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 22),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),

                        // 👑 HERO SECTION
                        const FadeAnimation(
                          delayInMs: 100,
                          child: Icon(Icons.diamond_rounded, size: 70, color: Colors.amber),
                        ),
                        const SizedBox(height: 15),
                        const FadeAnimation(
                          delayInMs: 200,
                          child: Text(
                            'Upgrade to VIP',
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FadeAnimation(
                          delayInMs: 300,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              'Get 10x more matches and unlock exclusive features to find your perfect partner.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // 💳 PRICING CARDS (Horizontal Scroll)
                        SizedBox(
                          height: 170,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _plans.length,
                            itemBuilder: (context, index) {
                              return FadeAnimation(
                                delayInMs: 400 + (index * 100),
                                child: _buildPricingCard(index),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 40),

                        // 📋 FEATURES LIST
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('VIP Benefits', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.9))),
                              const SizedBox(height: 20),
                              ...List.generate(_features.length, (index) {
                                final feature = _features[index];
                                return FadeAnimation(
                                  delayInMs: 600 + (index * 100),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), shape: BoxShape.circle),
                                          child: Icon(feature['icon'], color: Colors.amber, size: 24),
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(feature['title'], style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                                              const SizedBox(height: 2),
                                              Text(feature['subtitle'], style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white.withOpacity(0.6))),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 120), // Bottom nav padding
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🔘 FLOATING BOTTOM CTA
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 100), // 100 to clear bottom nav
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter, end: Alignment.topCenter,
                  colors: [AppTheme.brandDark, AppTheme.brandDark.withOpacity(0.9), Colors.transparent],
                  stops: const [0.5, 0.8, 1.0],
                ),
              ),
              child: GestureDetector(
                onTap: () {
                  HapticUtils.heavyImpact();
                  // TODO: Initialize Payment Gateway (Razorpay/Stripe)
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]), // Gold Gradient
                    boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: const Center(
                    child: Text(
                      'Continue',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.brandDark, letterSpacing: 1),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 💳 PRICING CARD BUILDER
  Widget _buildPricingCard(int index) {
    final plan = _plans[index];
    final isSelected = _selectedPlanIndex == index;

    return GestureDetector(
      onTap: () {
        HapticUtils.selectionClick();
        setState(() => _selectedPlanIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 130,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.all(2), // For gradient border effect
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: isSelected
              ? const LinearGradient(colors: [Colors.amber, Colors.orangeAccent], begin: Alignment.topLeft, end: Alignment.bottomRight)
              : LinearGradient(colors: [Colors.grey.shade800, Colors.grey.shade900]),
          boxShadow: isSelected ? [BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))] : [],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.brandDark.withOpacity(0.9) : Colors.grey.shade900,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(plan['months'], style: TextStyle(fontFamily: 'Poppins', fontSize: 32, fontWeight: FontWeight.w900, color: isSelected ? Colors.amber : Colors.white)),
                    Text(plan['duration'], style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.amber.withOpacity(0.8) : Colors.grey.shade500)),
                    const Spacer(),
                    Text(plan['pricePerMonth'], style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 5),
                    Text('Total ${plan['price']}', style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: Colors.white.withOpacity(0.5))),
                  ],
                ),
              ),

              // 🏷️ "SAVE %" or "POPULAR" Badge
              if (plan['save'].toString().isNotEmpty || plan['isPopular'])
                Positioned(
                  top: -10, left: 0, right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Colors.amber, Colors.orange]),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: Text(
                        plan['isPopular'] ? 'MOST POPULAR' : plan['save'],
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 9, fontWeight: FontWeight.w900, color: AppTheme.brandDark),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}