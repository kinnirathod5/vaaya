import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../shared/animations/fade_animation.dart';
import '../../../../shared/widgets/guest_lock_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

import '../widgets/matches_filter_chips.dart';
import '../widgets/matches_grid.dart';
import '../widgets/search_filter_bottom_sheet.dart';

// ============================================================
// 🔍 MATCHES SCREEN
// Compact header — search expands inline on tap.
// Single filter icon top-right opens bottom sheet.
// Grid gets maximum vertical space.
//
// TODO: Replace with matchesProvider + authProvider (Riverpod)
// ============================================================
class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen>
    with SingleTickerProviderStateMixin {

  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  // Search bar visibility
  bool _searchOpen = false;
  String _searchQuery = '';
  String _selectedFilter = 'All';

  // Animated height for search bar
  late final AnimationController _searchAnim;
  late final Animation<double> _searchHeight;
  late final Animation<double> _searchOpacity;

  // TODO: authProvider.isGuest
  static const bool _isGuest = true;
  static const int _guestFreeLimit = 3;

  static const List<String> _filterOptions = [
    'All', 'New', 'Near Me', 'Online', 'Premium',
  ];

  // ── Dummy data ────────────────────────────────────────────
  static const List<Map<String, dynamic>> _allMatches = [
    {
      'name': 'Priya Rathod',    'age': 24, 'city': 'Mumbai',
      'profession': 'Software Engineer', 'match': 98,
      'isOnline': true,  'isPremium': false, 'isNew': true,
      'image': AppAssets.dummyFemale1,
      'education': 'B.Tech', 'height': "5'4\"",
    },
    {
      'name': 'Anjali Chavan',   'age': 26, 'city': 'Pune',
      'profession': 'UX Designer', 'match': 92,
      'isOnline': false, 'isPremium': true,  'isNew': false,
      'image': AppAssets.dummyFemale2,
      'education': 'B.Des', 'height': "5'5\"",
    },
    {
      'name': 'Sneha Pawar',     'age': 25, 'city': 'Nagpur',
      'profession': 'Doctor', 'match': 89,
      'isOnline': true,  'isPremium': false, 'isNew': true,
      'image': AppAssets.dummyFemale3,
      'education': 'MBBS', 'height': "5'3\"",
    },
    {
      'name': 'Kavya Desai',     'age': 23, 'city': 'Nashik',
      'profession': 'CA', 'match': 86,
      'isOnline': true,  'isPremium': true,  'isNew': false,
      'image': AppAssets.dummyFemale4,
      'education': 'CA Final', 'height': "5'2\"",
    },
    {
      'name': 'Roshni Kulkarni', 'age': 27, 'city': 'Aurangabad',
      'profession': 'Architect', 'match': 84,
      'isOnline': false, 'isPremium': false, 'isNew': false,
      'image': AppAssets.dummyFemale5,
      'education': 'B.Arch', 'height': "5'6\"",
    },
    {
      'name': 'Meera Joshi',     'age': 25, 'city': 'Mumbai',
      'profession': 'Teacher', 'match': 81,
      'isOnline': true,  'isPremium': false, 'isNew': true,
      'image': AppAssets.dummyFemale6,
      'education': 'M.Ed', 'height': "5'3\"",
    },
    {
      'name': 'Pooja Chauhan',   'age': 24, 'city': 'Pune',
      'profession': 'Nurse', 'match': 78,
      'isOnline': false, 'isPremium': true,  'isNew': false,
      'image': AppAssets.dummyFemale7,
      'education': 'B.Sc Nursing', 'height': "5'4\"",
    },
    {
      'name': 'Swati More',      'age': 26, 'city': 'Kolhapur',
      'profession': 'Lawyer', 'match': 75,
      'isOnline': true,  'isPremium': false, 'isNew': false,
      'image': AppAssets.dummyFemale8,
      'education': 'LLB', 'height': "5'5\"",
    },
  ];

  // ── Computed ──────────────────────────────────────────────
  List<Map<String, dynamic>> get _filtered {
    return _allMatches.where((m) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final hit = (m['name'] as String).toLowerCase().contains(q) ||
            (m['city'] as String).toLowerCase().contains(q) ||
            (m['profession'] as String).toLowerCase().contains(q);
        if (!hit) return false;
      }
      switch (_selectedFilter) {
        case 'New':     return m['isNew']     as bool;
        case 'Online':  return m['isOnline']  as bool;
        case 'Premium': return m['isPremium'] as bool;
        case 'Near Me': return m['city'] == 'Mumbai' || m['city'] == 'Pune';
        default: return true;
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
      duration: const Duration(milliseconds: 260),
    );
    _searchHeight = Tween<double>(begin: 0, end: 48).animate(
      CurvedAnimation(parent: _searchAnim, curve: Curves.easeOutCubic),
    );
    _searchOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _searchAnim, curve: Curves.easeOut),
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
      Future.delayed(
        const Duration(milliseconds: 280),
            () => _searchFocus.requestFocus(),
      );
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
      builder: (_) => const SearchFilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppTheme.bgScaffold,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Compact top bar ───────────────────────────
            _buildTopBar(),

            // ── Collapsible search ────────────────────────
            AnimatedBuilder(
              animation: _searchAnim,
              builder: (_, __) {
                return SizeTransition(
                  sizeFactor: CurvedAnimation(
                    parent: _searchAnim,
                    curve: Curves.easeOutCubic,
                  ),
                  child: FadeTransition(
                    opacity: _searchOpacity,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: _SearchField(
                        controller: _searchCtrl,
                        focusNode: _searchFocus,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        onClear: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
                    ),
                  ),
                );
              },
            ),

            // ── Filter chips ──────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 8),
              child: FadeAnimation(
                delayInMs: 80,
                child: MatchesFilterChips(
                  options: _filterOptions,
                  selected: _selectedFilter,
                  onSelected: (f) {
                    HapticUtils.selectionClick();
                    setState(() => _selectedFilter = f);
                  },
                ),
              ),
            ),

            // ── Result count + guest badge ─────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Text(
                    '${filtered.length} profiles',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (_isGuest) _GuestBadge(
                    freeLimit: _guestFreeLimit,
                    onTap: () {
                      HapticUtils.lightImpact();
                      context.go('/login');
                    },
                  ),
                ],
              ),
            ),

            // ── Grid ──────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? EmptyStateWidget.noMatches(
                onRefresh: () => setState(() {
                  _searchQuery = '';
                  _selectedFilter = 'All';
                  _searchCtrl.clear();
                  if (_searchOpen) _toggleSearch();
                }),
              )
                  : _buildGrid(filtered, bottomPad),
            ),
          ],
        ),
      ),
    );
  }

  // ── Compact top bar ───────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
      child: Row(
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
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.brandDark,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Find your perfect match',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

          // Search icon
          _TopBarBtn(
            icon: _searchOpen
                ? Icons.close_rounded
                : Icons.search_rounded,
            onTap: _toggleSearch,
            isActive: _searchOpen,
          ),
          const SizedBox(width: 8),

          // Filter icon — single, opens bottom sheet
          _TopBarBtn(
            icon: Icons.tune_rounded,
            onTap: _openFilterSheet,
            isActive: false,
          ),
        ],
      ),
    );
  }

  // ── Grid ──────────────────────────────────────────────────
  Widget _buildGrid(List<Map<String, dynamic>> matches, double bottomPad) {
    return GridView.builder(
      controller: _scrollCtrl,
      padding: EdgeInsets.fromLTRB(16, 0, 16, 80 + bottomPad),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.66,
      ),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        final bool isLocked = _isGuest && index >= _guestFreeLimit;

        if (isLocked) {
          return GuestLockedCard(
            borderRadius: 20,
            child: MatchesGrid.buildCard(
              match: match,
              onLikeTap: () {},
            ),
          );
        }

        return FadeAnimation(
          delayInMs: index * 40,
          child: GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              context.push('/user_detail');
            },
            child: MatchesGrid.buildCard(
              match: match,
              onLikeTap: () {
                HapticUtils.heavyImpact();
                // TODO: interestsProvider.sendInterest(match['uid'])
              },
            ),
          ),
        );
      },
    );
  }
}


// ── Top bar icon button ───────────────────────────────────────
class _TopBarBtn extends StatelessWidget {
  const _TopBarBtn({
    required this.icon,
    required this.onTap,
    required this.isActive,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

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
            color: isActive
                ? AppTheme.brandPrimary
                : Colors.grey.shade200,
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


// ── Inline search field ───────────────────────────────────────
class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color: AppTheme.brandPrimary.withValues(alpha: 0.18),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
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
            color: AppTheme.brandPrimary.withValues(alpha: 0.60),
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, v, __) {
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
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}


// ── Guest badge ───────────────────────────────────────────────
class _GuestBadge extends StatelessWidget {
  const _GuestBadge({required this.freeLimit, required this.onTap});
  final int freeLimit;
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
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.brandPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}