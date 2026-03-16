import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 🔥 Humare Premium Lego Blocks
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../shared/animations/fade_animation.dart';
import '../../../shared/widgets/premium_avatar.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // 🌟 Dummy Notifications Data
  final List<Map<String, dynamic>> _notifications = [
    {
      'type': 'match',
      'title': 'New Match! 🎉',
      'message': 'You and Priya liked each other. Say Hi!',
      'time': '2m ago',
      'isRead': false,
      'image': 'https://images.unsplash.com/photo-1583089892943-e02e52f17d50?auto=format&fit=crop&w=400&q=80',
    },
    {
      'type': 'view',
      'title': 'Profile View',
      'message': 'Someone from Mumbai viewed your profile.',
      'time': '1h ago',
      'isRead': false,
      'icon': Icons.visibility_rounded,
      'color': Colors.blueAccent,
    },
    {
      'type': 'promo',
      'title': 'VIP Offer 👑',
      'message': 'Get 50% off on 3-month VIP plan. Limited time only!',
      'time': '3h ago',
      'isRead': true,
      'icon': Icons.workspace_premium_rounded,
      'color': Colors.amber.shade600,
    },
    {
      'type': 'message',
      'title': 'New Message',
      'message': 'Anjali: Are we still meeting tomorrow?',
      'time': '1d ago',
      'isRead': true,
      'image': 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?auto=format&fit=crop&w=400&q=80',
    },
    {
      'type': 'system',
      'title': 'Profile Tip',
      'message': 'Add your family details to get 2x more matches.',
      'time': '2d ago',
      'isRead': true,
      'icon': Icons.tips_and_updates_rounded,
      'color': Colors.orange,
    },
  ];

  void _markAllAsRead() {
    HapticUtils.heavyImpact();
    setState(() {
      for (var notif in _notifications) {
        notif['isRead'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgScaffold,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.brandDark, size: 20),
          onPressed: () {
            HapticUtils.lightImpact();
            context.pop();
          },
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.brandDark),
        ),
        actions: [
          // Mark all as read button
          IconButton(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.done_all_rounded, color: AppTheme.brandPrimary),
            tooltip: 'Mark all as read',
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notif = _notifications[index];
          return FadeAnimation(
            delayInMs: index * 100,
            child: _buildNotificationTile(notif),
          );
        },
      ),
    );
  }

  // 🔔 WIDGET: Notification Tile Design
  Widget _buildNotificationTile(Map<String, dynamic> notif) {
    bool isRead = notif['isRead'];

    return GestureDetector(
      onTap: () {
        HapticUtils.selectionClick();
        setState(() => notif['isRead'] = true);

        // Navigation logic based on notification type
        if (notif['type'] == 'match' || notif['type'] == 'view') {
          context.push('/user_detail');
        } else if (notif['type'] == 'message') {
          context.push('/chat_detail');
        } else if (notif['type'] == 'promo') {
          // VIP screen is in bottom nav, but you can route there
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isRead ? Colors.transparent : AppTheme.brandPrimary.withOpacity(0.05),
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
            left: BorderSide(
              color: isRead ? Colors.transparent : AppTheme.brandPrimary,
              width: 4,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ Leading Icon or Avatar
            if (notif.containsKey('image'))
              PremiumAvatar(imageUrl: notif['image'], size: 50)
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: notif['color'].withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(notif['icon'], color: notif['color'], size: 24),
              ),

            const SizedBox(width: 15),

            // 📝 Notification Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif['title'],
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                              color: AppTheme.brandDark
                          ),
                        ),
                      ),
                      Text(
                        notif['time'],
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: isRead ? Colors.grey.shade500 : AppTheme.brandPrimary,
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    notif['message'],
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: isRead ? Colors.grey.shade600 : Colors.grey.shade800,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📭 WIDGET: Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
            child: Icon(Icons.notifications_off_rounded, size: 50, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 20),
          const Text('No Notifications Yet', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.brandDark)),
          const SizedBox(height: 10),
          Text('We will notify you when you get a match\nor a message.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}