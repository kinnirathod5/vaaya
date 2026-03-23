import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../shared/animations/fade_animation.dart';
import '../../../../shared/widgets/custom_network_image.dart';

// ============================================================
// 👤 USER DETAIL SCREEN
// Full profile of another user — swipeable photos, compat,
// interests, basic details, send interest + message CTAs
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

  // ── Dummy data ────────────────────────────────────────────
  static const Map<String, dynamic> _profile = {
    'name': 'Priya Rathod',
    'age': 24,
    'city': 'Mumbai',
    'profession': 'Software Engineer',
    'education': 'B.Tech',
    'height': "5'4\"",
    'gotra': 'Rathod',
    'community': 'Banjara',
    'about':
    'Family-oriented and career-driven. Love cooking, travelling, and exploring new cuisines. Looking for a genuine partner who values family.',
    'matchPct': 98,
    'isOnline': true,
    'isVerified': true,
    'isPremium': false,
    'memberSince': 'Jan 2024',
    'lastSeen': 'Active now',
    'photos': [
      'https://images.unsplash.com/photo-1583089892943-e02e52f17d50?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1607746882042-944635dfe10e?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&w=800&q=80',
    ],
    'interests': ['Cooking', 'Travelling', 'Reading', 'Music', 'Fitness'],
    'compatibility': {
      'kundali': 28,
      'lifestyle': 90,
      'values': 95,
      'location': 85,
    },
  };

  // ── State ─────────────────────────────────────────────────
  int _photoIndex = 0;
  bool _interestSent = false;
  bool _isLiked = false;

  late final PageController _photoCtrl;
  late final AnimationController _heartCtrl;
  late final Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _photoCtrl = PageController();
    _heartCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.45), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.45, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _heartCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _photoCtrl.dispose();
    _heartCtrl.dispose();
    super.dispose();
  }

  // ── Handlers ──────────────────────────────────────────────
  void _sendInterest() {
    if (_interestSent) return;
    HapticUtils.heavyImpact();
    setState(() => _interestSent = true);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        '🌸  Interest sent to ${_profile['name']}!',
        style: const TextStyle(
            fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13),
      ),
      backgroundColor: AppTheme.brandPrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
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

              // ── Photo gallery ──────────────────────────
              SliverToBoxAdapter(child: _buildPhotoGallery(photos)),

              // ── Content card ───────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAF8F9),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      const SizedBox(height: 20),

                      FadeAnimation(delayInMs: 0,   child: _buildNameRow()),
                      const SizedBox(height: 16),
                      FadeAnimation(delayInMs: 60,  child: _buildPills()),
                      const SizedBox(height: 20),
                      FadeAnimation(delayInMs: 120, child: _buildCompatibility()),
                      const SizedBox(height: 20),
                      FadeAnimation(delayInMs: 180, child: _buildAbout()),
                      const SizedBox(height: 20),
                      FadeAnimation(delayInMs: 240, child: _buildDetails()),
                      const SizedBox(height: 20),
                      FadeAnimation(delayInMs: 300, child: _buildInterests()),
                      SizedBox(height: 100 + bottomPad),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating back + like
          _buildTopButtons(),

          // Bottom CTA
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomCTA(bottomPad),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // SECTIONS
  // ══════════════════════════════════════════════════════════

  Widget _buildPhotoGallery(List photos) {
    return SizedBox(
      height: 480,
      child: Stack(
        children: [
          // Swipeable photos
          PageView.builder(
            controller: _photoCtrl,
            itemCount: photos.length,
            onPageChanged: (i) => setState(() => _photoIndex = i),
            itemBuilder: (_, i) => CustomNetworkImage(
              imageUrl: photos[i] as String,
              borderRadius: 0,
            ),
          ),

          // Top fade
          Container(
            height: 130,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withValues(alpha: 0.55), Colors.transparent],
              ),
            ),
          ),

          // Bottom fade
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: 0.70), Colors.transparent],
                ),
              ),
            ),
          ),

          // Photo dot indicators
          Positioned(
            top: 58, left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(photos.length, (i) {
                final active = i == _photoIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 20 : 6,
                  height: 4,
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.40),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),

          // Online badge
          if (_profile['isOnline'] as bool)
            Positioned(
              bottom: 54, left: 20,
              child: _PillBadge(
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
                    const SizedBox(width: 5),
                    Text(
                      _profile['lastSeen'] as String,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Photo count
          Positioned(
            bottom: 54, right: 20,
            child: _PillBadge(
              child: Text(
                '${_photoIndex + 1}/${photos.length}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopButtons() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _GlassBtn(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () { HapticUtils.lightImpact(); context.pop(); },
            ),
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
          ],
        ),
      ),
    );
  }

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
                Row(
                  children: [
                    Text(
                      '${_profile['name']}, ${_profile['age']}',
                      style: const TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.brandDark,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                    if (_profile['isVerified'] as bool) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified_rounded,
                          color: Color(0xFF2563EB), size: 18),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 13, color: Colors.grey.shade400),
                    const SizedBox(width: 3),
                    Text(
                      '${_profile['city']} · ${_profile['profession']}',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Match % badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.brandPrimary,
                  AppTheme.brandPrimary.withValues(alpha: 0.75),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.brandPrimary.withValues(alpha: 0.28),
                  blurRadius: 12, offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '${_profile['matchPct']}%',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                const Text(
                  'match',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 9,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPills() {
    final pills = [
      {'icon': Icons.school_outlined,        'text': _profile['education']},
      {'icon': Icons.height_rounded,          'text': _profile['height']},
      {'icon': Icons.diversity_1_rounded,     'text': _profile['gotra']},
      {'icon': Icons.calendar_today_outlined, 'text': 'Since ${_profile['memberSince']}'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8, runSpacing: 8,
        children: pills.map((p) => Container(
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
              Icon(p['icon'] as IconData,
                  size: 13, color: AppTheme.brandPrimary),
              const SizedBox(width: 6),
              Text(p['text'] as String,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.brandDark,
                  )),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildCompatibility() {
    final compat = _profile['compatibility'] as Map<String, dynamic>;
    final items = [
      {'label': 'Kundali',   'val': compat['kundali']  as int, 'max': 36},
      {'label': 'Lifestyle', 'val': compat['lifestyle'] as int, 'max': 100},
      {'label': 'Values',    'val': compat['values']    as int, 'max': 100},
      {'label': 'Location',  'val': compat['location']  as int, 'max': 100},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Compatibility'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.softShadow,
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: items.asMap().entries.map((e) {
                final item = e.value;
                final pct  = (item['val'] as int) / (item['max'] as int);
                final isKundali = item['label'] == 'Kundali';
                Color barColor = pct >= 0.85
                    ? const Color(0xFF16A34A)
                    : pct >= 0.60
                    ? AppTheme.brandPrimary
                    : Colors.orange.shade400;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: e.key < items.length - 1 ? 12 : 0,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 68,
                        child: Text(
                          item['label'] as String,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(barColor),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isKundali
                            ? '${item['val']}/36'
                            : '${item['val']}%',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.brandDark,
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

  Widget _buildAbout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('About'),
          const SizedBox(height: 10),
          Text(
            _profile['about'] as String,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    final w = (MediaQuery.of(context).size.width - 56) / 2;
    final details = [
      {'icon': Icons.cake_rounded,        'label': 'Age',        'value': '${_profile['age']} years'},
      {'icon': Icons.height_rounded,       'label': 'Height',     'value': _profile['height']},
      {'icon': Icons.work_outline_rounded, 'label': 'Profession', 'value': _profile['profession']},
      {'icon': Icons.school_outlined,      'label': 'Education',  'value': _profile['education']},
      {'icon': Icons.location_on_outlined, 'label': 'City',       'value': _profile['city']},
      {'icon': Icons.diversity_1_rounded,  'label': 'Gotra',      'value': _profile['gotra']},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Basic Details'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10, runSpacing: 10,
            children: details.map((d) => SizedBox(
              width: w,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Row(
                  children: [
                    Icon(d['icon'] as IconData,
                        size: 14, color: AppTheme.brandPrimary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d['label'] as String,
                              style: TextStyle(
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
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInterests() {
    final interests = _profile['interests'] as List;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Interests'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: interests.map((i) => Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.brandPrimary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.brandPrimary.withValues(alpha: 0.15),
                ),
              ),
              child: Text(i as String,
                  style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.brandPrimary,
                  )),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCTA(double bottomPad) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + bottomPad),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            border: Border(
                top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              // Message
              GestureDetector(
                onTap: _startChat,
                child: Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.brandPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.brandPrimary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppTheme.brandPrimary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Send Interest
              Expanded(
                child: GestureDetector(
                  onTap: _interestSent ? null : _sendInterest,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _interestSent
                            ? [Colors.grey.shade400, Colors.grey.shade400]
                            : [AppTheme.brandPrimary, const Color(0xFFFF6B84)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _interestSent
                          ? []
                          : [
                        BoxShadow(
                          color: AppTheme.brandPrimary
                              .withValues(alpha: 0.30),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _interestSent
                                ? Icons.check_circle_rounded
                                : Icons.favorite_rounded,
                            color: Colors.white,
                            size: 17,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _interestSent
                                ? 'Interest Sent'
                                : 'Send Interest',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
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


// ── Private helpers ───────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: AppTheme.brandDark,
          letterSpacing: -0.2,
        ));
  }
}

class _PillBadge extends StatelessWidget {
  const _PillBadge({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: child,
    );
  }
}

class _GlassBtn extends StatelessWidget {
  const _GlassBtn({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });
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
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: Icon(icon, color: iconColor ?? Colors.white, size: 18),
      ),
    );
  }
}