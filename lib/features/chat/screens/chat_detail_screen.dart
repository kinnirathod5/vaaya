import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/constants/app_assets.dart';

import '../widgets/message_bubble.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_detail_header.dart';

// ============================================================
// 💬 CHAT DETAIL SCREEN
// Individual conversation — messages + input bar
//
// TODO: chatProvider.messages(conversationId)
//       chatProvider.sendMessage(conversationId, text)
//       Firestore real-time snapshots
// ============================================================
class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {

  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _isTyping = false;

  // ── Dummy data ────────────────────────────────────────────
  static const Map<String, dynamic> _otherUser = {
    'name':       'Priya Rathod',
    'image':      AppAssets.dummyFemale1,
    'isOnline':   true,
    'lastSeen':   'Online',
    'profession': 'Software Engineer',
    'city':       'Bengaluru',
    'isPremium':  false,
  };

  final List<Map<String, dynamic>> _messages = [
    {
      'id': 'm1',
      'text': 'Hello! 🙏 I saw your profile, really liked it.',
      'isMe': false, 'time': '10:02 AM', 'status': 'read',
    },
    {
      'id': 'm2',
      'text': 'Hi! Thank you 😊 Where are you from?',
      'isMe': true,  'time': '10:04 AM', 'status': 'read',
    },
    {
      'id': 'm3',
      'text': 'I\'m in Bengaluru, originally from Nagpur. You?',
      'isMe': false, 'time': '10:05 AM', 'status': 'read',
    },
    {
      'id': 'm4',
      'text': 'I\'m from Mumbai. You\'re also a Software Engineer? Saw it on your profile.',
      'isMe': true,  'time': '10:07 AM', 'status': 'read',
    },
    {
      'id': 'm5',
      'text': 'Yes! Been at TCS for 5 years. What do you do?',
      'isMe': false, 'time': '10:08 AM', 'status': 'read',
    },
    {
      'id': 'm6',
      'text': 'I\'m a product manager at a startup in Pune. My family is very traditional — Banjara community.',
      'isMe': true,  'time': '10:12 AM', 'status': 'read',
    },
    {
      'id': 'm7',
      'text': 'That\'s great! Our values seem to match 😊 Could we hop on a call this Sunday?',
      'isMe': false, 'time': '10:15 AM', 'status': 'read',
    },
    {
      'id': 'm8',
      'text': 'Sure! Sunday it is 😊',
      'isMe': true,  'time': '10:18 AM', 'status': 'delivered',
    },
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _msgCtrl.addListener(_onTypingChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _msgCtrl.removeListener(_onTypingChanged);
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onTypingChanged() {
    final typing = _msgCtrl.text.isNotEmpty;
    if (typing != _isTyping) setState(() => _isTyping = typing);
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    HapticUtils.lightImpact();
    setState(() {
      _messages.add({
        'id': 'm${_messages.length + 1}',
        'text': text,
        'isMe': true,
        'time': _now(),
        'status': 'sent',
      });
    });
    _msgCtrl.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    // TODO: chatProvider.sendMessage(conversationId, text)
  }

  String _now() {
    final t = DateTime.now();
    final h = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.hour >= 12 ? 'PM' : 'AM'}';
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.bgScaffold,
      body: Column(
        children: [

          // Header
          ChatDetailHeader(
            user: _otherUser,
            onBackTap: () {
              HapticUtils.lightImpact();
              context.pop();
            },
            onProfileTap: () {
              HapticUtils.lightImpact();
              context.push('/user_detail');
            },
            onCallTap: () => HapticUtils.mediumImpact(),
            onMoreTap: _showMoreOptions,
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              itemCount: _messages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _DateDivider('Today');
                final msg = _messages[index - 1];
                final bool showAvatar = !(msg['isMe'] as bool) &&
                    (index == _messages.length ||
                        (_messages[index]['isMe'] as bool));
                return MessageBubble(
                  message: msg,
                  showAvatar: showAvatar,
                  otherUserImage: _otherUser['image'],
                );
              },
            ),
          ),

          // Input
          ChatInputBar(
            controller: _msgCtrl,
            isTyping: _isTyping,
            bottomPadding: bottomPad,
            onSend: _sendMessage,
            onAttachmentTap: () => HapticUtils.lightImpact(),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
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
            _OptionRow(
              icon: Icons.person_outline_rounded,
              label: 'View Profile',
              onTap: () {
                Navigator.pop(context);
                context.push('/user_detail');
              },
            ),
            _OptionRow(
              icon: Icons.volume_off_rounded,
              label: 'Mute Chat',
              onTap: () => Navigator.pop(context),
            ),
            _OptionRow(
              icon: Icons.block_rounded,
              label: 'Block User',
              color: Colors.orange.shade600,
              onTap: () => Navigator.pop(context),
            ),
            _OptionRow(
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


// ── Date divider ──────────────────────────────────────────────
class _DateDivider extends StatelessWidget {
  const _DateDivider(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: Colors.grey.shade200)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(label, style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              )),
            ),
          ),
          Expanded(child: Container(height: 1, color: Colors.grey.shade200)),
        ],
      ),
    );
  }
}


// ── Option row ────────────────────────────────────────────────
class _OptionRow extends StatelessWidget {
  const _OptionRow({
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
        fontFamily: 'Poppins', fontSize: 14,
        fontWeight: FontWeight.w600, color: c,
      )),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}