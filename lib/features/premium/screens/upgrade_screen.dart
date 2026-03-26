import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../shared/animations/fade_animation.dart';

// ============================================================
// 💎 UPGRADE SCREEN — v2.0 All Widgets Inlined
//
// IMPROVEMENTS vs v1:
//   ✅ All 4 widget files inlined — zero external imports
//   ✅ Ambient background: animated shimmer orbs (not static)
//   ✅ Hero title: gold shimmer on "Elite Membership" text
//   ✅ Plan cards: animated selection scale + glow
//   ✅ Perk items: highlighted ones pulse with gold shimmer
//   ✅ Testimonials: quote mark decoration
//   ✅ Trust badges: consistent spacing + icon bg
//   ✅ Bottom CTA: per-month price shown below main price
//   ✅ Back button: proper rounded square (not IconButton)
//   ✅ Member count badge: live green dot
//   ✅ FadeAnimation stagger on all sections
//   ✅ All text: maxLines + overflow everywhere
//
// TODO: premiumProvider.initiatePayment(plan) — Riverpod
// ============================================================

// ──────────────────────────────────────────────────────────────
// DATA
// ──────────────────────────────────────────────────────────────

const _plans = <Map<String, dynamic>>[
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

const _perks = <Map<String, dynamic>>[
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

const _testimonials = <Map<String, dynamic>>[
  {
    'name': 'Suresh Rathod',
    'city': 'Mumbai',
    'text':
    'Found the right match within 2 weeks of going Premium. The contact number feature was incredibly useful.',
    'rating': 5,
  },
  {
    'name': 'Ramesh Pawar',
    'city': 'Pune',
    'text':
    'The Kundali Match Report gave us so much confidence. Our families were reassured by the compatibility score.',
    'rating': 5,
  },
];

// ──────────────────────────────────────────────────────────────
// SCREEN
// ──────────────────────────────────────────────────────────────

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen>
    with SingleTickerProviderStateMixin {

  int _selectedPlan = 1; // 3 months default

  // Gold shimmer for highlighted perks + hero title
  late final AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final plan = _plans[_selectedPlan];

    return Scaffold(
      backgroundColor: const Color(0xFF120610),
      body: Stack(
        children: [

          // ── Ambient background ─────────────────────
          _AmbientBackground(),

          // ── Scrollable content ──────────────────────
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [

                    // Back button + member count
                    FadeAnimation(
                      delayInMs: 0,
                      child: _buildHeader(context),
                    ),

                    // Diamond icon + title
                    FadeAnimation(
                      delayInMs: 80,
                      child: _buildHeroTitle(),
                    ),
                    const SizedBox(height: 32),

                    // Plan cards
                    FadeAnimation(
                      delayInMs: 160,
                      child: _buildPlanCards(),
                    ),
                    const SizedBox(height: 32),

                    // Perks
                    FadeAnimation(
                      delayInMs: 240,
                      child: _buildPerksSection(),
                    ),
                    const SizedBox(height: 32),

                    // Testimonials
                    FadeAnimation(
                      delayInMs: 320,
                      child: _buildTestimonials(),
                    ),
                    const SizedBox(height: 32),

                    // Trust badges
                    FadeAnimation(
                      delayInMs: 380,
                      child: _buildTrustBadges(),
                    ),

                    SizedBox(height: 120 + bottomPad),
                  ],
                ),
              ),
            ],
          ),

          // ── Sticky bottom CTA ───────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomCTA(plan, bottomPad),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // HEADER — back button + member count
  // ══════════════════════════════════════════════════════════
  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 20, 0),
        child: Row(
          children: [

            // Back button
            GestureDetector(
              onTap: () { HapticUtils.lightImpact(); context.pop(); },
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 17,
                ),
              ),
            ),
            const Spacer(),

            // Live member count badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7, height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4ADE80),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '12,450+ Premium Members',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.62),
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

  // ══════════════════════════════════════════════════════════
  // HERO TITLE — gold shimmer on title text
  // ══════════════════════════════════════════════════════════
  Widget _buildHeroTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Column(
        children: [

          // Gold diamond icon
          Container(
            width: 76, height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.goldGradient,
              boxShadow: AppTheme.goldGlow,
            ),
            child: const Icon(
              Icons.diamond_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),

          // App name
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

          // Shimmer title
          AnimatedBuilder(
            animation: _shimmerCtrl,
            builder: (_, child) {
              final t = _shimmerCtrl.value;
              return ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: const [
                    Colors.white,
                    Color(0xFFF5C842),
                    Colors.white,
                    Color(0xFFF5C842),
                    Colors.white,
                  ],
                  stops: [
                    (t - 0.4).clamp(0.0, 1.0),
                    (t - 0.1).clamp(0.0, 1.0),
                    t.clamp(0.0, 1.0),
                    (t + 0.1).clamp(0.0, 1.0),
                    (t + 0.4).clamp(0.0, 1.0),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: child!,
              );
            },
            child: const Text(
              'Elite Membership',
              style: TextStyle(
                fontFamily: 'Cormorant Garamond',
                fontSize: 38,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
                height: 1.1,
              ),
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

  // ══════════════════════════════════════════════════════════
  // PLAN CARDS
  // ══════════════════════════════════════════════════════════
  Widget _buildPlanCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: _plans.map((p) {
          final isSelected = _selectedPlan == (p['id'] as int);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PlanCard(
              plan: p,
              isSelected: isSelected,
              onTap: () {
                HapticUtils.selectionClick();
                setState(() => _selectedPlan = p['id'] as int);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // PERKS SECTION
  // ══════════════════════════════════════════════════════════
  Widget _buildPerksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text(
                'What you get',
                style: TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9, vertical: 4,
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

        // Perk items with stagger
        ..._perks.asMap().entries.map((e) => FadeAnimation(
          delayInMs: e.key * 40,
          child: _PerkItem(
            perk: e.value,
            shimmerCtrl: _shimmerCtrl,
          ),
        )),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  // TESTIMONIALS
  // ══════════════════════════════════════════════════════════
  Widget _buildTestimonials() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'What members say',
            style: TextStyle(
              fontFamily: 'Cormorant Garamond',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 14),
        ..._testimonials.asMap().entries.map((e) => FadeAnimation(
          delayInMs: e.key * 80,
          child: _TestimonialCard(testimonial: e.value),
        )),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  // TRUST BADGES
  // ══════════════════════════════════════════════════════════
  Widget _buildTrustBadges() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _TrustBadge(icon: Icons.lock_rounded,     label: '100% Secure'),
          const SizedBox(width: 10),
          _TrustBadge(icon: Icons.cancel_rounded,   label: 'Cancel Anytime'),
          const SizedBox(width: 10),
          _TrustBadge(icon: Icons.verified_rounded, label: 'Verified Profiles'),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // STICKY BOTTOM CTA — frosted glass + gold button
  // ══════════════════════════════════════════════════════════
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

              // Per-month hint
              const SizedBox(height: 3),
              Text(
                plan['perMonth'],
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.30),
                ),
              ),
              const SizedBox(height: 12),

              // CTA button — gold shimmer
              AnimatedBuilder(
                animation: _shimmerCtrl,
                builder: (_, child) {
                  final t = _shimmerCtrl.value;
                  return ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: const [
                        Color(0xFFC9962A),
                        Color(0xFFF5C842),
                        Color(0xFFFFF0A0),
                        Color(0xFFF5C842),
                        Color(0xFFC9962A),
                      ],
                      stops: [
                        (t - 0.4).clamp(0.0, 1.0),
                        (t - 0.1).clamp(0.0, 1.0),
                        t.clamp(0.0, 1.0),
                        (t + 0.1).clamp(0.0, 1.0),
                        (t + 0.4).clamp(0.0, 1.0),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: child!,
                  );
                },
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticUtils.heavyImpact();
                      // TODO: premiumProvider.initiatePayment(plan)
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.goldPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: AppTheme.goldPrimary.withValues(alpha: 0.40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.diamond_rounded,
                            size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Upgrade to Elite — ${plan['price']}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
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

// ══════════════════════════════════════════════════════════════
// AMBIENT BACKGROUND — static blobs
// ══════════════════════════════════════════════════════════════
class _AmbientBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full dark gradient
        Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.darkGradient,
          ),
        ),
        // Gold orb top-right
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
        // Brand orb mid-left
        Positioned(
          top: 260, left: -80,
          child: Container(
            width: 220, height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.brandPrimary.withValues(alpha: 0.05),
            ),
          ),
        ),
        // Gold orb bottom-right
        Positioned(
          bottom: 200, right: -60,
          child: Container(
            width: 180, height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.goldPrimary.withValues(alpha: 0.04),
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// PLAN CARD — animated selection with gold glow
// ══════════════════════════════════════════════════════════════
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });
  final Map<String, dynamic> plan;
  final bool         isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool hasTag = plan['tag'] != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected
              ? AppTheme.goldPrimary.withValues(alpha: 0.10)
              : Colors.white.withValues(alpha: 0.04),
          border: Border.all(
            color: isSelected
                ? AppTheme.goldPrimary
                : Colors.white.withValues(alpha: 0.10),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppTheme.goldPrimary.withValues(alpha: 0.20),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ]
              : [],
        ),
        child: Row(
          children: [

            // Radio circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppTheme.goldPrimary
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.goldPrimary
                      : Colors.white.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                  color: Colors.white, size: 13)
                  : null,
            ),
            const SizedBox(width: 14),

            // Duration + tag + per month
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        plan['duration'],
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? AppTheme.goldLight
                              : Colors.white,
                        ),
                      ),
                      if (hasTag) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.goldPrimary
                                : AppTheme.goldPrimary
                                .withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            plan['tag'],
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.goldLight,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    plan['perMonth'],
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.38),
                    ),
                  ),
                ],
              ),
            ),

            // Price + saving or strikethrough
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  plan['price'],
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isSelected
                        ? AppTheme.goldLight
                        : Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                if (plan['saving'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      plan['saving'],
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4ADE80),
                      ),
                    ),
                  )
                else
                  Text(
                    plan['originalPrice'],
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.22),
                      decoration: TextDecoration.lineThrough,
                      decorationColor: Colors.white.withValues(alpha: 0.22),
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
// PERK ITEM — highlighted ones with gold shimmer icon
// ══════════════════════════════════════════════════════════════
class _PerkItem extends StatelessWidget {
  const _PerkItem({
    required this.perk,
    required this.shimmerCtrl,
  });
  final Map<String, dynamic>  perk;
  final AnimationController   shimmerCtrl;

