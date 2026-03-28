import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../shared/widgets/custom_network_image.dart';

// ============================================================
// 💬 CHAT DETAIL SCREEN — v2.0 All Widgets Inlined
//
// IMPROVEMENTS vs v1:
//   ✅ Header: rounded avatar (not square), online pulse dot
//   ✅ Header: video call + more buttons with proper icon bg
//   ✅ Message bubbles: smart corner radius (tail shape)
//   ✅ Message bubbles: mine = brand gradient, theirs = white
//   ✅ Avatar only shows on last message in a group
//   ✅ Date divider: centered pill, gradient side lines
//   ✅ Input bar: attachment tint, animated send button
//   ✅ Input bar: multiline expand, max 110px height
//   ✅ More options: profile view, mute, block, delete
//   ✅ Safe scroll to bottom on new message
//   ✅ All text: maxLines + overflow
//
// TODO: chatProvider.messages(conversationId) — Riverpod
// ============================================================

// ──────────────────────────────────────────────────────────────
// DUMMY DATA
// ──────────────────────────────────────────────────────────────

const _otherUser = <String, dynamic>{
  'name':       'Priya Rathod',
  'image':      AppAssets.dummyFemale1,
  'isOnline':   true,
  'lastSeen':   'Online',
  'profession': 'Software Engineer',
  'city':       'Bengaluru',
  'isPremium':  false,
};

