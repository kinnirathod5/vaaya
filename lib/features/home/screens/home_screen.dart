import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// 🔥 Humare Premium Lego Blocks
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../shared/animations/fade_animation.dart';
import '../../../shared/widgets/custom_network_image.dart';
import '../../../shared/widgets/premium_avatar.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/glass_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ==========================================
  // 🎮 CONTROLLERS
  // ==========================================
  // Carousel Controller (For Spotlight Matches)
  final PageController _pageController = PageController(viewportFraction: 0.85);

  // Radar Animation Controller (For Active Now pulse)
  late AnimationController _radarController;

  // ==========================================
  // 🌟 DUMMY DATA
  // ==========================================
  final List<Map<String, dynamic>> _dailyMatches = [
    {
      'name': 'Priya Rathod',
      'age': 24,
      'profession': 'Software Engineer',
      'image': 'https://images.unsplash.com/photo-1583089892943-e02e52f17d50?auto=format&fit=crop&w=800&q=80',
      'match': '98%'
    },
    {
      'name': 'Anjali Chavan',
      'age': 26,
      'profession': 'UX Designer',
      'image': 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?auto=format&fit=crop&w=800&q=80',
      'match': '92%'
    },
    {
      'name': 'Sneha Pawar',
      'age': 25,
      'profession': 'Doctor',
      'image': 'https://images.unsplash.com/photo-1605281317010-fe5ffe798166?auto=format&fit=crop&w=800&q=80',
      'match': '89%'
    },
  ];

  final List<Map<String, dynamic>> _premiumMatches = [
    {
      'name': 'Kavya',
      'age': 25,
      'city': 'Mumbai',
      'image': 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?auto=format&fit=crop&w=400&q=80'
    },
    {
      'name': 'Roshni',
      'age': 27,
      'city': 'Pune',
      'image': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80'
    },
  ];

  final List<Map<String, dynamic>> _successStories = [
    {
      'couple': 'Rahul & Priya',
      'quote': 'We met on Banjara Vivah and it was magic!',
      'image': 'https://images.unsplash.com/photo-1529636798458-92182e662485?auto=format&fit=crop&w=800&q=80'
    },
    {
      'couple': 'Amit & Neha',
      'quote': 'Thank you for finding my soulmate.',
      'image': 'https://images.unsplash.com/photo-1623091410901-00e2d268901f?auto=format&fit=crop&w=800&q=80'
    },
  ];

  // ==========================================
  // 🔄 LIFECYCLE METHODS
  // ==========================================
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark
      ),
    );
    // 2-second looping animation for the green radar dot
    _radarController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2)
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _radarController.dispose();
    super.dispose();
  }

  // ==========================================
  // 📱 MAIN BUILD METHOD
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgScaffold,
      body: Stack(
        children: [
          // 🌌 AMBIENT VIBRANT BACKGROUND (Glowing Circles)
          Positioned(
            top: -100,
            left: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.brandPrimary.withOpacity(0.15)
                  )
              ),
            ),
          ),
          Positioned(
            top: 250,
            right: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blueAccent.withOpacity(0.1)
                  )
              ),
            ),
          ),

          // 📜 MAIN SCROLLABLE CONTENT
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 120), // Bottom Nav Spacer
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // 🎩 HEADER
                    _buildHeader(context),
                    const SizedBox(height: 30),

                    // 🟢 ACTIVE NOW (Replaced Activity Update at top)
                    _buildActiveNow(),
                    const SizedBox(height: 30),

                    // 🌟 SPOTLIGHT MATCHES (Carousel)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: SectionHeader(title: 'Spotlight Matches ✨', actionText: 'Curated'),
                    ),
                    const SizedBox(height: 15),
                    _buildEliteCarousel(),
                    const SizedBox(height: 30),

                    // 📅 DAILY MATCHES (Large Cards)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SectionHeader(
                          title: 'Daily Matches',
                          actionText: 'See All',
                          onActionTap: () {}
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildDailyMatches(),
                    const SizedBox(height: 30),

                    // 👑 VIP PREMIUM BANNER (Black Metal Card)
                    _buildBlackMetalVIPCard(),
                    const SizedBox(height: 30),

                    // 💎 PREMIUM MATCHES (Golden Cards)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SectionHeader(
                          title: 'Premium Matches',
                          actionText: 'Unlock',
                          onActionTap: () {}
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildPremiumMatches(),
                    const SizedBox(height: 30),

                    // 📊 RECENT ACTIVITY (Moved Down Here)
                    _buildActivityUpdate(),
                    const SizedBox(height: 30),

                    // 💍 SUCCESS STORIES
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SectionHeader(
                          title: 'Success Stories',
                          actionText: 'Read More',
                          onActionTap: () {}
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildSuccessStories(),
                    const SizedBox(height: 30),

                    // 📿 THOUGHT OF THE DAY
                    _buildThoughtOfTheDay(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 🧩 WIDGET BUILDERS
  // ==========================================

  // --- 🎩 HEADER ---
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              context.push('/my_profile');
            },
            child: const PremiumAvatar(
              imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=150&q=80',
              size: 45,
              isOnline: true,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    'Good Morning 🌤️',
                    style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)
                ),
                Text(
                    'Rahul Rathod',
                    style: TextStyle(fontFamily: 'Poppins', color: AppTheme.brandDark, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5)
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticUtils.mediumImpact();
              context.push('/notifications');
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
                border: Border.all(color: Colors.grey.shade100, width: 1.5),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_rounded, color: AppTheme.brandDark, size: 22),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          color: const Color(0xFFE94057),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2)
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 🟢 ACTIVE NOW (With Radar & Horizontal Avatars) ---
  Widget _buildActiveNow() {
    return FadeAnimation(
      delayInMs: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text('Active Now', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.brandDark)),
                const SizedBox(width: 10),
                // Live Radar Pulse
                AnimatedBuilder(
                    animation: _radarController,
                    builder: (context, child) {
                      return Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.green,
                            boxShadow: [BoxShadow(color: Colors.green.withOpacity(1 - _radarController.value), blurRadius: 8 * _radarController.value, spreadRadius: 4 * _radarController.value)]
                        ),
                      );
                    }
                ),
                const SizedBox(width: 5),
                const Text('Live', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 95,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _dailyMatches.length + 1, // +1 for the blurred "Likes You" circle
              itemBuilder: (context, index) {
                // Blur Master Card at index 0
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Colors.amber, Colors.orange])),
                            child: Stack(
                                children: [
                                  Container(
                                    width: 60, height: 60,
                                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), image: const DecorationImage(image: NetworkImage('https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=crop&w=200&q=80'), fit: BoxFit.cover)),
                                    child: ClipOval(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), child: Container(color: Colors.white.withOpacity(0.1)))),
                                  ),
                                  Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.amber.shade700, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)), child: const Icon(Icons.lock_rounded, size: 10, color: Colors.white))),
                                ]
                            )
                        ),
                        const SizedBox(height: 6),
                        Text('Likes You', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w900, color: Colors.amber.shade700)),
                      ],
                    ),
                  );
                }

                // Normal Online Profiles
                final match = _dailyMatches[index - 1];
                return GestureDetector(
                  onTap: () {
                    HapticUtils.lightImpact();
                    context.push('/user_detail');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        PremiumAvatar(imageUrl: match['image'], size: 66, isOnline: true),
                        const SizedBox(height: 6),
                        Text(match['name'].toString().split(' ')[0], style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.brandDark)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- 🌟 ELITE CAROUSEL ---
  Widget _buildEliteCarousel() {
    List<Map<String, dynamic>> spotlightMatches = [
      {
        'name': 'Anjali Rathod', 'age': '25', 'loc': 'Mumbai',
        'prof': 'Software Engineer', 'match': '98%',
        'img': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=80'
      },
      {
        'name': 'Pooja Chauhan', 'age': '24', 'loc': 'Pune',
        'prof': 'Doctor', 'match': '95%',
        'img': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80'
      },
    ];

    return FadeAnimation(
      delayInMs: 300,
      child: SizedBox(
        height: 420,
        child: PageView.builder(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          itemCount: spotlightMatches.length,
          itemBuilder: (context, index) {
            final match = spotlightMatches[index];

            return AnimatedBuilder(
              animation: _pageController,
              builder: (context, child) {
                double value = 1.0;
                if (_pageController.position.haveDimensions) {
                  value = _pageController.page! - index;
                  value = (1 - (value.abs() * 0.12)).clamp(0.85, 1.0);
                } else {
                  value = index == 0 ? 1.0 : 0.85;
                }
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 30, right: 8, left: 8),
                child: GestureDetector(
                  onTap: () {
                    HapticUtils.mediumImpact();
                    context.push('/user_detail');
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))
                            ],
                            image: DecorationImage(
                                image: NetworkImage(match['img']),
                                fit: BoxFit.cover
                            )
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                                bottom: 0, left: 0, right: 0,
                                child: Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(30),
                                            bottomRight: Radius.circular(30)
                                        ),
                                        gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [Colors.black.withOpacity(0.9), Colors.transparent]
                                        )
                                    )
                                )
                            ),
                            Positioned(
                                top: 20, left: 20,
                                child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                    child: Row(
                                        children: [
                                          const Icon(Icons.local_fire_department_rounded, color: AppTheme.brandPrimary, size: 16),
                                          const SizedBox(width: 5),
                                          Text(
                                              '${match['match']} Match',
                                              style: const TextStyle(fontFamily: 'Poppins', color: AppTheme.brandPrimary, fontWeight: FontWeight.bold, fontSize: 12)
                                          )
                                        ]
                                    )
                                )
                            ),
                            Positioned(
                              bottom: 40, left: 20, right: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${match['name']}, ${match['age']}',
                                      style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                                          child: Row(
                                              children: [
                                                const Icon(Icons.work_outline_rounded, color: Colors.white, size: 14),
                                                const SizedBox(width: 5),
                                                Text(
                                                    '${match['prof']}',
                                                    style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 11)
                                                )
                                              ]
                                          )
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                                          child: Row(
                                              children: [
                                                const Icon(Icons.location_on_outlined, color: Colors.white, size: 14),
                                                const SizedBox(width: 5),
                                                Text(
                                                    '${match['loc']}',
                                                    style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 11)
                                                )
                                              ]
                                          )
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: -20, right: 20,
                        child: Row(
                          children: [
                            Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]
                                ),
                                child: const Icon(Icons.close_rounded, color: Colors.grey, size: 28)
                            ),
                            const SizedBox(width: 15),
                            Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [AppTheme.brandPrimary, Color(0xFFFF5E7E)]),
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: AppTheme.brandPrimary.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))]
                                ),
                                child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 32)
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- 📅 DAILY MATCHES ---
  Widget _buildDailyMatches() {
    return FadeAnimation(
      delayInMs: 400,
      child: SizedBox(
        height: 280,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _dailyMatches.length,
          itemBuilder: (context, index) {
            final match = _dailyMatches[index];
            return GestureDetector(
              onTap: () {
                HapticUtils.lightImpact();
                context.push('/user_detail');
              },
              child: Container(
                width: 200,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppTheme.softShadow
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomNetworkImage(
                        imageUrl: match['image'],
                        borderRadius: 24
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                            stops: const [0.5, 1.0]
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12, left: 12,
                      child: GlassContainer(
                        blur: 10,
                        opacity: 0.3,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        borderRadius: BorderRadius.circular(12),
                        child: Text(
                            '${match['match']} Match',
                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 15, left: 15, right: 15,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${match['name']}, ${match['age']}',
                              style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                          ),
                          const SizedBox(height: 2),
                          Text(
                              match['profession'],
                              style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white70)
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- 👑 BLACK METAL VIP CARD ---
  Widget _buildBlackMetalVIPCard() {
    return FadeAnimation(
      delayInMs: 500,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E1E1E), Color(0xFF2A2D34), Color(0xFF000000)]
              ),
              border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5), width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
              ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(12)
                      ),
                      child: const Icon(Icons.diamond_rounded, color: Color(0xFFFFD700), size: 24)
                  ),
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: const Text(
                          'ELITE',
                          style: TextStyle(fontFamily: 'Poppins', color: Color(0xFFFFD700), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)
                      )
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                  'Unlock Premium',
                  style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)
              ),
              const SizedBox(height: 5),
              const Text(
                  'Get contact numbers & stand out.',
                  style: TextStyle(fontFamily: 'Poppins', color: Colors.white60, fontSize: 12, height: 1.5)
              ),
              const SizedBox(height: 20),
              SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                      onPressed: () {
                        HapticUtils.heavyImpact();
                        context.push('/settings');
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      child: const Text(
                          'Upgrade Now',
                          style: TextStyle(fontFamily: 'Poppins', color: AppTheme.brandDark, fontWeight: FontWeight.w900, fontSize: 15)
                      )
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 💎 PREMIUM MATCHES ---
  Widget _buildPremiumMatches() {
    return FadeAnimation(
      delayInMs: 600,
      child: SizedBox(
        height: 180,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _premiumMatches.length,
          itemBuilder: (context, index) {
            final match = _premiumMatches[index];
            return GestureDetector(
              onTap: () {
                HapticUtils.lightImpact();
                context.push('/user_detail');
              },
              child: Container(
                width: 130,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFD700), width: 2),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomNetworkImage(
                        imageUrl: match['image'],
                        borderRadius: 18
                    ),
                    Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                                stops: const [0.5, 1.0]
                            )
                        )
                    ),
                    Positioned(
                      bottom: 12, left: 12, right: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.diamond_rounded, color: Color(0xFFFFD700), size: 14),
                              const SizedBox(width: 4),
                              Expanded(
                                  child: Text(
                                      match['name'],
                                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                      overflow: TextOverflow.ellipsis
                                  )
                              ),
                            ],
                          ),
                          Text(
                              '${match['age']} • ${match['city']}',
                              style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, color: Colors.white70)
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- 📊 RECENT ACTIVITY (Moved down here) ---
  Widget _buildActivityUpdate() {
    return FadeAnimation(
      delayInMs: 700,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GestureDetector(
          onTap: () {
            HapticUtils.selectionClick();
            context.push('/dashboard');
          },
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppTheme.brandPrimary.withOpacity(0.1), Colors.white]
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.brandPrimary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  height: 35,
                  child: Stack(
                    children: [
                      Positioned(left: 0, child: _tinyAvatar(_dailyMatches[0]['image'])),
                      Positioned(left: 15, child: _tinyAvatar(_dailyMatches[1]['image'])),
                      Positioned(left: 30, child: _tinyAvatar(_dailyMatches[2]['image'])),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.visibility_rounded, size: 16, color: AppTheme.brandPrimary),
                          SizedBox(width: 6),
                          Text(
                              'Recent Profile Visits',
                              style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.brandDark)
                          ),
                        ],
                      ),
                      Text(
                          '5 people viewed your profile.',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey.shade600)
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.brandPrimary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tinyAvatar(String url) {
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2)
      ),
      child: CustomNetworkImage(imageUrl: url, width: 30, height: 30, borderRadius: 15),
    );
  }

  // --- 💍 SUCCESS STORIES ---
  Widget _buildSuccessStories() {
    return FadeAnimation(
      delayInMs: 800,
      child: SizedBox(
        height: 160,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _successStories.length,
          itemBuilder: (context, index) {
            final story = _successStories[index];
            return Container(
              width: 280,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.softShadow
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomNetworkImage(
                      imageUrl: story['image'],
                      borderRadius: 20
                  ),
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.2)]
                          )
                      )
                  ),
                  Positioned(
                    left: 20, top: 20, bottom: 20, right: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.format_quote_rounded, color: Colors.white54, size: 30),
                        const SizedBox(height: 5),
                        Text(
                            story['quote'],
                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white, fontStyle: FontStyle.italic)
                        ),
                        const SizedBox(height: 10),
                        Text(
                            story['couple'],
                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.brandPrimary)
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- 📿 THOUGHT OF THE DAY ---
  Widget _buildThoughtOfTheDay() {
    return FadeAnimation(
      delayInMs: 900,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: const Color(0xFFFAF2E9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE8D0B3))
          ),
          child: Column(
            children: [
              const Icon(Icons.format_quote_rounded, color: Color(0xFFD6A060), size: 30),
              const SizedBox(height: 10),
              const Text(
                  '"A successful marriage requires falling in love many times, always with the same person."',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontStyle: FontStyle.italic, color: Color(0xFF6B4E2D))
              ),
              const SizedBox(height: 10),
              Text(
                  '— Banjara Vivah',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF6B4E2D).withOpacity(0.6))
              ),
            ],
          ),
        ),
      ),
    );
  }
}