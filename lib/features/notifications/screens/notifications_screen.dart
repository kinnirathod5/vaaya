import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/custom_toast.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../shared/animations/fade_animation.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/premium_avatar.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/shimmer_loading_grid.dart';

// ============================================================
// 🔔 NOTIFICATIONS SCREEN
// All app notifications — grouped by Today / Earlier
// TODO: Replace dummy data with notificationsProvider (Riverpod)
//       Real-time via Firestore snapshots or FCM
// ============================================================
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {

  // ── Dummy Data ────────────────────────────────────────────
  // TODO: notificationsProvider.notifications se replace karo
  final List<Map<String, dynamic>> _notifications = [
    // Today
    {
      'id': 'n1',
      'type': 'interest',       // interest, match, view, message, system
      'title': 'New Interest',
      'body': 'Priya Rathod sent you an interest request.',
      'time': '2m ago',
      'isRead': false,
      'isToday': true,
      'image': 'https://images.unsplash.com/photo-1583089892943-e02e52f17d50?auto=format&fit=crop&w=200&q=80',
      'actionRoute': '/interests',
    },
    {
      'id': 'n2',
      'type': 'match',
      'title': 'It\'s a Match! 🎉',
      'body': 'You and Anjali Chavan both accepted each other\'s interest.',
      'time': '18m ago',
      'isRead': false,
      'isToday': true,
      'image': 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?auto=format&fit=crop&w=200&q=80',
      'actionRoute': '/chat_detail',
    },
    {
      'id': 'n3',
      'type': 'view',
      'title': 'Profile View',
      'body': 'Kavya Desai viewed your profile.',
      'time': '1h ago',
      'isRead': false,
      'isToday': true,
      'image': 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?auto=format&fit=crop&w=200&q=80',
      'actionRoute': '/user_detail',
    },
    {
      'id': 'n4',
      'type': 'message',
      'title': 'New Message',
      'body': 'Sneha Pawar: "Han ji, bilkul! Sunday ko milte hain 😊"',
      'time': '3h ago',
      'isRead': true,
      'isToday': true,
      'image': 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&w=200&q=80',
      'actionRoute': '/chat_detail',
    },
    // Earlier
    {
      'id': 'n5',
      'type': 'system',
      'title': 'Profile Tip',
      'body': 'Add more photos to get 2x more profile views.',
      'time': 'Yesterday',
      'isRead': true,
      'isToday': false,
      'image': null,
      'actionRoute': '/edit_profile',
    },
    {
      'id': 'n6',
      'type': 'interest',
      'title': 'New Interest',
      'body': 'Roshni Kulkarni sent you an interest request.',
      'time': '2 days ago',
      'isRead': true,
      'isToday': false,
      'image': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      'actionRoute': '/interests',
    },
    {
      'id': 'n7',
      'type': 'view',
      'title': '3 People Viewed You',
      'body': 'Your profile got 3 new views today.',
      'time': '3 days ago',
      'isRead': true,
      'isToday': false,
      'image': null,
      'actionRoute': '/dashboard',
    },
    {
      'id': 'n8',
      'type': 'system',
      'title': 'Complete Your Profile',
      'body': 'Your profile is 72% complete. Complete it to get more matches.',
      'time': '5 days ago',
      'isRead': true,
      'isToday': false,
      'image': null,
      'actionRoute': '/edit_profile',
    },
  ];

  bool _isLoading = true;

  // ── Computed ──────────────────────────────────────────────
  List<Map<String, dynamic>> get _todayNotifs =>
      _notifications.where((n) => n['isToday'] as bool).toList();

  List<Map<String, dynamic>> get _earlierNotifs =>
      _notifications.where((n) => !(n['isToday'] as bool)).toList();

  int get _unreadCount =>
      _notifications.where((n) => !(n['isRead'] as bool)).length;

  // ── Lifecycle ─────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  // ── Handlers ──────────────────────────────────────────────
  void _onTap(Map<String, dynamic> notif) {
    HapticUtils.lightImpact();
    // Mark as read
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == notif['id']);
      if (index != -1) _notifications[index]['isRead'] = true;
    });
    // Navigate
    final route = notif['actionRoute'] as String?;
    if (route != null && route.isNotEmpty) context.push(route);
  }

  void _markAllRead() {
    HapticUtils.mediumImpact();
    setState(() {
      for (final n in _notifications) { n['isRead'] = true; }
    });
    CustomToast.success(context, 'All notifications marked as read');
  }

  void _deleteNotification(String id) {
    HapticUtils.mediumImpact();
    setState(() => _notifications.removeWhere((n) => n['id'] == id));
    if (mounted) CustomToast.info(context, 'Notification removed');
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    Widget body;
    if (_isLoading) {
      body = const ShimmerLoadingGrid(mode: ShimmerMode.list, itemCount: 5);
    } else if (_notifications.isEmpty) {
      body = EmptyStateWidget.noNotifications();
    } else {
      final todayUnread = _todayNotifs
          .where((n) => !(n['isRead'] as bool))
          .length;

      body = ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 24 + bottomPadding),
        children: [
          // Today
          if (_todayNotifs.isNotEmpty) ...[
            SectionHeader(
              title: 'Today',
              badge: todayUnread > 0 ? todayUnread : null,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            ),
            ..._todayNotifs.asMap().entries.map((e) => FadeAnimation(
              delayInMs: e.key * 60,
              child: _NotifTile(
                notif: e.value,
                onTap: () => _onTap(e.value),
                onDelete: () => _deleteNotification(e.value['id']),
              ),
            )),
            const SizedBox(height: 8),
          ],

          // Earlier
          if (_earlierNotifs.isNotEmpty) ...[
            const SectionHeader(
              title: 'Earlier',
              padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
            ),
            ..._earlierNotifs.asMap().entries.map((e) => FadeAnimation(
              delayInMs: 200 + e.key * 60,
              child: _NotifTile(
                notif: e.value,
                onTap: () => _onTap(e.value),
                onDelete: () => _deleteNotification(e.value['id']),
              ),
            )),
          ],
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bgScaffold,
      appBar: CustomAppBar(
        title: 'Notifications',
        badge: _unreadCount > 0 ? _unreadCount : null,
        subtitle: _unreadCount > 0
            ? '$_unreadCount unread notifications'
            : 'All caught up!',
        actions: _unreadCount > 0 ? [_buildMarkAllReadButton()] : null,
      ),
      body: body,
    );
  }

  // ── Mark all read pill button (passed to CustomAppBar.actions) ─
  Widget _buildMarkAllReadButton() {
    return GestureDetector(
      onTap: _markAllRead,
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppTheme.brandPrimary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.brandPrimary.withValues(alpha: 0.15),
          ),
        ),
        child: const Text(
          'Mark all read',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.brandPrimary,
          ),
        ),
      ),
    );
  }
}


