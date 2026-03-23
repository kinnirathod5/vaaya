import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../shared/animations/fade_animation.dart';

import '../widgets/interests_header.dart';
import '../widgets/interests_tab_bar.dart';
import '../widgets/received_request_card.dart';
import '../widgets/sent_request_card.dart';
import '../widgets/mutual_match_card.dart';
import '../widgets/interests_empty_state.dart';
import '../widgets/section_divider_label.dart';

// ============================================================
// ❤️ INTERESTS SCREEN
// Received, Sent, and Mutual Matches — two tabs
// TODO: Replace dummy data with interestsProvider (Riverpod)
//   interestsProvider.receivedRequests
//   interestsProvider.sentRequests
//   interestsProvider.mutualMatches
// ============================================================
class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen>
    with SingleTickerProviderStateMixin {

  late final TabController _tabController;

  // ── Dummy data ────────────────────────────────────────────

  final List<Map<String, dynamic>> _received = [
    {
      'id': '1',
      'name': 'Priya Rathod', 'age': 24,
      'profession': 'Software Engineer', 'city': 'Bengaluru',
      'education': 'B.Tech',
      'image': AppAssets.dummyFemale1,
      'time': '2h ago', 'isOnline': true, 'matchPct': 98,
    },
    {
      'id': '2',
      'name': 'Anjali Chavan', 'age': 26,
      'profession': 'UX Designer', 'city': 'Mumbai',
      'education': 'B.Des',
      'image': AppAssets.dummyFemale2,
      'time': '5h ago', 'isOnline': false, 'matchPct': 92,
    },
    {
      'id': '3',
      'name': 'Kavya Desai', 'age': 23,
      'profession': 'CA', 'city': 'Nashik',
      'education': 'CA Final',
      'image': AppAssets.dummyFemale4,
      'time': 'Yesterday', 'isOnline': false, 'matchPct': 87,
    },
  ];

  final List<Map<String, dynamic>> _sent = [
    {
      'id': '4',
      'name': 'Neha Kulkarni', 'age': 25,
      'profession': 'Marketing Head', 'city': 'Pune',
      'image': AppAssets.dummyFemale3,
      'status': 'Pending', 'sentTime': '3h ago',
    },
    {
      'id': '5',
      'name': 'Roshni More', 'age': 27,
      'profession': 'Architect', 'city': 'Nagpur',
      'image': AppAssets.dummyFemale5,
      'status': 'Viewed', 'sentTime': '1d ago',
    },
  ];

  final List<Map<String, dynamic>> _mutual = [
    {
      'id': '6',
      'name': 'Sneha Pawar', 'age': 25,
      'profession': 'Doctor', 'city': 'Pune',
      'image': AppAssets.dummyFemale6,
      'matchedTime': 'Just now',
    },
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticUtils.selectionClick();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.bgScaffold,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Header
            InterestsHeader(
              newCount: _received.length,
              onNotificationTap: () {
                HapticUtils.lightImpact();
                context.push('/notifications');
              },
            ),

            // Tab bar
            InterestsTabBar(
              controller: _tabController,
              receivedCount: _received.length,
              sentCount: _sent.length,
            ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildReceivedTab(bottomPad),
                  _buildSentTab(bottomPad),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Received tab ──────────────────────────────────────────
  Widget _buildReceivedTab(double bottomPad) {
    if (_received.isEmpty && _mutual.isEmpty) {
      return const InterestsEmptyState(
        emoji: '💌',
        title: 'No interests yet',
        message: 'When someone sends you an interest,\nit will appear here.',
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 80 + bottomPad),
      children: [

        // Mutual matches — shown first, most exciting
        if (_mutual.isNotEmpty) ...[
          const SectionDividerLabel(label: 'Mutual Match', emoji: '🎉'),
          ..._mutual.asMap().entries.map((e) => FadeAnimation(
            delayInMs: e.key * 80,
            child: MutualMatchCard(
              profile: e.value,
              onTap: () {
                HapticUtils.mediumImpact();
                context.push('/user_detail');
              },
              onChatTap: () {
                HapticUtils.heavyImpact();
                context.push('/chat_detail');
              },
            ),
          )),
          const SizedBox(height: 8),
        ],

        // Received requests
        if (_received.isNotEmpty) ...[
          SectionDividerLabel(
            label: 'New Requests',
            emoji: '❤️',
            count: _received.length,
          ),
          ..._received.asMap().entries.map((e) => FadeAnimation(
            delayInMs: e.key * 100,
            child: ReceivedRequestCard(
              profile: e.value,
              onTap: () {
                HapticUtils.lightImpact();
                context.push('/user_detail');
              },
              onAccept: () {
                HapticUtils.heavyImpact();
                _accept(e.value['id']);
              },
              onDecline: () {
                HapticUtils.mediumImpact();
                _decline(e.value['id']);
              },
            ),
          )),
        ],
      ],
    );
  }

  // ── Sent tab ──────────────────────────────────────────────
  Widget _buildSentTab(double bottomPad) {
    if (_sent.isEmpty) {
      return const InterestsEmptyState(
        emoji: '📤',
        title: 'No interests sent',
        message: 'Browse profiles and send\nyour first interest.',
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(18, 16, 18, 80 + bottomPad),
      children: _sent.asMap().entries.map((e) => FadeAnimation(
        delayInMs: e.key * 100,
        child: SentRequestCard(
          profile: e.value,
          onTap: () {
            HapticUtils.lightImpact();
            context.push('/user_detail');
          },
          onCancel: () {
            HapticUtils.mediumImpact();
            _cancelSent(e.value['id']);
          },
        ),
      )).toList(),
    );
  }

  // ── Handlers ──────────────────────────────────────────────
  void _accept(String id) {
    // TODO: interestsProvider.acceptRequest(id)
    setState(() {
      final r = _received.firstWhere((r) => r['id'] == id);
      _received.removeWhere((r) => r['id'] == id);
      _mutual.insert(0, {...r, 'matchedTime': 'Just now'});
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text(
        'Interest accepted! 🎉',
        style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
      ),
      backgroundColor: AppTheme.brandPrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  void _decline(String id) {
    // TODO: interestsProvider.declineRequest(id)
    setState(() => _received.removeWhere((r) => r['id'] == id));
  }

  void _cancelSent(String id) {
    // TODO: interestsProvider.cancelRequest(id)
    setState(() => _sent.removeWhere((r) => r['id'] == id));
  }
}