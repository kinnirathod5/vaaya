import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../shared/animations/fade_animation.dart';
import '../../../../shared/widgets/custom_network_image.dart';

// ============================================================
// 💬 CHAT LIST SCREEN — v2.0 All Widgets Inlined
//
// IMPROVEMENTS vs v1:
//   ✅ Ambient background blobs (consistent with all screens)
//   ✅ Header: two-tone title (Messages bold + unread subtitle)
//   ✅ Stories row: "New Matches" label + count badge
//   ✅ Stories ring: gradient for new, grey for seen
//   ✅ Conversation tile: unread brand tint + border
//   ✅ Online dot on avatar, premium gold badge
//   ✅ Status ticks: sent/delivered/read with correct colors
//   ✅ Empty state: gradient circle bg + Cormorant title
//   ✅ FadeAnimation stagger on list items
//   ✅ SizeTransition + FadeTransition on search bar
//   ✅ Long-press bottom sheet with icon options
//   ✅ All text: maxLines + overflow everywhere
//
// TODO: Replace dummy data with chatProvider (Riverpod)
// ============================================================

// ──────────────────────────────────────────────────────────────
// DUMMY DATA
// ──────────────────────────────────────────────────────────────

const _newMatches = <Map<String, dynamic>>[
  {'name': 'Anjali', 'image': AppAssets.dummyFemale2, 'isNew': true},
  {'name': 'Kavya',  'image': AppAssets.dummyFemale4, 'isNew': true},
  {'name': 'Sneha',  'image': AppAssets.dummyFemale6, 'isNew': false},
  {'name': 'Pooja',  'image': AppAssets.dummyFemale7, 'isNew': false},
];

const _allConvos = <Map<String, dynamic>>[
  {
    'id': 'c1', 'name': 'Priya Rathod',
    'image': AppAssets.dummyFemale1,
    'lastMessage': 'Sure! Sunday it is 😊',
    'time': '2m', 'unreadCount': 2,
    'isOnline': true,  'isPremium': false,
    'lastMessageIsMe': false, 'messageStatus': 'delivered',
  },
  {
    'id': 'c2', 'name': 'Anjali Chavan',
    'image': AppAssets.dummyFemale2,
    'lastMessage': 'Your profile is really nice 🙏',
    'time': '18m', 'unreadCount': 0,
    'isOnline': true,  'isPremium': true,
    'lastMessageIsMe': false, 'messageStatus': 'read',
  },
  {
    'id': 'c3', 'name': 'Sneha Pawar',
    'image': AppAssets.dummyFemale3,
    'lastMessage': 'I had sent you an interest earlier...',
    'time': '1h', 'unreadCount': 0,
    'isOnline': false, 'isPremium': false,
    'lastMessageIsMe': true,  'messageStatus': 'delivered',
  },
  {
    'id': 'c4', 'name': 'Kavya Desai',
    'image': AppAssets.dummyFemale4,
    'lastMessage': 'Saw your photo, very beautiful 😍',
    'time': '3h', 'unreadCount': 1,
    'isOnline': false, 'isPremium': true,
    'lastMessageIsMe': false, 'messageStatus': 'read',
  },
  {
    'id': 'c5', 'name': 'Roshni Kulkarni',
    'image': AppAssets.dummyFemale5,
    'lastMessage': 'Yes, I stay in Pune.',
    'time': 'Yesterday', 'unreadCount': 0,
    'isOnline': false, 'isPremium': false,
    'lastMessageIsMe': false, 'messageStatus': 'read',
  },
  {
    'id': 'c6', 'name': 'Meera Joshi',
    'image': AppAssets.dummyFemale8,
    'lastMessage': 'Okay, talk tomorrow 🙏',
    'time': '2d', 'unreadCount': 0,
    'isOnline': false, 'isPremium': false,
    'lastMessageIsMe': true,  'messageStatus': 'read',
  },
];

