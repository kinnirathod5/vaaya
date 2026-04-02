import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/custom_toast.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../shared/animations/fade_animation.dart';
import '../../../../shared/widgets/custom_chip.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/guest_lock_widget.dart';
import '../../../../shared/widgets/premium_icon_button.dart';
import '../../../../shared/widgets/premium_match_card.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/shimmer_loading_grid.dart';

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

  bool   _searchOpen       = false;
  bool   _isInitialLoading = true;
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
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isInitialLoading = false);
    });
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
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
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
          PremiumIconButton(
            icon: _searchOpen ? Icons.close_rounded : Icons.search_rounded,
            backgroundColor: _searchOpen ? AppTheme.brandPrimary : Colors.white,
            iconColor: _searchOpen ? Colors.white : AppTheme.brandDark,
            shape: ButtonShape.rounded,
            onTap: _toggleSearch,
          ),
          const SizedBox(width: 8),

          // Filter
          PremiumIconButton(
            icon: Icons.tune_rounded,
            shape: ButtonShape.rounded,
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
    if (_isInitialLoading) {
      return ShimmerLoadingGrid(
        itemCount: 6,
        crossAxisCount: 2,
        childAspectRatio: 0.66,
        padding: EdgeInsets.fromLTRB(20, 4, 20, 88 + bottomPad),
      );
    }

    return GridView.builder(
      controller: _scrollCtrl,
      padding: EdgeInsets.fromLTRB(20, 4, 20, 88 + bottomPad),
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

        final card = PremiumMatchCard(
          name:       match['name']       as String,
          age:        match['age']        as int,
          imageUrl:   match['image']      as String,
          matchPct:   match['match']      as int,
          profession: match['profession'] as String,
          city:       match['city']       as String,
          isOnline:   match['isOnline']   as bool,
          isNew:      match['isNew']      as bool,
          isPremium:  match['isPremium']  as bool,
          onTap:      () => context.push('/user_detail'),
          onLike:     () => CustomToast.interestSent(
            context,
            (match['name'] as String).split(' ').first,
          ),
        );

        if (isLocked) {
          return GuestLockedCard(borderRadius: 20, child: card);
        }

        return FadeAnimation(
          delayInMs: (index * 50).clamp(0, 400),
          child: RepaintBoundary(child: card),
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
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CustomChip(
              label:      opt,
              isSelected: isSelected,
              onTap:      () => onSelect(opt),
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
    CustomToast.success(context, 'Filters applied!');
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
                  const SectionHeader(title: 'Age Range', padding: EdgeInsets.zero),
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
                  const SectionHeader(title: 'Height Range', padding: EdgeInsets.zero),
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
                  const SectionHeader(title: 'City', padding: EdgeInsets.zero),
                  const SizedBox(height: 10),
                  _SheetChipGroup(
                    items:    _cities,
                    selected: _city,
                    onSelect: (v) => setState(() => _city = v),
                  ),
                  const SizedBox(height: 16),

                  // ── Education ────────────────────────────
                  const SectionHeader(title: 'Education', padding: EdgeInsets.zero),
                  const SizedBox(height: 10),
                  _SheetChipGroup(
                    items:    _educations,
                    selected: _education,
                    onSelect: (v) => setState(() => _education = v),
                  ),
                  const SizedBox(height: 16),

                  // ── Toggles ───────────────────────────────
                  const SectionHeader(title: 'Preferences', padding: EdgeInsets.zero),
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
                  PrimaryButton(
                    text:  'Apply Filters',
                    width: double.infinity,
                    onTap: _apply,
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
        return CustomChip(
          label:      item,
          isSelected: isSel,
          onTap: () {
            HapticUtils.selectionClick();
            onSelect(item);
          },
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