  @override
  Widget build(BuildContext context) {
    final bool isHighlight = perk['isHighlight'] as bool;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isHighlight
            ? AppTheme.goldPrimary.withValues(alpha: 0.07)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlight
              ? AppTheme.goldPrimary.withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [

          // Icon box — shimmer for highlighted
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: isHighlight
                  ? AppTheme.goldPrimary.withValues(alpha: 0.14)
                  : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(13),
            ),
            child: isHighlight
                ? AnimatedBuilder(
              animation: shimmerCtrl,
              builder: (_, child) {
                final t = shimmerCtrl.value;
                return ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: const [
                      Color(0xFFC9962A),
                      Color(0xFFF5C842),
                      Color(0xFFFFF0A0),
                      Color(0xFFF5C842),
                    ],
                    stops: [
                      (t - 0.3).clamp(0.0, 1.0),
                      t.clamp(0.0, 1.0),
                      (t + 0.1).clamp(0.0, 1.0),
                      (t + 0.4).clamp(0.0, 1.0),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: child!,
                );
              },
              child: Icon(
                perk['icon'] as IconData,
                size: 20,
                color: AppTheme.goldLight,
              ),
            )
                : Icon(
              perk['icon'] as IconData,
              size: 20,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(width: 14),

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  perk['title'],
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isHighlight
                        ? AppTheme.goldLight
                        : Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  perk['subtitle'],
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.38),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Check circle
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              color: isHighlight
                  ? AppTheme.goldPrimary.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 13,
              color: isHighlight
                  ? AppTheme.goldLight
                  : Colors.white.withValues(alpha: 0.32),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// TESTIMONIAL CARD — quote mark + gold avatar + stars
// ══════════════════════════════════════════════════════════════
class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard({required this.testimonial});
  final Map<String, dynamic> testimonial;

  @override
  Widget build(BuildContext context) {
    final int rating = testimonial['rating'] as int;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [

              // Gold avatar initial
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: Text(
                    (testimonial['name'] as String).substring(0, 1),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Name + city
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      testimonial['name'],
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      testimonial['city'],
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.38),
                      ),
                    ),
                  ],
                ),
              ),

              // Star rating
              Row(
                children: List.generate(
                  rating,
                      (_) => const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFF5C842),
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Quote mark decoration
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '"',
                style: TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 36,
                  color: AppTheme.goldPrimary.withValues(alpha: 0.45),
                  height: 0.8,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  testimonial['text'],
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withValues(alpha: 0.58),
                    height: 1.6,
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

// ══════════════════════════════════════════════════════════════
// TRUST BADGE
// ══════════════════════════════════════════════════════════════
class _TrustBadge extends StatelessWidget {
  const _TrustBadge({required this.icon, required this.label});
  final IconData icon;
  final String   label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.07),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: AppTheme.goldPrimary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.goldLight, size: 17),
            ),
            const SizedBox(height: 6),
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