// ── Notification Tile ─────────────────────────────────────────
class _NotifTile extends StatelessWidget {
  const _NotifTile({
    required this.notif,
    required this.onTap,
    required this.onDelete,
  });

  final Map<String, dynamic> notif;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  // Icon + color per type
  static const Map<String, Map<String, dynamic>> _typeConfig = {
    'interest': {'icon': Icons.favorite_rounded,      'color': Color(0xFFE8395A)},
    'match':    {'icon': Icons.people_rounded,         'color': Color(0xFF7C3AED)},
    'view':     {'icon': Icons.visibility_rounded,     'color': Color(0xFF2563EB)},
    'message':  {'icon': Icons.chat_bubble_rounded,    'color': Color(0xFF16A34A)},
    'system':   {'icon': Icons.info_outline_rounded,   'color': Color(0xFFD97706)},
  };

  @override
  Widget build(BuildContext context) {
    final bool isRead    = notif['isRead'] as bool;
    final String type    = notif['type'] as String;
    final config         = _typeConfig[type] ?? _typeConfig['system']!;
    final Color color    = config['color'] as Color;
    final IconData icon  = config['icon'] as IconData;
    final String? image  = notif['image'] as String?;

    return Dismissible(
      key: Key(notif['id'] as String),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade400,
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 22),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : const Color(0xFFFFF5F7),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isRead
                  ? Colors.grey.shade100
                  : AppTheme.brandPrimary.withValues(alpha: 0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isRead ? 0.03 : 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Avatar / Icon ──────────────────────────
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Photo (PremiumAvatar) or fallback icon
                  image != null
                      ? PremiumAvatar(imageUrl: image, size: 48)
                      : Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),

                  // Type icon badge overlaid on photo
                  if (image != null)
                    Positioned(
                      bottom: -2, right: -2,
                      child: Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Icon(icon, color: Colors.white, size: 10),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),

              // ── Text ──────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notif['title'] as String,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: isRead
                                  ? FontWeight.w600
                                  : FontWeight.w800,
                              color: AppTheme.brandDark,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Unread dot
                        if (!isRead)
                          Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.brandPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notif['body'] as String,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        height: 1.45,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notif['time'] as String,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        color: Colors.grey.shade400,
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
    );
  }
}