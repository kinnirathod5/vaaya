import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // 🔥 NAYA IMPORT: Navigation ke liye

// 🔥 Humare Premium Lego Blocks
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../shared/widgets/custom_network_image.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../../../shared/animations/fade_animation.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();

  // 🌟 Dummy Data: New Matches (Horizontal List)
  final List<Map<String, dynamic>> _newMatches = [
    {'name': 'Kavya', 'image': 'https://images.unsplash.com/photo-1583089892943-e02e52f17d50?auto=format&fit=crop&w=400&q=80', 'isOnline': true},
    {'name': 'Sneha', 'image': 'https://images.unsplash.com/photo-1605281317010-fe5ffe798166?auto=format&fit=crop&w=400&q=80', 'isOnline': false},
    {'name': 'Pooja', 'image': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=400&q=80', 'isOnline': true},
    {'name': 'Aarti', 'image': 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?auto=format&fit=crop&w=400&q=80', 'isOnline': false},
    {'name': 'Divya', 'image': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=400&q=80', 'isOnline': true},
  ];

  // 🌟 Dummy Data: Recent Chats (Vertical List)
  final List<Map<String, dynamic>> _chatList = [
    {
      'name': 'Riya Rathod',
      'message': 'Hi! I saw your profile and...',
      'time': '10:30 AM',
      'unread': 2,
      'image': 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?auto=format&fit=crop&w=400&q=80',
      'isOnline': true,
    },
    {
      'name': 'Neha Pawar',
      'message': 'Are we still meeting tomorrow?',
      'time': 'Yesterday',
      'unread': 0,
      'image': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
      'isOnline': false,
    },
    {
      'name': 'Anjali Chavan',
      'message': 'You: Thanks for the match! 😊',
      'time': 'Tuesday',
      'unread': 0,
      'image': 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?auto=format&fit=crop&w=400&q=80',
      'isOnline': false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgScaffold,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎩 HEADER SECTION
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Messages',
                    style: AppTheme.lightTheme.textTheme.displayLarge?.copyWith(fontSize: 32),
                  ),
                  GestureDetector(
                    onTap: () => HapticUtils.mediumImpact(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppTheme.softShadow),
                      child: const Icon(Icons.more_horiz_rounded, color: AppTheme.brandDark, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // 🔍 SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: CustomTextField(
                hintText: 'Search matches...',
                controller: _searchController,
                prefixIcon: Icons.search_rounded,
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // 🌟 NEW MATCHES SECTION (Horizontal Scroll)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Text('New Matches', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 110,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _newMatches.length,
                        itemBuilder: (context, index) {
                          final match = _newMatches[index];
                          return FadeAnimation(
                            delayInMs: index * 50,
                            child: GestureDetector(
                              onTap: () {
                                HapticUtils.lightImpact();
                                context.push('/user_detail'); // 🔥 YAHAN UPDATE KIYA HAI: New match pe click -> Profile
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  children: [
                                    Stack(
                                      children: [
                                        // Premium Glowing Border for New Matches
                                        Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(colors: [AppTheme.brandPrimary, Colors.orangeAccent]),
                                          ),
                                          child: CustomNetworkImage(
                                            imageUrl: match['image']!,
                                            width: 64,
                                            height: 64,
                                            borderRadius: 32,
                                          ),
                                        ),
                                        // Online Indicator
                                        if (match['isOnline'])
                                          Positioned(
                                            bottom: 2, right: 2,
                                            child: Container(
                                              width: 16, height: 16,
                                              decoration: BoxDecoration(color: Colors.green.shade400, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      match['name'],
                                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.brandDark),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 💬 RECENT CONVERSATIONS SECTION (Vertical Scroll)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      child: Text('Messages', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                    ),

                    ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100, left: 20, right: 20),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _chatList.length,
                      itemBuilder: (context, index) {
                        final chat = _chatList[index];
                        final hasUnread = chat['unread'] > 0;

                        return FadeAnimation(
                          delayInMs: 200 + (index * 100),
                          child: GestureDetector(
                            onTap: () {
                              HapticUtils.selectionClick();
                              context.push('/chat_detail'); // 🔥 YAHAN UPDATE KIYA HAI: Row pe click -> Chat Box
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: AppTheme.softShadow,
                              ),
                              child: Row(
                                children: [
                                  // Chat Avatar (Profile DP)
                                  GestureDetector(
                                    onTap: () {
                                      HapticUtils.lightImpact();
                                      context.push('/user_detail'); // 🔥 YAHAN UPDATE KIYA HAI: Sirf DP pe click -> Profile Detail
                                    },
                                    child: Stack(
                                      children: [
                                        CustomNetworkImage(imageUrl: chat['image']!, width: 60, height: 60, borderRadius: 30),
                                        if (chat['isOnline'])
                                          Positioned(
                                            bottom: 0, right: 0,
                                            child: Container(width: 14, height: 14, decoration: BoxDecoration(color: Colors.green.shade400, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 15),

                                  // Chat Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          chat['name'],
                                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.brandDark),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          chat['message'],
                                          style: TextStyle(
                                              fontFamily: 'Poppins', fontSize: 13,
                                              fontWeight: hasUnread ? FontWeight.bold : FontWeight.w500,
                                              color: hasUnread ? AppTheme.brandDark : Colors.grey.shade500
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Time & Unread Badge
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        chat['time'],
                                        style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: hasUnread ? AppTheme.brandPrimary : Colors.grey.shade400),
                                      ),
                                      const SizedBox(height: 8),
                                      if (hasUnread)
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(color: AppTheme.brandPrimary, shape: BoxShape.circle),
                                          child: Text(
                                            chat['unread'].toString(),
                                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                        )
                                      else
                                        const SizedBox(height: 20), // Placeholder to maintain alignment
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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