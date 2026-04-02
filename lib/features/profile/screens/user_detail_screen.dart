import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/utils/custom_toast.dart';
import '../../../../shared/animations/fade_animation.dart';
import '../../../../shared/widgets/custom_chip.dart';
import '../../../../shared/widgets/custom_network_image.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/guest_lock_widget.dart';
import '../../../../shared/widgets/match_badge.dart';
import '../../../../shared/widgets/premium_lock_overlay.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/premium_icon_button.dart';
import '../../../../shared/widgets/primary_button.dart';

// ============================================================
// 👤 USER DETAIL SCREEN — Redesigned
// Improvements:
//   • Photo gallery — tap zones for prev/next, better dots
//   • Name row — marital status + gotra pills added
//   • Compatibility — animated progress bars with color coding
//   • About — read more/less toggle
//   • Details grid — color-coded icon backgrounds
//   • Bottom CTA — share button added
//   • Top right — 3-dot menu (report/block)
//   • Content card — drag handle + better spacing
//
// TODO: profileRepository.getProfile(uid)
//       interestsProvider.sendInterest(uid)
//       chatProvider.startConversation(uid)
// ============================================================
class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({super.key});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen>
    with SingleTickerProviderStateMixin {

  static const Map<String, dynamic> _profile = {
    'name':         'Priya Rathod',
    'age':          24,
    'city':         'Mumbai',
    'profession':   'Software Engineer',
    'education':    'B.Tech',
    'height':       "5'4\"",
    'gotra':        'Rathod',
    'community':    'Banjara',
    'maritalStatus':'Never Married',
    'familyType':   'Joint Family',
    'diet':         'Vegetarian',
    'about':
    'Family-oriented and career-driven. Love cooking, travelling, and exploring new cuisines. Looking for a genuine partner who values family and traditions. I believe in building a life together with love, respect, and understanding.',
    'matchPct':     98,
    'isOnline':     true,
    'isVerified':   true,
    'isPremium':    false,
    'memberSince':  'Jan 2024',
    'lastSeen':     'Active now',
    'photos': [
      AppAssets.dummyFemale1,
      AppAssets.dummyFemale2,
      AppAssets.dummyFemale3,
    ],
    'interests': ['Cooking', 'Travelling', 'Reading', 'Music', 'Fitness', 'Yoga'],
    'compatibility': {
      'kundali':   28,
      'lifestyle': 90,
      'values':    95,
      'location':  85,
    },
  };

  int  _photoIndex    = 0;
  bool _interestSent  = false;
  bool _isLiked       = false;
  bool _aboutExpanded = false;
  // TODO: replace with auth state provider (Riverpod)
  static const bool _isGuest = false;

  late final PageController      _photoCtrl;
  late final AnimationController _heartCtrl;
  late final Animation<double>   _heartScale;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _photoCtrl = PageController();
    _heartCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.5), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _heartCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _photoCtrl.dispose();
    _heartCtrl.dispose();
    super.dispose();
  }

  void _sendInterest() {
    if (_interestSent) return;
    HapticUtils.heavyImpact();
    setState(() => _interestSent = true);
    CustomToast.interestSent(context, _profile['name'] as String);
  }

  void _toggleLike() {
    HapticUtils.lightImpact();
    setState(() => _isLiked = !_isLiked);
    _heartCtrl.forward(from: 0);
  }

  void _startChat() {
    HapticUtils.mediumImpact();
    context.push('/chat_detail');
  }

  void _showMoreOptions() {
    HapticUtils.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MoreOptionsSheet(name: _profile['name'] as String),
    );
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final photos = _profile['photos'] as List;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0408),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildPhotoGallery(photos)),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.bgScaffold,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.cardRadius)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      const SizedBox(height: 10),
                      Center(
                        child: Container(
                          width: 40, height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      FadeAnimation(delayInMs: 0,   child: _buildNameRow()),
                      const SizedBox(height: 14),
                      FadeAnimation(delayInMs: 50,  child: _buildQuickPills()),
                      const SizedBox(height: 18),
                      FadeAnimation(delayInMs: 100, child: _buildInfoChips()),
                      const SizedBox(height: 20),
                      FadeAnimation(delayInMs: 150, child: _buildCompatibility()),
                      const SizedBox(height: 20),
                      FadeAnimation(delayInMs: 200, child: _buildAbout()),
                      const SizedBox(height: 20),
                      FadeAnimation(delayInMs: 250, child: _buildDetails()),
                      const SizedBox(height: 20),
                      FadeAnimation(delayInMs: 300, child: _buildContactDetails()),
                      const SizedBox(height: 20),
                      FadeAnimation(delayInMs: 350, child: _buildInterests()),
                      SizedBox(height: 110 + bottomPad),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Top buttons
          _buildTopButtons(),

          // Bottom CTA
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomCTA(bottomPad),
          ),

          // Guest lock — blocks detail sections for unauthenticated users
          if (_isGuest) const GuestLockOverlay(),
        ],
      ),
    );
  }

  // ── Photo Gallery ─────────────────────────────────────────
  Widget _buildPhotoGallery(List photos) {
    return SizedBox(
      height: 500,
      child: Stack(
        children: [
          // PageView
          PageView.builder(
            controller: _photoCtrl,
            itemCount: photos.length,
            onPageChanged: (i) => setState(() => _photoIndex = i),
            itemBuilder: (_, i) => CustomNetworkImage(
              imageUrl: photos[i] as String,
              borderRadius: 0,
            ),
          ),

          // Tap zones — left/right to navigate
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (_photoIndex > 0) {
                      HapticUtils.selectionClick();
                      _photoCtrl.previousPage(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                      );
                    }
                  },
                  behavior: HitTestBehavior.translucent,
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (_photoIndex < photos.length - 1) {
                      HapticUtils.selectionClick();
                      _photoCtrl.nextPage(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                      );
                    }
                  },
                  behavior: HitTestBehavior.translucent,
                ),
              ),
            ],
          ),

          // Top gradient
          Container(
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withValues(alpha: 0.60), Colors.transparent],
              ),
            ),
          ),

          // Bottom gradient
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 240,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: 0.75), Colors.transparent],
                ),
              ),
            ),
          ),

          // Photo segment indicators (top)
          Positioned(
            top: 60, left: 16, right: 16,
            child: Row(
              children: List.generate(photos.length, (i) {
                final active = i == _photoIndex;
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 3,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Name / age glass badge (bottom left — above status badge)
          Positioned(
            bottom: 96, left: 20,
            child: GlassContainer(
              variant: GlassVariant.dark,
              blur: 12,
              opacity: 0.38,
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Text(
                '${_profile['name']}, ${_profile['age']}',
                style: const TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 20, fontWeight: FontWeight.w700,
                  color: Colors.white, height: 1.1,
                ),
              ),
            ),
          ),

          // Online badge (bottom left)
          if (_profile['isOnline'] as bool)
            Positioned(
              bottom: 56, left: 20,
              child: _PillBadge(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7, height: 7,
                      decoration: const BoxDecoration(
                        color: AppTheme.onlineDot, shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _profile['lastSeen'] as String,
                      style: const TextStyle(
                        fontFamily: 'Poppins', fontSize: 11,
                        fontWeight: FontWeight.w600, color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Photo counter (bottom right)
          Positioned(
            bottom: 56, right: 20,
            child: _PillBadge(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo_library_outlined,
                      size: 11, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    '${_photoIndex + 1} / ${photos.length}',
                    style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 11,
                      fontWeight: FontWeight.w600, color: Colors.white,
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

  // ── Top buttons ───────────────────────────────────────────
  Widget _buildTopButtons() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _GlassBtn(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () { HapticUtils.lightImpact(); context.pop(); },
            ),
            Row(
              children: [
                // Like
                ScaleTransition(
                  scale: _heartScale,
                  child: _GlassBtn(
                    icon: _isLiked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    iconColor: _isLiked ? AppTheme.brandPrimary : null,
                    onTap: _toggleLike,
                  ),
                ),
                const SizedBox(width: 10),
                // More options
                _GlassBtn(
                  icon: Icons.more_vert_rounded,
                  onTap: _showMoreOptions,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Name row ──────────────────────────────────────────────
  Widget _buildNameRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + verified
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    Text(
                      '${_profile['name']}, ${_profile['age']}',
                      style: const TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 30, fontWeight: FontWeight.w700,
                        color: AppTheme.brandDark,
                        letterSpacing: -0.5, height: 1.1,
                      ),
                    ),
                    if (_profile['isVerified'] as bool)
                      const Icon(Icons.verified_rounded,
                          color: Color(0xFF2563EB), size: 19),
                    if (_profile['isPremium'] as bool)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFC9962A)]),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('VIP', style: TextStyle(
                          fontFamily: 'Poppins', fontSize: 8,
                          fontWeight: FontWeight.w800, color: Colors.white,
                        )),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                // City + profession
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 13, color: Colors.grey.shade400),
                    const SizedBox(width: 3),
                    Text(
                      '${_profile['city']}  ·  ${_profile['profession']}',
                      style: TextStyle(
                        fontFamily: 'Poppins', fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Match % hero badge — MatchBadge.large
          MatchBadge(
            percent: _profile['matchPct'] as int,
            size: BadgeSize.large,
          ),
        ],
      ),
    );
  }

  // ── Quick info pills ──────────────────────────────────────
  Widget _buildQuickPills() {
    final pills = [
      {'icon': Icons.school_outlined,         'text': _profile['education'],     'color': const Color(0xFF6366F1)},
      {'icon': Icons.height_rounded,           'text': _profile['height'],        'color': const Color(0xFF0EA5E9)},
      {'icon': Icons.diversity_1_rounded,      'text': _profile['gotra'],         'color': AppTheme.brandPrimary},
      {'icon': Icons.calendar_today_outlined,  'text': 'Since ${_profile['memberSince']}', 'color': const Color(0xFF10B981)},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8, runSpacing: 8,
        children: pills.map((p) {
          final color = p['color'] as Color;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: AppTheme.softShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(p['icon'] as IconData, size: 12, color: color),
                ),
                const SizedBox(width: 7),
                Text(p['text'] as String, style: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 12,
                  fontWeight: FontWeight.w600, color: AppTheme.brandDark,
                )),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Info chips (marital, diet, family) ────────────────────
  Widget _buildInfoChips() {
    final chips = [
      {'label': _profile['maritalStatus'] as String, 'icon': Icons.ring_volume_outlined},
      {'label': _profile['familyType'] as String,    'icon': Icons.home_outlined},
      {'label': _profile['diet'] as String,           'icon': Icons.restaurant_outlined},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: chips.map((c) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.brandPrimary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppTheme.brandPrimary.withValues(alpha: 0.12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(c['icon'] as IconData,
                    size: 12, color: AppTheme.brandPrimary),
                const SizedBox(width: 5),
                Text(c['label'] as String, style: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 11,
                  fontWeight: FontWeight.w600, color: AppTheme.brandPrimary,
                )),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }

  // ── Compatibility ─────────────────────────────────────────
  Widget _buildCompatibility() {
    final compat = _profile['compatibility'] as Map<String, dynamic>;

    final items = [
      {
        'label': 'Kundali',
        'val': compat['kundali'] as int,
        'max': 36,
        'icon': Icons.auto_awesome_outlined,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'label': 'Lifestyle',
        'val': compat['lifestyle'] as int,
        'max': 100,
        'icon': Icons.spa_outlined,
        'color': const Color(0xFF10B981),
      },
      {
        'label': 'Values',
        'val': compat['values'] as int,
        'max': 100,
        'icon': Icons.favorite_outline_rounded,
        'color': AppTheme.brandPrimary,
      },
      {
        'label': 'Location',
        'val': compat['location'] as int,
        'max': 100,
        'icon': Icons.location_on_outlined,
        'color': const Color(0xFF0EA5E9),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Compatibility',
            subtitle: '${_profile['matchPct']}% overall match',
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.softShadow,
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: items.asMap().entries.map((e) {
                final item  = e.value;
                final pct   = (item['val'] as int) / (item['max'] as int);
                final color = item['color'] as Color;
                final isKundali = item['label'] == 'Kundali';
                final valueText = isKundali
                    ? '${item['val']}/36'
                    : '${item['val']}%';

                return Padding(
                  padding: EdgeInsets.only(bottom: e.key < items.length - 1 ? 14 : 0),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(item['icon'] as IconData,
                            size: 14, color: color),
                      ),
                      const SizedBox(width: 10),
                      // Label
                      SizedBox(
                        width: 60,
                        child: Text(
                          item['label'] as String,
                          style: TextStyle(
                            fontFamily: 'Poppins', fontSize: 12,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Bar
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 7,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Value
                      SizedBox(
                        width: 40,
                        child: Text(
                          valueText,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'Poppins', fontSize: 12,
                            fontWeight: FontWeight.w800, color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── About ─────────────────────────────────────────────────
  Widget _buildAbout() {
    final about = _profile['about'] as String;
    const maxChars = 100;
    final isLong = about.length > maxChars;
    final displayText = (!_aboutExpanded && isLong)
        ? '${about.substring(0, maxChars)}...'
        : about;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'About', padding: EdgeInsets.zero),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayText,
                  style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 13,
                    color: Colors.grey.shade600, height: 1.7,
                  ),
                ),
                if (isLong) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      HapticUtils.selectionClick();
                      setState(() => _aboutExpanded = !_aboutExpanded);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _aboutExpanded ? 'Read less' : 'Read more',
                          style: const TextStyle(
                            fontFamily: 'Poppins', fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.brandPrimary,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          _aboutExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 16, color: AppTheme.brandPrimary,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Basic details ─────────────────────────────────────────
  Widget _buildDetails() {
    final w = (MediaQuery.of(context).size.width - 56) / 2;
    final details = [
      {'icon': Icons.cake_rounded,         'label': 'Age',        'value': '${_profile['age']} years', 'color': const Color(0xFFEC4899)},
      {'icon': Icons.height_rounded,        'label': 'Height',     'value': _profile['height'],         'color': const Color(0xFF0EA5E9)},
      {'icon': Icons.work_outline_rounded,  'label': 'Profession', 'value': _profile['profession'],     'color': const Color(0xFF8B5CF6)},
      {'icon': Icons.school_outlined,       'label': 'Education',  'value': _profile['education'],      'color': const Color(0xFF6366F1)},
      {'icon': Icons.location_on_outlined,  'label': 'City',       'value': _profile['city'],           'color': const Color(0xFF10B981)},
      {'icon': Icons.diversity_1_rounded,   'label': 'Gotra',      'value': _profile['gotra'],          'color': AppTheme.brandPrimary},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Basic Details', padding: EdgeInsets.zero),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10, runSpacing: 10,
            children: details.map((d) {
              final color = d['color'] as Color;
              return SizedBox(
                width: w,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(d['icon'] as IconData,
                            size: 15, color: color),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d['label'] as String, style: TextStyle(
                              fontFamily: 'Poppins', fontSize: 10,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w500,
                            )),
                            Text(d['value'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Poppins', fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.brandDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Contact Details (Premium locked) ─────────────────────
  Widget _buildContactDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Contact Details', padding: EdgeInsets.zero),
          const SizedBox(height: 12),
          Stack(
            children: [
              // Placeholder rows (blurred by overlay)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  children: [
                    Row(children: [
                      Container(width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.brandPrimary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.phone_outlined,
                            size: 15, color: AppTheme.brandPrimary),
                      ),
                      const SizedBox(width: 12),
                      Container(height: 12, width: 140,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          )),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Container(width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0EA5E9).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.mail_outline_rounded,
                            size: 15, color: Color(0xFF0EA5E9)),
                      ),
                      const SizedBox(width: 12),
                      Container(height: 12, width: 170,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          )),
                    ]),
                  ],
                ),
              ),
              // Premium lock overlay
              Positioned.fill(
                child: PremiumLockOverlay(
                  lockType: LockType.contact,
                  title: 'Unlock Contact Details',
                  subtitle: 'Upgrade to Premium to see phone & email',
                  borderRadius: 16,
                  blurSigma: 4,
                  buttonLabel: 'Upgrade to Premium',
                  onUnlockTap: () {
                    HapticUtils.mediumImpact();
                    context.push('/premium');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Interests ─────────────────────────────────────────────
  Widget _buildInterests() {
    final interests = _profile['interests'] as List;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Interests & Hobbies', padding: EdgeInsets.zero),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: interests.map((i) => CustomChip(
              label: i as String,
              variant: ChipVariant.subtle,
              isSelected: true,
            )).toList(),
          ),
        ],
      ),
    );
  }

  // ── Bottom CTA ────────────────────────────────────────────
  Widget _buildBottomCTA(double bottomPad) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPad),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20, offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Share
              PremiumIconButton(
                icon: Icons.share_outlined,
                shape: ButtonShape.rounded,
                padding: 14.0,
                onTap: () => HapticUtils.lightImpact(),
              ),
              const SizedBox(width: 10),

              // Message
              PremiumIconButton(
                icon: Icons.chat_bubble_outline_rounded,
                shape: ButtonShape.rounded,
                padding: 14.0,
                onTap: _startChat,
              ),
              const SizedBox(width: 12),

              // Send Interest — primary CTA
              Expanded(
                child: PrimaryButton(
                  text: _interestSent ? 'Interest Sent' : 'Send Interest',
                  icon: _interestSent
                      ? Icons.check_circle_rounded
                      : Icons.favorite_rounded,
                  isEnabled: !_interestSent,
                  variant: _interestSent
                      ? ButtonVariant.success
                      : ButtonVariant.filled,
                  height: 52,
                  onTap: _interestSent ? null : _sendInterest,
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
// PRIVATE HELPERS
// ══════════════════════════════════════════════════════════════

// _SectionHeader removed — replaced by shared SectionHeader widget

class _PillBadge extends StatelessWidget {
  const _PillBadge({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: child,
    );
  }
}

class _GlassBtn extends StatelessWidget {
  const _GlassBtn({required this.icon, required this.onTap, this.iconColor});
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.38),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Icon(icon, color: iconColor ?? Colors.white, size: 18),
      ),
    );
  }
}

// _CTAIconBtn removed — replaced by shared PremiumIconButton widget

// More options bottom sheet
class _MoreOptionsSheet extends StatelessWidget {
  const _MoreOptionsSheet({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.sheetRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(name, style: const TextStyle(
              fontFamily: 'Poppins', fontSize: 15,
              fontWeight: FontWeight.w800, color: AppTheme.brandDark,
            )),
          ),
          const SizedBox(height: 12),
          _OptionTile(
            icon: Icons.share_outlined,
            label: 'Share Profile',
            color: AppTheme.brandDark,
            onTap: () { HapticUtils.lightImpact(); Navigator.pop(context); },
          ),
          _OptionTile(
            icon: Icons.block_rounded,
            label: 'Block $name',
            color: Colors.orange.shade700,
            onTap: () { HapticUtils.mediumImpact(); Navigator.pop(context); },
          ),
          _OptionTile(
            icon: Icons.flag_outlined,
            label: 'Report Profile',
            color: Colors.red.shade500,
            onTap: () { HapticUtils.heavyImpact(); Navigator.pop(context); },
            showDivider: false,
          ),
          SizedBox(height: 16 + MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon, required this.label,
    required this.color, required this.onTap,
    this.showDivider = true,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          title: Text(label, style: TextStyle(
            fontFamily: 'Poppins', fontSize: 14,
            fontWeight: FontWeight.w600, color: color,
          )),
          trailing: Icon(Icons.arrow_forward_ios_rounded,
              size: 13, color: Colors.grey.shade300),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1, color: Colors.grey.shade100),
          ),
      ],
    );
  }
}