import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // 🔥 NAYA IMPORT: Navigation ke liye

// 🔥 Humare Premium Lego Blocks
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../shared/widgets/custom_network_image.dart';
import '../../../shared/animations/fade_animation.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 🌟 Dummy Data for Received Requests
  final List<Map<String, dynamic>> _receivedRequests = [
    {
      'id': '1',
      'name': 'Priya',
      'age': 24,
      'profession': 'Software Engineer',
      'city': 'Bengaluru',
      'image': 'https://images.unsplash.com/photo-1583089892943-e02e52f17d50?auto=format&fit=crop&w=400&q=80',
      'time': '2h ago',
    },
    {
      'id': '2',
      'name': 'Anjali',
      'age': 26,
      'profession': 'UX Designer',
      'city': 'Mumbai',
      'image': 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?auto=format&fit=crop&w=400&q=80',
      'time': '5h ago',
    },
  ];

  // 🌟 Dummy Data for Sent Requests
  final List<Map<String, dynamic>> _sentRequests = [
    {
      'id': '3',
      'name': 'Neha',
      'age': 25,
      'profession': 'Marketing Head',
      'city': 'Pune',
      'image': 'https://images.unsplash.com/photo-1605281317010-fe5ffe798166?auto=format&fit=crop&w=400&q=80',
      'status': 'Pending',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
            // 🎩 Custom Premium Header
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
              child: Text(
                'Interests',
                style: AppTheme.lightTheme.textTheme.displayLarge?.copyWith(fontSize: 32),
              ),
            ),

            // 🎛️ Premium Custom Tab Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Container(
                height: 50,
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(25)),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                  labelColor: AppTheme.brandPrimary,
                  unselectedLabelColor: Colors.grey.shade500,
                  labelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14),
                  onTap: (index) => HapticUtils.selectionClick(),
                  tabs: [
                    Tab(text: 'Received (${_receivedRequests.length})'),
                    Tab(text: 'Sent (${_sentRequests.length})'),
                  ],
                ),
              ),
            ),

            // 📄 Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildReceivedTab(),
                  _buildSentTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: RECEIVED REQUESTS
  // ==========================================
  Widget _buildReceivedTab() {
    if (_receivedRequests.isEmpty) {
      return _buildEmptyState('No new interests received yet.', Icons.favorite_border_rounded);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 15, bottom: 100, left: 20, right: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: _receivedRequests.length,
      itemBuilder: (context, index) {
        final request = _receivedRequests[index];
        return FadeAnimation(
          delayInMs: index * 100,
          child: _buildRequestCard(
            profile: request,
            isReceived: true,
          ),
        );
      },
    );
  }

  // ==========================================
  // TAB 2: SENT REQUESTS
  // ==========================================
  Widget _buildSentTab() {
    if (_sentRequests.isEmpty) {
      return _buildEmptyState('You haven\'t sent any interests yet.', Icons.send_rounded);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 15, bottom: 100, left: 20, right: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: _sentRequests.length,
      itemBuilder: (context, index) {
        final request = _sentRequests[index];
        return FadeAnimation(
          delayInMs: index * 100,
          child: _buildRequestCard(
            profile: request,
            isReceived: false,
          ),
        );
      },
    );
  }

  // 🖼️ PREMIUM REQUEST CARD WIDGET
  Widget _buildRequestCard({required Map<String, dynamic> profile, required bool isReceived}) {
    // 🔥 YAHAN UPDATE KIYA HAI: GestureDetector add kiya navigation ke liye
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        context.push('/user_detail'); // User detail screen open karega
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          children: [
            // Profile Image with online indicator
            Stack(
              children: [
                CustomNetworkImage(
                  imageUrl: profile['image']!,
                  width: 70,
                  height: 70,
                  borderRadius: 16,
                ),
                Positioned(
                  bottom: -2, right: -2,
                  child: Container(
                    width: 16, height: 16,
                    decoration: BoxDecoration(
                      color: Colors.green.shade400,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 15),

            // Profile Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${profile['name']}, ${profile['age']}',
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.brandDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${profile['profession']} • ${profile['city']}',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isReceived ? 'Received ${profile['time']}' : 'Status: ${profile['status']}',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isReceived ? AppTheme.brandPrimary : Colors.orange.shade400
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            if (isReceived) ...[
              // Decline Button
              GestureDetector(
                onTap: () {
                  HapticUtils.mediumImpact();
                  // Decline logic here
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded, color: Colors.grey.shade600, size: 20),
                ),
              ),
              const SizedBox(width: 10),
              // Accept Button
              GestureDetector(
                onTap: () {
                  HapticUtils.heavyImpact();
                  // Accept logic here
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.brandPrimary,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppTheme.brandPrimary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
                ),
              ),
            ] else ...[
              // Cancel Sent Request Button
              GestureDetector(
                onTap: () {
                  HapticUtils.lightImpact();
                  // Cancel logic here
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Cancel', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // 📭 EMPTY STATE WIDGET
  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
            child: Icon(icon, size: 40, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 15),
          Text(
            message,
            style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}