import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 🔥 Humare Premium Lego Blocks
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../shared/animations/fade_animation.dart';

// 🧩 Naye Imported Shared Widgets (Lego Blocks)
import '../../../shared/widgets/premium_match_card.dart';
import '../../../shared/widgets/premium_lock_overlay.dart';
import '../../../shared/widgets/shimmer_loading_grid.dart';
import '../widgets/search_filter_bottom_sheet.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  // ⏳ Shimmer Loading State
  bool _isLoading = true;

  // 🌟 Dummy Data: Top Picks
  final List<Map<String, dynamic>> _topPicks = [
    {'name': 'Kavya', 'age': 25, 'profession': 'Software Engineer', 'image': 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?auto=format&fit=crop&w=400&q=80', 'match': '98%'},
    {'name': 'Anjali', 'age': 26, 'profession': 'UX Designer', 'image': 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?auto=format&fit=crop&w=400&q=80', 'match': '95%'},
    {'name': 'Roshni', 'age': 24, 'profession': 'Doctor', 'image': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80', 'match': '92%'},
    {'name': 'Priya', 'age': 27, 'profession': 'HR Manager', 'image': 'https://images.unsplash.com/photo-1583089892943-e02e52f17d50?auto=format&fit=crop&w=400&q=80', 'match': '89%'},
    {'name': 'Neha', 'age': 25, 'profession': 'Architect', 'image': 'https://images.unsplash.com/photo-1605281317010-fe5ffe798166?auto=format&fit=crop&w=400&q=80', 'match': '85%'},
    {'name': 'Sneha', 'age': 28, 'profession': 'Data Scientist', 'image': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=400&q=80', 'match': '82%'},
  ];

  // 🌟 Dummy Data: Liked You (VIP Section)
  final List<String> _likedYouImages = [
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=400&q=80',
  ];

  @override
  void initState() {
    super.initState();
    // ⏱️ Fake Network Delay (2 Seconds) taaki aapko Shimmer animation dikhe!
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgScaffold,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎩 HEADER SECTION (Title & Filter)
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Matches',
                    style: AppTheme.lightTheme.textTheme.displayLarge?.copyWith(fontSize: 32),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticUtils.mediumImpact();
                      // 🔥 YAHAN UPDATE KIYA HAI: Filter Bottom Sheet Open Hoga
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true, // Zaroori hai taaki height 90% tak ja sake
                        backgroundColor: Colors.transparent, // Rounded corners ke liye
                        builder: (context) => const SearchFilterBottomSheet(),
                      );
                    },
                    // 🔥 UPDATED FILTER ICON (Consistent with Home Notification Icon)
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
                        border: Border.all(color: Colors.grey.shade100, width: 1.5),
                      ),
                      child: const Icon(Icons.tune_rounded, color: AppTheme.brandDark, size: 22),
                    ),
                  ),
                ],
              ),
            ),

            // 📜 SCROLLABLE CONTENT
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // 🔒 SECTION 1: LIKED YOU (Using PremiumLockOverlay)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Liked You', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.brandDark)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber.shade200)),
                            child: const Text('12 New', style: TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber)),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _likedYouImages.length + 1, // +1 for the master unlock card
                        itemBuilder: (context, index) {
                          // Master Unlock Card (Aakhri card)
                          if (index == _likedYouImages.length) {
                            return FadeAnimation(
                              delayInMs: 300,
                              child: Container(
                                width: 160,
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  // 🔥 UPDATED TO UNIVERSAL VIP THEME
                                  gradient: const LinearGradient(colors: [Color(0xFF1E1E1E), Color(0xFF3A3D45)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                  boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
                                  border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5), width: 1.5),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(colors: [const Color(0xFFFFDF00).withOpacity(0.3), const Color(0xFFD4AF37).withOpacity(0.2)]),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.diamond_rounded, color: Color(0xFFFFD700), size: 28)
                                    ),
                                    const SizedBox(height: 15),
                                    const Text('10+ More', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                    const Text('Liked You', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white70)),
                                  ],
                                ),
                              ),
                            );
                          }

                          // 🖼️ Locked Profile Cards
                          return FadeAnimation(
                            delayInMs: 100 + (index * 100),
                            child: Container(
                              width: 160,
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.softShadow),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(_likedYouImages[index], fit: BoxFit.cover),
                                  ),
                                  // 🔥 YAHAN USE KIYA HAI HUMARA LATEST BLOCK: PremiumLockOverlay
                                  PremiumLockOverlay(
                                    title: 'Hidden Profile',
                                    subtitle: 'Upgrade to VIP to reveal.',
                                    useDarkTheme: true,
                                    onUnlockTap: () {
                                      // Ideally points to the VIP Tab or Screen
                                      HapticUtils.heavyImpact();
                                      // Aap chahein toh context.push('/upgrade') laga sakte hain
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 35),

                    // 🌟 SECTION 2: TOP PICKS (Using Shimmer & PremiumMatchCard)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Text('Top Picks For You', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.brandDark)),
                    ),
                    const SizedBox(height: 5),

                    // 🪄 MAGIC HAPPENS HERE: Loading hai toh Shimmer, warna asali grid
                    _isLoading
                        ? const ShimmerLoadingGrid(itemCount: 6)
                        : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(), // Scroll singleChildScrollView karega
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75, // Perfect height/width ratio for cards
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemCount: _topPicks.length,
                      itemBuilder: (context, index) {
                        final match = _topPicks[index];
                        return FadeAnimation(
                          delayInMs: index * 100,
                          // 🔥 YAHAN USE KIYA HAI HUMARA BLOCK: PremiumMatchCard
                          child: PremiumMatchCard(
                            name: match['name'],
                            age: match['age'],
                            imageUrl: match['image'],
                            matchPercentage: match['match'],
                            profession: match['profession'],
                            onTap: () => context.push('/user_detail'),
                            onLike: () {
                              HapticUtils.heavyImpact();
                              // Like animation/logic yahan aayegi
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 120), // Spacer for bottom navigation bar
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