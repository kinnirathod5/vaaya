import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 🔥 Humare Premium Lego Blocks
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../shared/widgets/custom_network_image.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/animations/fade_animation.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 🌟 Dummy Messages Data
  final List<Map<String, dynamic>> _messages = [
    {'text': 'Namaste! I really liked your profile.', 'isMe': false, 'time': '10:00 AM'},
    {'text': 'Namaste! Thank you so much. Your profile is impressive too! 😊', 'isMe': true, 'time': '10:05 AM'},
    {'text': 'I saw you studied at IIT Bombay. That is great! What do you do currently?', 'isMe': false, 'time': '10:06 AM'},
    {'text': 'Yes! Currently working at Google Bengaluru as a Senior Engineer.', 'isMe': true, 'time': '10:10 AM'},
    {'text': 'That is wonderful. I would love to know more about your family.', 'isMe': false, 'time': '10:12 AM'},
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    HapticUtils.lightImpact();
    setState(() {
      _messages.add({
        'text': _messageController.text.trim(),
        'isMe': true,
        'time': 'Just now',
      });
      _messageController.clear();
    });

    // Scroll to bottom after message sent
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgScaffold,
      // 🎩 PREMIUM CUSTOM APP BAR
      appBar: _buildChatAppBar(context),

      body: Column(
        children: [
          // 💬 MESSAGES LIST
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg, index);
              },
            ),
          ),

          // ⌨️ INPUT BAR SECTION
          _buildMessageInput(),
        ],
      ),
    );
  }

  // 📝 WIDGET: Custom Premium App Bar
  PreferredSizeWidget _buildChatAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leadingWidth: 40,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.brandDark, size: 20),
        onPressed: () => context.pop(),
      ),
      title: GestureDetector(
        onTap: () => context.push('/user_detail'),
        child: Row(
          children: [
            Stack(
              children: [
                const CustomNetworkImage(
                  imageUrl: 'https://images.unsplash.com/photo-1583089892943-e02e52f17d50?auto=format&fit=crop&w=400&q=80',
                  width: 40, height: 40, borderRadius: 20,
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('Priya Rathod', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.brandDark)),
                    SizedBox(width: 4),
                    Icon(Icons.verified_rounded, color: Colors.blueAccent, size: 14),
                  ],
                ),
                Text('Online', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.green.shade600, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
      actions: [
        IconButton(onPressed: () => HapticUtils.lightImpact(), icon: const Icon(Icons.videocam_outlined, color: Colors.grey)),
        IconButton(onPressed: () => HapticUtils.lightImpact(), icon: const Icon(Icons.call_outlined, color: Colors.grey)),
        const SizedBox(width: 10),
      ],
    );
  }

  // 📝 WIDGET: Message Bubble Design
  Widget _buildMessageBubble(Map<String, dynamic> msg, int index) {
    bool isMe = msg['isMe'];
    return FadeAnimation(
      delayInMs: index * 50,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? AppTheme.brandPrimary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 5),
                  bottomRight: Radius.circular(isMe ? 5 : 20),
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Text(
                msg['text'],
                style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 14,
                    color: isMe ? Colors.white : AppTheme.brandDark,
                    height: 1.4
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              msg['time'],
              style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }

  // 📝 WIDGET: Message Input Bar
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          // Emoji Button
          IconButton(onPressed: () {}, icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.grey)),

          // TextField Container
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(25)),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Type your message...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (val) => setState(() {}),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Send Button
          GestureDetector(
            onTap: _sendMessage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _messageController.text.isEmpty ? Colors.grey.shade300 : AppTheme.brandPrimary,
                shape: BoxShape.circle,
                boxShadow: _messageController.text.isEmpty
                    ? []
                    : [BoxShadow(color: AppTheme.brandPrimary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}