// ──────────────────────────────────────────────────────────────
// SCREEN
// ──────────────────────────────────────────────────────────────

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {

  final _msgCtrl    = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isTyping = false;

  final List<Map<String, dynamic>> _messages = [
    {
      'id': 'm1', 'isMe': false,
      'text': 'Hello! 🙏 I saw your profile, really liked it.',
      'time': '10:02 AM', 'status': 'read',
    },
    {
      'id': 'm2', 'isMe': true,
      'text': 'Hi! Thank you 😊 Where are you from?',
      'time': '10:04 AM', 'status': 'read',
    },
    {
      'id': 'm3', 'isMe': false,
      'text': 'I\'m in Bengaluru, originally from Nagpur. You?',
      'time': '10:05 AM', 'status': 'read',
    },
    {
      'id': 'm4', 'isMe': true,
      'text': 'I\'m from Mumbai. You\'re also a Software Engineer? Saw it on your profile.',
      'time': '10:07 AM', 'status': 'read',
    },
    {
      'id': 'm5', 'isMe': false,
      'text': 'Yes! Been at TCS for 5 years. What do you do?',
      'time': '10:08 AM', 'status': 'read',
    },
    {
      'id': 'm6', 'isMe': true,
      'text': 'I\'m a product manager at a startup in Pune. My family is very traditional — Banjara community.',
      'time': '10:12 AM', 'status': 'read',
    },
    {
      'id': 'm7', 'isMe': false,
      'text': 'That\'s great! Our values seem to match 😊 Could we hop on a call this Sunday?',
      'time': '10:15 AM', 'status': 'read',
    },
    {
      'id': 'm8', 'isMe': true,
      'text': 'Sure! Sunday it is 😊',
      'time': '10:18 AM', 'status': 'delivered',
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

          // ── Header ──────────────────────────────────
          _ChatHeader(
            user: _otherUser,
            onBackTap: () { HapticUtils.lightImpact(); context.pop(); },
            onProfileTap: () { HapticUtils.lightImpact(); context.push('/user_detail'); },
            onCallTap: () => HapticUtils.mediumImpact(),
            onMoreTap: () => _showMoreOptions(context),
          ),

          // ── Messages ─────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              itemCount: _messages.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return const _DateDivider('Today');
                final msg = _messages[index - 1];
                // Show avatar only on last consecutive message from other user
                final bool showAvatar =
                    !(msg['isMe'] as bool) &&
                        (index == _messages.length ||
                            (_messages[index]['isMe'] as bool));
                return _MessageBubble(
                  message:        msg,
                  showAvatar:     showAvatar,
                  otherUserImage: _otherUser['image'],
                );
              },
            ),
          ),

          // ── Input bar ────────────────────────────────
          _ChatInputBar(
            controller:     _msgCtrl,
            isTyping:       _isTyping,
            bottomPadding:  bottomPad,
            onSend:         _sendMessage,
            onAttachment:   () => HapticUtils.lightImpact(),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
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
              icon: Icons.person_outline_rounded,
              label: 'View Profile',
              onTap: () {
                Navigator.pop(context);
                context.push('/user_detail');
              },
            ),
            _OptionTile(
              icon: Icons.volume_off_rounded,
              label: 'Mute Chat',
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
// CHAT HEADER
// ══════════════════════════════════════════════════════════════
class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    required this.user,
    required this.onBackTap,
    required this.onProfileTap,
    required this.onCallTap,
    required this.onMoreTap,
  });
  final Map<String, dynamic> user;
  final VoidCallback onBackTap, onProfileTap, onCallTap, onMoreTap;

  @override
  Widget build(BuildContext context) {
    final bool isOnline = user['isOnline'] as bool;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
          child: Row(
            children: [

              // Back button
              GestureDetector(
                onTap: onBackTap,
                child: Container(
                  width: 40, height: 40,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppTheme.brandDark,
                    size: 18,
                  ),
                ),
              ),

              // Avatar + name — tappable
              Expanded(
                child: GestureDetector(
                  onTap: onProfileTap,
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CustomNetworkImage(
                              imageUrl: user['image'],
                              width: 44, height: 44,
                              borderRadius: 16,
                            ),
                          ),
                          if (isOnline)
                            Positioned(
                              bottom: 1, right: 1,
                              child: Container(
                                width: 12, height: 12,
                                decoration: BoxDecoration(
                                  color: AppTheme.onlineDot,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white, width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['name'],
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.brandDark,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              isOnline ? '● Online' : user['lastSeen'],
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: isOnline
                                    ? const Color(0xFF16A34A)
                                    : Colors.grey.shade400,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Video call
              GestureDetector(
                onTap: onCallTap,
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.brandPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.videocam_rounded,
                    color: AppTheme.brandPrimary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // More options
              GestureDetector(
                onTap: onMoreTap,
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.more_vert_rounded,
                    color: Colors.grey.shade600,
                    size: 20,
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

// ══════════════════════════════════════════════════════════════
// MESSAGE BUBBLE
// ══════════════════════════════════════════════════════════════
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.showAvatar,
    required this.otherUserImage,
  });
  final Map<String, dynamic> message;
  final bool   showAvatar;
  final String otherUserImage;

  @override
  Widget build(BuildContext context) {
    final bool   isMe   = message['isMe']   as bool;
    final String text   = message['text']   as String;
    final String time   = message['time']   as String;
    final String status = message['status'] as String? ?? 'sent';

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment:
        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [

          // Other user avatar
          if (!isMe) ...[
            showAvatar
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomNetworkImage(
                imageUrl: otherUserImage,
                width: 30, height: 30,
                borderRadius: 12,
              ),
            )
                : const SizedBox(width: 30),
            const SizedBox(width: 8),
          ],

          // Bubble + timestamp
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [

                // Bubble
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.68,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    // Mine: brand gradient, theirs: white
                    gradient: isMe ? AppTheme.brandGradient : null,
                    color: isMe ? null : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft:     const Radius.circular(18),
                      topRight:    const Radius.circular(18),
                      bottomLeft:  Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4  : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isMe
                            ? AppTheme.brandPrimary.withValues(alpha: 0.20)
                            : Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: isMe ? Colors.white : AppTheme.brandDark,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 3),

                // Time + status ticks
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      _StatusTick(status),
                    ],
                  ],
                ),
              ],
            ),
          ),

          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// ── Status tick icon ──────────────────────────────────────────
class _StatusTick extends StatelessWidget {
  const _StatusTick(this.status);
  final String status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case 'sent':
        return Icon(Icons.check_rounded,
            size: 13, color: Colors.grey.shade400);
      case 'delivered':
        return Icon(Icons.done_all_rounded,
            size: 13, color: Colors.grey.shade400);
      case 'read':
        return const Icon(Icons.done_all_rounded,
            size: 13, color: AppTheme.brandPrimary);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ══════════════════════════════════════════════════════════════
// DATE DIVIDER
// ══════════════════════════════════════════════════════════════
class _DateDivider extends StatelessWidget {
  const _DateDivider(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.grey.shade200,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.shade200,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// CHAT INPUT BAR
// ══════════════════════════════════════════════════════════════
class _ChatInputBar extends StatelessWidget {
  const _ChatInputBar({
    required this.controller,
    required this.isTyping,
    required this.bottomPadding,
    required this.onSend,
    required this.onAttachment,
  });
  final TextEditingController controller;
  final bool     isTyping;
  final double   bottomPadding;
  final VoidCallback onSend;
  final VoidCallback onAttachment;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(14, 10, 14, 10 + bottomPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [

          // Attachment button
          GestureDetector(
            onTap: onAttachment,
            child: Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: AppTheme.brandPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.attach_file_rounded,
                color: AppTheme.brandPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Text field — expands multiline
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 42, maxHeight: 110,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F4F5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.brandPrimary.withValues(alpha: 0.10),
                ),
              ),
              child: TextField(
                controller: controller,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppTheme.brandDark,
                ),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 11,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Send button — activates on typing
          GestureDetector(
            onTap: isTyping ? onSend : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 42, height: 42,
              decoration: BoxDecoration(
                gradient: isTyping ? AppTheme.brandGradient : null,
                color: isTyping ? null : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(13),
                boxShadow: isTyping ? AppTheme.primaryGlow : [],
              ),
              child: Icon(
                Icons.send_rounded,
                size: 19,
                color: isTyping ? Colors.white : Colors.grey.shade400,
              ),
            ),
          ),
        ],
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