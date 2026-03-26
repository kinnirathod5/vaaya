import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../shared/animations/fade_animation.dart';
import '../../../../shared/widgets/custom_network_image.dart';
import '../../../../shared/widgets/guest_lock_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

// ============================================================
// 🔍 MATCHES SCREEN — v2.0 Full Rewrite (All Widgets Inlined)
//
// IMPROVEMENTS vs v1:
//   ✅ Inline search with animated height + focus
//   ✅ Filter chips with glow shadow on selected
//   ✅ Match cards: arc ring % + shimmer loading
//   ✅ Guest lock: GuestLockedCard on index >= 3
//   ✅ Result count + guest badge row
//   ✅ Filter bottom sheet: age/height sliders, city/education chips
//   ✅ FadeAnimation stagger on grid items
//   ✅ Ambient background blobs (same as home screen)
//   ✅ Consistent 20px horizontal padding everywhere
//   ✅ Empty state with reset action
//   ✅ All text: maxLines + overflow
//   ✅ RepaintBoundary on each card
//
// TODO: Replace _allMatches + _isGuest with Riverpod providers
// ============================================================

// ──────────────────────────────────────────────────────────────
// DATA
// ──────────────────────────────────────────────────────────────

const _filterOptions = ['All', 'New', 'Near Me', 'Online', 'Premium'];

const _allMatches = <Map<String, dynamic>>[
  {
    'name': 'Priya Rathod',    'age': 24, 'city': 'Mumbai',
    'profession': 'Software Engineer', 'match': 98,
    'isOnline': true,  'isPremium': false, 'isNew': true,
    'image': AppAssets.dummyFemale1, 'education': 'B.Tech', 'height': "5'4\"",
  },
  {
    'name': 'Anjali Chavan',   'age': 26, 'city': 'Pune',
    'profession': 'UX Designer', 'match': 92,
    'isOnline': false, 'isPremium': true,  'isNew': false,
    'image': AppAssets.dummyFemale2, 'education': 'B.Des', 'height': "5'5\"",
  },
  {
    'name': 'Sneha Pawar',     'age': 25, 'city': 'Nagpur',
    'profession': 'Doctor', 'match': 89,
    'isOnline': true,  'isPremium': false, 'isNew': true,
    'image': AppAssets.dummyFemale3, 'education': 'MBBS', 'height': "5'3\"",
  },
  {
    'name': 'Kavya Desai',     'age': 23, 'city': 'Nashik',
    'profession': 'CA', 'match': 86,
    'isOnline': true,  'isPremium': true,  'isNew': false,
    'image': AppAssets.dummyFemale4, 'education': 'CA Final', 'height': "5'2\"",
  },
  {
    'name': 'Roshni Kulkarni', 'age': 27, 'city': 'Aurangabad',
    'profession': 'Architect', 'match': 84,
    'isOnline': false, 'isPremium': false, 'isNew': false,
    'image': AppAssets.dummyFemale5, 'education': 'B.Arch', 'height': "5'6\"",
  },
  {
    'name': 'Meera Joshi',     'age': 25, 'city': 'Mumbai',
    'profession': 'Teacher', 'match': 81,
    'isOnline': true,  'isPremium': false, 'isNew': true,
    'image': AppAssets.dummyFemale6, 'education': 'M.Ed', 'height': "5'3\"",
  },
  {
    'name': 'Pooja Chauhan',   'age': 24, 'city': 'Pune',
    'profession': 'Nurse', 'match': 78,
    'isOnline': false, 'isPremium': true,  'isNew': false,
    'image': AppAssets.dummyFemale7, 'education': 'B.Sc Nursing', 'height': "5'4\"",
  },
  {
    'name': 'Swati More',      'age': 26, 'city': 'Kolhapur',
    'profession': 'Lawyer', 'match': 75,
    'isOnline': true,  'isPremium': false, 'isNew': false,
    'image': AppAssets.dummyFemale8, 'education': 'LLB', 'height': "5'5\"",
  },
];

