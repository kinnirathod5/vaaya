import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../shared/animations/fade_animation.dart';

import '../widgets/chat_list_header.dart';
import '../widgets/chat_list_tile.dart';
import '../widgets/chat_empty_state.dart';
import '../widgets/match_stories_row.dart';

// ============================================================
// 💬 CHAT LIST SCREEN
// Active conversations + New matches stories row.
// Search is hidden behind an icon — expands inline on tap.
//
// TODO: Replace dummy data with chatProvider (Riverpod)
//   chatProvider.conversations
//   chatProvider.newMatches
//   chatProvider.totalUnreadCount
// ============================================================
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {

  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _searchOpen = false;
  String _searchQuery = '';

  late final AnimationController _searchAnim;
  late final Animation<double> _searchOpacity;

  // ── Dummy data ────────────────────────────────────────────

  static const List<Map<String, dynamic>> _newMatches = [
    {'name': 'Anjali', 'image': AppAssets.dummyFemale2, 'isNew': true},
    {'name': 'Kavya',  'image': AppAssets.dummyFemale4, 'isNew': true},
    {'name': 'Sneha',  'image': AppAssets.dummyFemale6, 'isNew': false},
    {'name': 'Pooja',  'image': AppAssets.dummyFemale7, 'isNew': false},
  ];

  static const List<Map<String, dynamic>> _allConvos = [
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

  // ── Computed ──────────────────────────────────────────────
  List<Map<String, dynamic>> get _filtered {
    if (_searchQuery.isEmpty) return _allConvos;
    return _allConvos.where((c) =>
        (c['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase()),
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
      duration: const Duration(milliseconds: 240),
    );
    _searchOpacity = CurvedAnimation(
      parent: _searchAnim,
      curve: Curves.easeOut,
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
      Future.delayed(
        const Duration(milliseconds: 260),
            () => _searchFocus.requestFocus(),
      );
    } else {
      _searchAnim.reverse();
      _searchFocus.unfocus();
      _searchCtrl.clear();
      setState(() => _searchQuery = '');
    }
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

            // Header — title + search icon + compose icon
            ChatListHeader(
              unreadCount: _totalUnread,
              searchOpen: _searchOpen,
              onSearchTap: _toggleSearch,
            ),

            // Collapsible search
            SizeTransition(
              sizeFactor: CurvedAnimation(
                parent: _searchAnim,
                curve: Curves.easeOutCubic,
              ),
              child: FadeTransition(
                opacity: _searchOpacity,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: _InlineSearchBar(
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
            ),

            // New matches stories — hidden during search
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 16),
              FadeAnimation(
                delayInMs: 80,
                child: MatchStoriesRow(
                  matches: _newMatches,
                  onMatchTap: (match) {
                    HapticUtils.lightImpact();
                    context.push('/chat_detail');
                  },
                ),
              ),
              const SizedBox(height: 18),
            ] else
              const SizedBox(height: 10),

            // Section label
            FadeAnimation(
              delayInMs: 120,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  children: [
                    Text(
                      _searchQuery.isEmpty
                          ? 'Messages'
                          : '${filtered.length} results',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.brandDark,
                        letterSpacing: -0.2,
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
              ),
            ),
            const SizedBox(height: 8),

            // Conversation list
            Expanded(
              child: filtered.isEmpty
                  ? ChatEmptyState(
                isSearching: _searchQuery.isNotEmpty,
                searchQuery: _searchQuery,
              )
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  bottom: 80 + bottomPad,
                  top: 4,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  return FadeAnimation(
                    delayInMs: 140 + (index * 50),
                    child: ChatListTile(
                      conversation: filtered[index],
                      onTap: () {
                        HapticUtils.lightImpact();
                        context.push('/chat_detail');
                      },
                      onLongPress: () {
                        HapticUtils.mediumImpact();
                        _showOptions(filtered[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(Map<String, dynamic> convo) {
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
              onTap: () {
                Navigator.pop(context);
                // TODO: chatProvider.deleteConversation(convo['id'])
              },
            ),
          ],
        ),
      ),
    );
  }
}


// ── Inline search bar ─────────────────────────────────────────
class _InlineSearchBar extends StatelessWidget {
  const _InlineSearchBar({
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
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.brandPrimary.withValues(alpha: 0.18),
          width: 1.5,
        ),
        boxShadow: AppTheme.softShadow,
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
          hintText: 'Search by name...',
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
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}


// ── Option tile ───────────────────────────────────────────────
class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}