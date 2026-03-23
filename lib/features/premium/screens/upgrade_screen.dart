import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../shared/animations/fade_animation.dart';

import '../widgets/plan_card.dart';
import '../widgets/perk_item.dart';
import '../widgets/upgrade_header.dart';
import '../widgets/testimonial_card.dart';

// ============================================================
// 💎 UPGRADE SCREEN
// Premium plan selection — dark cinematic design
// TODO: premiumProvider.initiatePayment(plan)
// ============================================================
class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {

  int _selectedPlan = 1; // 0 = 1 month, 1 = 3 months (default), 2 = 6 months

  static const List<Map<String, dynamic>> _plans = [
    {
      'id': 0,
      'duration': '1 Month',
      'price': '₹999',
      'perMonth': '₹999/mo',
      'originalPrice': '₹1,499',
      'saving': null,
      'tag': null,
    },
    {
      'id': 1,
      'duration': '3 Months',
      'price': '₹2,199',
      'perMonth': '₹733/mo',
      'originalPrice': '₹4,497',
      'saving': 'Save 51%',
      'tag': 'Most Popular',
    },
    {
      'id': 2,
      'duration': '6 Months',
      'price': '₹3,599',
      'perMonth': '₹599/mo',
      'originalPrice': '₹8,994',
      'saving': 'Save 60%',
      'tag': 'Best Value',
    },
  ];

  static const List<Map<String, dynamic>> _perks = [
    {
      'icon': Icons.phone_rounded,
      'title': 'Direct Contact Numbers',
      'subtitle': 'Get your match\'s phone number directly.',
      'isHighlight': true,
    },
    {
      'icon': Icons.visibility_rounded,
      'title': 'See Profile Visitors',
      'subtitle': 'Know exactly who viewed your profile.',
      'isHighlight': false,
    },
    {
      'icon': Icons.favorite_rounded,
      'title': 'Unlimited Interests',
      'subtitle': 'Send as many interests as you want.',
      'isHighlight': false,
    },
    {
      'icon': Icons.star_rounded,
      'title': 'Priority Listing',
      'subtitle': 'Your profile appears at the top of search.',
      'isHighlight': false,
    },
    {
      'icon': Icons.auto_graph_rounded,
      'title': 'Advanced Filters',
      'subtitle': 'Filter by Gotra, height, income and more.',
      'isHighlight': false,
    },
    {
      'icon': Icons.workspace_premium_rounded,
      'title': 'Kundali Match Report',
      'subtitle': 'Detailed 36-point compatibility report.',
      'isHighlight': true,
    },
    {
      'icon': Icons.verified_rounded,
      'title': 'Premium Badge',
      'subtitle': 'Verified gold badge on your profile.',
      'isHighlight': false,
    },
    {
      'icon': Icons.support_agent_rounded,
      'title': 'Priority Support',
      'subtitle': '24/7 dedicated customer support.',
      'isHighlight': false,
    },
  ];

  static const List<Map<String, dynamic>> _testimonials = [
    {
      'name': 'Suresh Rathod',
      'city': 'Mumbai',
      'text': 'Found the right match within 2 weeks of going Premium. The contact number feature was incredibly useful.',
      'rating': 5,
    },
    {
      'name': 'Ramesh Pawar',
      'city': 'Pune',
      'text': 'The Kundali Match Report gave us so much confidence. Our families were reassured by the compatibility score.',
      'rating': 5,
    },
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final plan = _plans[_selectedPlan];

    return Scaffold(
      backgroundColor: const Color(0xFF120610),
      body: Stack(
        children: [
          _buildBackground(),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [

                    // Back + member count
                    UpgradeHeader(
                      onBackTap: () {
                        HapticUtils.lightImpact();
                        context.pop();
                      },
                    ),

                    // Diamond icon + title
                    FadeAnimation(
                      delayInMs: 80,
                      child: _buildHeroTitle(),
                    ),
                    const SizedBox(height: 32),

                    // Plan cards
                    FadeAnimation(
                      delayInMs: 180,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: _plans.map((p) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: PlanCard(
                              plan: p,
                              isSelected: _selectedPlan == (p['id'] as int),
                              onTap: () {
                                HapticUtils.selectionClick();
                                setState(() => _selectedPlan = p['id'] as int);
                              },
                            ),
                          )).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Perks
                    FadeAnimation(
                      delayInMs: 260,
                      child: _buildPerksSection(),
                    ),
                    const SizedBox(height: 32),

                    // Testimonials
                    FadeAnimation(
                      delayInMs: 340,
                      child: _buildTestimonials(),
                    ),
                    const SizedBox(height: 32),

                    // Trust badges
                    FadeAnimation(
                      delayInMs: 400,
                      child: _buildTrustBadges(),
                    ),

                    SizedBox(height: 110 + bottomPad),
                  ],
                ),
              ),
            ],
          ),