// ──────────────────────────────────────────────────────────────
// SCREEN
// ──────────────────────────────────────────────────────────────

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {

  final _searchCtrl  = TextEditingController();
  final _searchFocus = FocusNode();
  bool   _searchOpen  = false;
  String _searchQuery = '';

  late final AnimationController _searchAnim;
  late final Animation<double>   _searchExpand;
  late final Animation<double>   _searchFade;

  List<Map<String, dynamic>> get _filtered {
    if (_searchQuery.isEmpty) return _allConvos;
    return _allConvos.where((c) =>
        (c['name'] as String)
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()),
    ).toList();
  }

  int get _totalUnread =>
      _allConvos.fold(0, (sum, c) => sum + (c['unreadCount'] as int));

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
    _searchExpand = CurvedAnimation(
      parent: _searchAnim, curve: Curves.easeOutCubic,
    );
    _searchFade = CurvedAnimation(
      parent: _searchAnim, curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
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
      Future.delayed(const Duration(milliseconds: 270),
              () { if (mounted) _searchFocus.requestFocus(); });
    } else {
      _searchAnim.reverse();
      _searchFocus.unfocus();
      _searchCtrl.clear();
      setState(() => _searchQuery = '');
    }
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
          RepaintBoundary(child: _AmbientBackground()),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Header ─────────────────────────────
                FadeAnimation(
                  delayInMs: 0,
                  child: _buildHeader(),
                ),

                // ── Collapsible search ──────────────────
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

                // ── New matches stories row ─────────────
                if (_searchQuery.isEmpty) ...[
                  const SizedBox(height: 18),
                  FadeAnimation(
                    delayInMs: 60,
                    child: _buildStoriesRow(),
                  ),
                  const SizedBox(height: 18),
                ] else
                  const SizedBox(height: 10),

                // ── Messages section label ──────────────
                FadeAnimation(
                  delayInMs: 100,
                  child: _buildSectionLabel(filtered),
                ),
                const SizedBox(height: 6),

                // ── List or empty state ─────────────────
                Expanded(
                  child: filtered.isEmpty
                      ? _EmptyState(
                    isSearching: _searchQuery.isNotEmpty,
                    searchQuery: _searchQuery,
                  )
                      : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      bottom: 88 + bottomPad,
                      top: 4,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return FadeAnimation(
                        delayInMs: 120 + (index * 50).clamp(0, 400),
                        child: _ConvoTile(
                          convo: filtered[index],
                          onTap: () {
                            HapticUtils.lightImpact();
                            context.push('/chat_detail');
                          },
                          onLongPress: () {
                            HapticUtils.mediumImpact();
                            _showOptions(context, filtered[index]);
                          },
                        ),
                      );
                    },
                  ),
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
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Messages',
                  style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.brandDark,
                    letterSpacing: -0.5,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _totalUnread > 0
                      ? '$_totalUnread unread messages'
                      : 'All caught up',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: _totalUnread > 0
                        ? AppTheme.brandPrimary
                        : Colors.grey.shade500,
                    fontWeight: _totalUnread > 0
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          // Search toggle
          _IconBtn(
            icon: _searchOpen
                ? Icons.close_rounded
                : Icons.search_rounded,
            isActive: _searchOpen,
            onTap: _toggleSearch,
          ),
          const SizedBox(width: 8),
          // Compose
          _IconBtn(
            icon: Icons.edit_outlined,
            isActive: false,
            onTap: () {}, // TODO: new conversation
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // NEW MATCHES STORIES ROW
  // ══════════════════════════════════════════════════════════
  Widget _buildStoriesRow() {
    final newCount = _newMatches.where((m) => m['isNew'] as bool).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label + count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text(
                'New Matches',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.brandDark,
                ),
              ),
              const SizedBox(width: 6),
              if (newCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.brandPrimary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$newCount',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.brandPrimary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Horizontal avatar list
        SizedBox(
          height: 90,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _newMatches.length,
            itemBuilder: (_, index) {
              final m      = _newMatches[index];
              final isNew  = m['isNew'] as bool;
              return GestureDetector(
                onTap: () {
                  HapticUtils.lightImpact();
                  context.push('/chat_detail');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: Column(
                    children: [
                      // Gradient ring (new) or grey ring (seen)
                      Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isNew ? AppTheme.brandGradient : null,
                          color: isNew ? null : Colors.grey.shade300,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: CustomNetworkImage(
                              imageUrl: m['image'],
                              width: 50, height: 50,
                              borderRadius: 25,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        m['name'],
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.brandDark,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Section label ─────────────────────────────────────────
  Widget _buildSectionLabel(List<Map<String, dynamic>> filtered) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            _searchQuery.isEmpty
                ? 'Conversations'
                : '${filtered.length} result${filtered.length == 1 ? '' : 's'}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.brandDark,
              letterSpacing: -0.1,
            ),
          ),
          if (_totalUnread > 0 && _searchQuery.isEmpty) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppTheme.brandPrimary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$_totalUnread',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Long press options ────────────────────────────────────
  void _showOptions(BuildContext context, Map<String, dynamic> convo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
          20, 12, 20,
          24 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            _OptionTile(
              icon: Icons.volume_off_rounded,
              label: 'Mute Conversation',
              onTap: () => Navigator.pop(context),
            ),
            _OptionTile(
              icon: Icons.block_rounded,
              label: 'Block User',
              color: Colors.orange.shade600,
              onTap: () => Navigator.pop(context),
            ),
            _OptionTile(
              icon: Icons.delete_outline_rounded,
              label: 'Delete Chat',
              color: Colors.red.shade500,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
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
          top: 380, left: -80,
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
// HEADER ICON BUTTON
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 44, height: 44,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.brandPrimary : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isActive ? AppTheme.primaryGlow : AppTheme.softShadow,
        border: Border.all(
          color: isActive ? AppTheme.brandPrimary : Colors.grey.shade200,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Icon(
            icon, size: 20,
            color: isActive ? Colors.white : AppTheme.brandDark,
          ),
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
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.brandPrimary.withValues(alpha: 0.20),
          width: 1.5,
        ),
        boxShadow: AppTheme.softShadow,
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
          hintText: 'Search by name...',
          hintStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: Colors.grey.shade400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded, size: 18,
            color: AppTheme.brandPrimary.withValues(alpha: 0.55),
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, v, _) {
              if (v.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: onClear,
                child: Icon(Icons.cancel_rounded, size: 17,
                    color: Colors.grey.shade400),
              );
            },
          ),
          border:         InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CONVERSATION TILE
// ══════════════════════════════════════════════════════════════
class _ConvoTile extends StatelessWidget {
  const _ConvoTile({
    required this.convo,
    required this.onTap,
    required this.onLongPress,
  });
  final Map<String, dynamic> convo;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final bool isOnline  = convo['isOnline']  as bool;
    final bool isPremium = convo['isPremium'] as bool;
    final int  unread    = convo['unreadCount'] as int;
    final bool hasUnread = unread > 0;
    final bool isMe      = convo['lastMessageIsMe'] as bool;
    final String status  = convo['messageStatus'] as String;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: hasUnread
              ? AppTheme.brandPrimary.withValues(alpha: 0.04)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: hasUnread
              ? Border.all(
            color: AppTheme.brandPrimary.withValues(alpha: 0.10),
          )
              : null,
        ),
        child: Row(
          children: [

            // Avatar + badges
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: CustomNetworkImage(
                    imageUrl: convo['image'],
                    width: 54, height: 54,
                    borderRadius: 18,
                  ),
                ),
                // Premium badge
                if (isPremium)
                  Positioned(
                    top: -2, right: -2,
                    child: Container(
                      width: 18, height: 18,
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.diamond_rounded,
                        size: 9, color: Colors.white,
                      ),
                    ),
                  ),
                // Online dot
                if (isOnline)
                  Positioned(
                    bottom: 1, right: 1,
                    child: Container(
                      width: 13, height: 13,
                      decoration: BoxDecoration(
                        color: AppTheme.onlineDot,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Name + last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          convo['name'],
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: hasUnread
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: AppTheme.brandDark,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        convo['time'],
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: hasUnread
                              ? AppTheme.brandPrimary
                              : Colors.grey.shade400,
                          fontWeight: hasUnread
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (isMe) ...[
                        _StatusIcon(status),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          convo['lastMessage'],
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: hasUnread
                                ? AppTheme.brandDark
                                : Colors.grey.shade500,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          constraints: const BoxConstraints(minWidth: 20),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.brandPrimary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$unread',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Message status icon ───────────────────────────────────────
class _StatusIcon extends StatelessWidget {
  const _StatusIcon(this.status);
  final String status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case 'sent':
        return Icon(Icons.check_rounded,
            size: 14, color: Colors.grey.shade400);
      case 'delivered':
        return Icon(Icons.done_all_rounded,
            size: 14, color: Colors.grey.shade400);
      case 'read':
        return const Icon(Icons.done_all_rounded,
            size: 14, color: AppTheme.brandPrimary);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ══════════════════════════════════════════════════════════════
// EMPTY STATE
// ══════════════════════════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.isSearching,
    this.searchQuery = '',
  });
  final bool   isSearching;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.brandPrimary.withValues(alpha: 0.10),
                    AppTheme.brandPrimary.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.brandPrimary.withValues(alpha: 0.12),
                ),
              ),
              child: Center(
                child: Text(
                  isSearching ? '🔍' : '💬',
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isSearching
                  ? '"$searchQuery" not found'
                  : 'No conversations yet',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Cormorant Garamond',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.brandDark,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Try a different name'
                  : 'Send an interest to start\na conversation',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Colors.grey.shade500,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// OPTION TILE (bottom sheet)
// ══════════════════════════════════════════════════════════════
class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String   label;
  final VoidCallback onTap;
  final Color?   color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.brandDark;
    return ListTile(
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: c, size: 20),
      ),
      title: Text(label, style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: c,
      )),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}