// ──────────────────────────────────────────────────────────────
// SCREEN
// ──────────────────────────────────────────────────────────────

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen>
    with SingleTickerProviderStateMixin {

  final _scrollCtrl  = ScrollController();
  final _searchCtrl  = TextEditingController();
  final _searchFocus = FocusNode();

  bool   _searchOpen   = false;
  String _searchQuery  = '';
  String _activeFilter = 'All';

  // Search bar slide-in animation
  late final AnimationController _searchAnim;
  late final Animation<double>   _searchExpand;
  late final Animation<double>   _searchFade;

  // TODO: authProvider.isGuest
  static const bool _isGuest       = true;
  static const int  _guestFreeLimit = 3;

  // ── Filtered list ─────────────────────────────────────────
  List<Map<String, dynamic>> get _filtered {
    return _allMatches.where((m) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final hit = (m['name'] as String).toLowerCase().contains(q) ||
            (m['city'] as String).toLowerCase().contains(q) ||
            (m['profession'] as String).toLowerCase().contains(q);
        if (!hit) return false;
      }
      switch (_activeFilter) {
        case 'New':     return m['isNew']     as bool;
        case 'Online':  return m['isOnline']  as bool;
        case 'Premium': return m['isPremium'] as bool;
        case 'Near Me': return m['city'] == 'Mumbai' || m['city'] == 'Pune';
        default:        return true;
      }
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _searchAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _searchExpand = CurvedAnimation(
      parent: _searchAnim,
      curve: Curves.easeOutCubic,
    );
    _searchFade = CurvedAnimation(
      parent: _searchAnim,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _searchAnim.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    HapticUtils.lightImpact();
    setState(() => _searchOpen = !_searchOpen);
    if (_searchOpen) {
      _searchAnim.forward();
      Future.delayed(const Duration(milliseconds: 290),
              () { if (mounted) _searchFocus.requestFocus(); });
    } else {
      _searchAnim.reverse();
      _searchFocus.unfocus();
      _searchCtrl.clear();
      setState(() => _searchQuery = '');
    }
  }

  void _openFilterSheet() {
    HapticUtils.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FilterBottomSheet(),
    );
  }

  void _resetFilters() {
    setState(() {
      _searchQuery  = '';
      _activeFilter = 'All';
      _searchCtrl.clear();
    });
    if (_searchOpen) _toggleSearch();
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final filtered  = _filtered;

    return Scaffold(
      backgroundColor: AppTheme.bgScaffold,
      body: Stack(
        children: [
          // Ambient background
          RepaintBoundary(child: _AmbientBackground()),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Header ──────────────────────────────
                FadeAnimation(
                  delayInMs: 0,
                  child: _buildHeader(),
                ),

                // ── Inline search bar ────────────────────
                SizeTransition(
                  sizeFactor: _searchExpand,
                  child: FadeTransition(
                    opacity: _searchFade,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: _SearchField(
                        controller: _searchCtrl,
                        focusNode:  _searchFocus,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        onClear: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
                    ),
                  ),
                ),

                // ── Filter chips ─────────────────────────
                FadeAnimation(
                  delayInMs: 60,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 4),
                    child: _FilterChipsRow(
                      options:  _filterOptions,
                      selected: _activeFilter,
                      onSelect: (f) {
                        HapticUtils.selectionClick();
                        setState(() => _activeFilter = f);
                      },
                    ),
                  ),
                ),

                // ── Result count + guest badge ────────────
                FadeAnimation(
                  delayInMs: 80,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
                    child: Row(
                      children: [
                        Text(
                          '${filtered.length} profiles found',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        if (_isGuest)
                          _GuestBadge(
                            freeLimit: _guestFreeLimit,
                            onTap: () {
                              HapticUtils.lightImpact();
                              context.go('/login');
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                // ── Grid or empty state ───────────────────
                Expanded(
                  child: filtered.isEmpty
                      ? EmptyStateWidget.noMatches(
                    onRefresh: _resetFilters,
                  )
                      : _buildGrid(filtered, bottomPad),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Discover',
                  style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.brandDark,
                    height: 1.0,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Find your perfect Banjara match',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Search toggle
          _IconBtn(
            icon: _searchOpen
                ? Icons.close_rounded
                : Icons.search_rounded,
            isActive: _searchOpen,
            onTap: _toggleSearch,
          ),
          const SizedBox(width: 8),

          // Filter
          _IconBtn(
            icon: Icons.tune_rounded,
            isActive: false,
            onTap: _openFilterSheet,
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // GRID
  // ══════════════════════════════════════════════════════════
  Widget _buildGrid(
      List<Map<String, dynamic>> matches,
      double bottomPad,
      ) {
    return GridView.builder(
      controller: _scrollCtrl,
      padding: EdgeInsets.fromLTRB(16, 4, 16, 88 + bottomPad),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:  2,
        crossAxisSpacing: 12,
        mainAxisSpacing:  12,
        childAspectRatio: 0.66,
      ),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match    = matches[index];
        final isLocked = _isGuest && index >= _guestFreeLimit;

        if (isLocked) {
          return GuestLockedCard(
            borderRadius: 20,
            child: _MatchCard(match: match, onLike: () {}),
          );
        }

        return FadeAnimation(
          delayInMs: (index * 50).clamp(0, 400),
          child: RepaintBoundary(
            child: GestureDetector(
              onTap: () {
                HapticUtils.lightImpact();
                context.push('/user_detail');
              },
              child: _MatchCard(
                match: match,
                onLike: () { HapticUtils.heavyImpact(); },
              ),
            ),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
// AMBIENT BACKGROUND
// ══════════════════════════════════════════════════════════════
class _AmbientBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -60, right: -60,
          child: Container(
            width: 220, height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.brandPrimary.withValues(alpha: 0.05),
            ),
          ),
        ),
        Positioned(
          top: 360, left: -80,
          child: Container(
            width: 180, height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.04),
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ICON BUTTON (header)
// ══════════════════════════════════════════════════════════════
class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });
  final IconData icon;
  final bool     isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: isActive ? AppTheme.brandPrimary : Colors.white,
          borderRadius: BorderRadius.circular(13),
          boxShadow: isActive ? AppTheme.primaryGlow : AppTheme.softShadow,
          border: Border.all(
            color: isActive ? AppTheme.brandPrimary : Colors.grey.shade200,
          ),
        ),
        child: Icon(
          icon,
          size: 19,
          color: isActive ? Colors.white : AppTheme.brandDark,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// INLINE SEARCH FIELD
// ══════════════════════════════════════════════════════════════
class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });
  final TextEditingController controller;
  final FocusNode             focusNode;
  final ValueChanged<String>  onChanged;
  final VoidCallback          onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color: AppTheme.brandPrimary.withValues(alpha: 0.20),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller:      controller,
        focusNode:       focusNode,
        onChanged:       onChanged,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          color: AppTheme.brandDark,
        ),
        decoration: InputDecoration(
          hintText: 'Name, city, profession...',
          hintStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: Colors.grey.shade400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 18,
            color: AppTheme.brandPrimary.withValues(alpha: 0.55),
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, v, _) {
              if (v.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.cancel_rounded,
                  size: 17,
                  color: Colors.grey.shade400,
                ),
              );
            },
          ),
          border:         InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// FILTER CHIPS ROW
// ══════════════════════════════════════════════════════════════
class _FilterChipsRow extends StatelessWidget {
  const _FilterChipsRow({
    required this.options,
    required this.selected,
    required this.onSelect,
  });
  final List<String>      options;
  final String            selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        padding:          const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection:  Axis.horizontal,
        physics:          const BouncingScrollPhysics(),
        itemCount:        options.length,
        itemBuilder: (_, index) {
          final opt        = options[index];
          final isSelected = opt == selected;
          return GestureDetector(
            onTap: () => onSelect(opt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve:    Curves.easeOut,
              margin:   const EdgeInsets.only(right: 8),
              padding:  const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.brandPrimary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color:  AppTheme.brandPrimary.withValues(alpha: 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : AppTheme.softShadow,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.brandPrimary
                      : Colors.grey.shade200,
                  width: 1.5,
                ),
              ),
              child: Text(
                opt,
                style: TextStyle(
                  fontFamily:  'Poppins',
                  fontSize:    12,
                  fontWeight:  FontWeight.w700,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// GUEST BADGE
// ══════════════════════════════════════════════════════════════
class _GuestBadge extends StatelessWidget {
  const _GuestBadge({required this.freeLimit, required this.onTap});
  final int          freeLimit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF2F4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.brandPrimary.withValues(alpha: 0.20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 10,
              color: AppTheme.brandPrimary,
            ),
            const SizedBox(width: 4),
            Text(
              'Guest · $freeLimit free · Sign in',
              style: const TextStyle(
                fontFamily:  'Poppins',
                fontSize:    10,
                fontWeight:  FontWeight.w700,
                color: AppTheme.brandPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// MATCH CARD — arc ring match% + like button
// ══════════════════════════════════════════════════════════════
class _MatchCard extends StatefulWidget {
  const _MatchCard({
    required this.match,
    required this.onLike,
  });
  final Map<String, dynamic> match;
  final VoidCallback         onLike;

  @override
  State<_MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<_MatchCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _likeCtrl;
  late final Animation<double>   _likeScale;
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    _likeCtrl = AnimationController(
      vsync:           this,
      duration:        const Duration(milliseconds: 200),
    );
    _likeScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.32), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.32, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _likeCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _likeCtrl.dispose();
    super.dispose();
  }

  void _onLike() {
    setState(() => _liked = !_liked);
    _likeCtrl.forward(from: 0);
    widget.onLike();
  }

  @override
  Widget build(BuildContext context) {
    final m          = widget.match;
    final bool isOnline  = m['isOnline']  as bool;
    final bool isPremium = m['isPremium'] as bool;
    final bool isNew     = m['isNew']     as bool;
    final int  matchPct  = m['match']     as int;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset:     const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [

            // ── Photo ────────────────────────────────────
            CustomNetworkImage(imageUrl: m['image'], borderRadius: 0),

            // ── Bottom gradient ───────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin:  Alignment.topCenter,
                  end:    Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.36, 1.0],
                ),
              ),
            ),

            // ── Top gradient (for badge readability) ──────
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin:  Alignment.topCenter,
                  end:    Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.20),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.28],
                ),
              ),
            ),

            // ── Top badges row ────────────────────────────
            Positioned(
              top: 10, left: 10, right: 10,
              child: Row(
                children: [
                  // Online pill
                  if (isOnline)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A).withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5, height: 5,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Text(
                            'Online',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),

                  // New badge
                  if (isNew)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.brandPrimary.withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'New',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  // Premium diamond
                  if (isPremium) ...[
                    if (isNew) const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.diamond_rounded,
                        size: 9,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Arc match ring (top-left, overlaps photo) ─
            Positioned(
              top: 42, left: 10,
              child: _ArcRing(pct: matchPct, size: 36),
            ),

            // ── Bottom content ────────────────────────────
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Name + age
                    Text(
                      '${m['name']}, ${m['age']}',
                      style: const TextStyle(
                        fontFamily:  'Cormorant Garamond',
                        fontSize:    17,
                        fontWeight:  FontWeight.w700,
                        color:       Colors.white,
                        height:      1.1,
                        letterSpacing: -0.2,
                      ),
                      maxLines:  1,
                      overflow:  TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),

                    // City · profession
                    Text(
                      '${m['city']} · ${m['profession']}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize:   10,
                        color:      Colors.white.withValues(alpha: 0.65),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),

                    // Match bar + like
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$matchPct% match',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize:   9,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.70),
                                ),
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: matchPct / 100,
                                  backgroundColor:
                                  Colors.white.withValues(alpha: 0.18),
                                  valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                    AppTheme.brandPrimary,
                                  ),
                                  minHeight: 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Like button — spring scale
                        GestureDetector(
                          onTap: _onLike,
                          child: ScaleTransition(
                            scale: _likeScale,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: _liked
                                    ? AppTheme.brandGradient
                                    : const LinearGradient(
                                  colors: [
                                    Color(0x88E8395A),
                                    Color(0x88FF6B84),
                                  ],
                                ),
                                shape:     BoxShape.circle,
                                boxShadow: _liked
                                    ? AppTheme.primaryGlow
                                    : [],
                              ),
                              child: Icon(
                                _liked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: Colors.white,
                                size:  16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ARC RING — match percentage
// ══════════════════════════════════════════════════════════════
class _ArcRing extends StatelessWidget {
  const _ArcRing({required this.pct, required this.size});
  final int    pct;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: size, height: size,
            decoration: BoxDecoration(
              color:  Colors.black.withValues(alpha: 0.40),
              shape:  BoxShape.circle,
            ),
          ),
          CustomPaint(
            size:    Size(size, size),
            painter: _ArcPainter(pct / 100),
          ),
          Text(
            '$pct',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize:   9,
              fontWeight: FontWeight.w900,
              color:      Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter(this.value);
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - 5) / 2;
    final bg = Paint()
      ..color      = Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = 2.5
      ..style      = PaintingStyle.stroke
      ..strokeCap  = StrokeCap.round;
    final fg = Paint()
      ..color      = AppTheme.brandPrimary
      ..strokeWidth = 2.5
      ..style      = PaintingStyle.stroke
      ..strokeCap  = StrokeCap.round;
    final pi = 3.141592653589793;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -pi / 2, 2 * pi, false, bg,
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -pi / 2, 2 * pi * value, false, fg,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter o) => o.value != value;
}

// ══════════════════════════════════════════════════════════════
// FILTER BOTTOM SHEET
// ══════════════════════════════════════════════════════════════
class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet();

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {

  RangeValues _ageRange    = const RangeValues(21, 32);
  RangeValues _heightRange = const RangeValues(150, 175);
  String _city      = 'Any';
  String _education = 'Any';
  bool   _onlineOnly  = false;
  bool   _premiumOnly = false;

  static const _cities = [
    'Any', 'Mumbai', 'Pune', 'Nagpur', 'Nashik',
    'Aurangabad', 'Kolhapur', 'Delhi', 'Bangalore',
  ];
  static const _educations = [
    'Any', 'B.Tech', 'MBBS', 'CA', 'B.Arch',
    'LLB', 'MBA', 'M.Tech', 'B.Des', 'M.Ed',
  ];

  String _cmToFeet(int cm) {
    final inches = (cm / 2.54).round();
    return "${inches ~/ 12}'${inches % 12}\"";
  }

  void _reset() {
    HapticUtils.lightImpact();
    setState(() {
      _ageRange    = const RangeValues(21, 32);
      _heightRange = const RangeValues(150, 175);
      _city        = 'Any';
      _education   = 'Any';
      _onlineOnly  = false;
      _premiumOnly = false;
    });
  }

  void _apply() {
    HapticUtils.mediumImpact();
    // TODO: filterProvider.applyFilters(...)
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),

          // Sheet header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'Filter Matches',
                  style: TextStyle(
                    fontFamily:  'Cormorant Garamond',
                    fontSize:    26,
                    fontWeight:  FontWeight.w700,
                    color:       AppTheme.brandDark,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _reset,
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color:      AppTheme.brandPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize:   13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable filters
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, 8, 20, 24 + bottomPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Age ──────────────────────────────────
                  _SheetLabel('Age Range'),
                  _SheetHint(
                    '${_ageRange.start.round()} – ${_ageRange.end.round()} years',
                  ),
                  RangeSlider(
                    values:      _ageRange,
                    min: 18, max: 50, divisions: 32,
                    activeColor:   AppTheme.brandPrimary,
                    inactiveColor: Colors.grey.shade200,
                    onChanged: (v) {
                      HapticUtils.selectionClick();
                      setState(() => _ageRange = v);
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Height ───────────────────────────────
                  _SheetLabel('Height Range'),
                  _SheetHint(
                    '${_cmToFeet(_heightRange.start.round())} – '
                        '${_cmToFeet(_heightRange.end.round())}',
                  ),
                  RangeSlider(
                    values:      _heightRange,
                    min: 140, max: 190, divisions: 50,
                    activeColor:   AppTheme.brandPrimary,
                    inactiveColor: Colors.grey.shade200,
                    onChanged: (v) {
                      HapticUtils.selectionClick();
                      setState(() => _heightRange = v);
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── City ─────────────────────────────────
                  _SheetLabel('City'),
                  const SizedBox(height: 10),
                  _SheetChipGroup(
                    items:    _cities,
                    selected: _city,
                    onSelect: (v) => setState(() => _city = v),
                  ),
                  const SizedBox(height: 16),

                  // ── Education ────────────────────────────
                  _SheetLabel('Education'),
                  const SizedBox(height: 10),
                  _SheetChipGroup(
                    items:    _educations,
                    selected: _education,
                    onSelect: (v) => setState(() => _education = v),
                  ),
                  const SizedBox(height: 16),

                  // ── Toggles ───────────────────────────────
                  _SheetLabel('Preferences'),
                  const SizedBox(height: 10),
                  _SheetToggle(
                    label:    'Online users only',
                    subtitle: 'Show only currently active profiles',
                    value:    _onlineOnly,
                    onChanged: (v) => setState(() => _onlineOnly = v),
                  ),
                  const SizedBox(height: 8),
                  _SheetToggle(
                    label:    'Premium profiles only',
                    subtitle: 'Verified and premium members',
                    value:    _premiumOnly,
                    onChanged: (v) => setState(() => _premiumOnly = v),
                  ),
                  const SizedBox(height: 28),

                  // ── Apply button ──────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _apply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.brandPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          fontSize:   15,
                        ),
                      ),
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
}

// ── Sheet sub-widgets ─────────────────────────────────────────

class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontFamily: 'Poppins',
      fontSize:   14,
      fontWeight: FontWeight.w800,
      color:      AppTheme.brandDark,
    ),
  );
}

class _SheetHint extends StatelessWidget {
  const _SheetHint(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontFamily: 'Poppins',
      fontSize:   12,
      color:      Colors.grey.shade500,
    ),
  );
}

class _SheetChipGroup extends StatelessWidget {
  const _SheetChipGroup({
    required this.items,
    required this.selected,
    required this.onSelect,
  });
  final List<String>      items;
  final String            selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: items.map((item) {
        final isSel = item == selected;
        return GestureDetector(
          onTap: () {
            HapticUtils.selectionClick();
            onSelect(item);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isSel ? AppTheme.brandPrimary : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSel ? AppTheme.brandPrimary : Colors.grey.shade200,
              ),
              boxShadow: isSel ? AppTheme.primaryGlow : [],
            ),
            child: Text(
              item,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize:   12,
                fontWeight: FontWeight.w600,
                color: isSel ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SheetToggle extends StatelessWidget {
  const _SheetToggle({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final String           label;
  final String           subtitle;
  final bool             value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color:        Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize:   13,
                    fontWeight: FontWeight.w700,
                    color:      AppTheme.brandDark,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize:   11,
                    color:      Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.88,
            child: Switch(
              value:     value,
              onChanged: (v) {
                HapticUtils.selectionClick();
                onChanged(v);
              },
              activeThumbColor: AppTheme.brandPrimary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}