          // Sticky bottom CTA
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomCTA(plan, bottomPad),
          ),
        ],
      ),
    );
  }

  // ── Background glows ──────────────────────────────────────
  Widget _buildBackground() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(gradient: AppTheme.darkGradient),
        ),
        Positioned(
          top: -60, right: -60,
          child: Container(
            width: 280, height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.goldPrimary.withValues(alpha: 0.07),
            ),
          ),
        ),
        Positioned(
          top: 200, left: -80,
          child: Container(
            width: 220, height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.brandPrimary.withValues(alpha: 0.05),
            ),
          ),
        ),
      ],
    );
  }

  // ── Hero title ────────────────────────────────────────────
  Widget _buildHeroTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.goldGradient,
              boxShadow: AppTheme.goldGlow,
            ),
            child: const Icon(
              Icons.diamond_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'BANJARA VIVAH',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: Color(0xFFF5C842),
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Elite Membership',
            style: TextStyle(
              fontFamily: 'Cormorant Garamond',
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Complete freedom to find your perfect match\n— with just one upgrade.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.45),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Perks section ─────────────────────────────────────────
  Widget _buildPerksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            children: [
              const Text(
                'What you get',
                style: TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.goldPrimary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.goldPrimary.withValues(alpha: 0.28),
                  ),
                ),
                child: const Text(
                  '8 perks',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF5C842),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._perks.map((p) => PerkItem(perk: p)),
      ],
    );
  }

  // ── Testimonials ──────────────────────────────────────────
  Widget _buildTestimonials() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 22),
          child: Text(
            'What members say',
            style: TextStyle(
              fontFamily: 'Cormorant Garamond',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 14),
        ..._testimonials.map((t) => TestimonialCard(testimonial: t)),
      ],
    );
  }

  // ── Trust badges ──────────────────────────────────────────
  Widget _buildTrustBadges() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _TrustBadge(icon: Icons.lock_rounded,    label: '100% Secure'),
          const SizedBox(width: 10),
          _TrustBadge(icon: Icons.cancel_rounded,  label: 'Cancel Anytime'),
          const SizedBox(width: 10),
          _TrustBadge(icon: Icons.verified_rounded, label: 'Verified Profiles'),
        ],
      ),
    );
  }

  // ── Bottom CTA ────────────────────────────────────────────
  Widget _buildBottomCTA(Map<String, dynamic> plan, double bottomPad) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + bottomPad),
          decoration: BoxDecoration(
            color: const Color(0xFF1A0814).withValues(alpha: 0.92),
            border: Border(
              top: BorderSide(
                color: AppTheme.goldPrimary.withValues(alpha: 0.40),
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // Price row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    plan['price'],
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFF5C842),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'for ${plan['duration']}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.42),
                    ),
                  ),
                  if (plan['saving'] != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.success.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Text(
                        plan['saving'],
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4ADE80),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // CTA button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    HapticUtils.heavyImpact();
                    // TODO: premiumProvider.initiatePayment(plan)
                    context.push('/payment');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.goldPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.diamond_rounded, size: 17),
                      const SizedBox(width: 8),
                      Text(
                        'Upgrade to Elite — ${plan['price']}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Auto-renews. Cancel anytime.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.25),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ── Trust badge ───────────────────────────────────────────────
class _TrustBadge extends StatelessWidget {
  const _TrustBadge({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.07),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.goldLight, size: 20),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.42),
              ),
            ),
          ],
        ),
      ),
    );
  }
}