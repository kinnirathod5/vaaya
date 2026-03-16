import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 🔥 Humare Premium Lego Blocks
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../../shared/widgets/custom_network_image.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/custom_chip.dart';
import '../../../shared/animations/fade_animation.dart';

class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({super.key});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  // 🌟 Premium Dummy Biodata (Trustworthy Details)
  final Map<String, dynamic> _profile = {
    'name': 'Priya Rathod',
    'age': 24,
    'height': "5'5\"",
    'gotra': 'Rathod',
    'city': 'Bengaluru, India',
    'profession': 'Senior Software Engineer',
    'company': 'Google India',
    'education': 'B.Tech in Computer Science (IIT Bombay)',
    'income': '₹15L - ₹20L per annum',
    'image': 'https://images.unsplash.com/photo-1583089892943-e02e52f17d50?auto=format&fit=crop&w=800&q=80',
    'matchPercentage': '98%',
    'about': 'I am a simple, ambitious, and family-oriented girl. I love traveling, exploring new cafes, and coding. Looking for someone who balances modern values with our traditional Banjara roots.',
    'father_occupation': 'Business (Textiles)',
    'mother_occupation': 'Homemaker',
    'siblings': '1 Younger Brother (Studying)',
    'family_type': 'Nuclear Family',
    'diet': 'Vegetarian',
    'drink_smoke': 'Never',
    'hobbies': ['Traveling', 'Photography', 'Badminton', 'Reading', 'Coding'],
    'isVerified': true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgScaffold,
      body: Stack(
        children: [
          // ==========================================
          // 1. SCROLLABLE MAGAZINE CONTENT (Sliver UI)
          // ==========================================
          CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              // 🖼️ The Immersive Hero Header
              SliverAppBar(
                expandedHeight: 450,
                stretch: true,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: GestureDetector(
                  onTap: () {
                    HapticUtils.lightImpact();
                    if (context.canPop()) context.pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GlassContainer(
                      blur: 10, opacity: 0.3,
                      borderRadius: BorderRadius.circular(50),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ),
                actions: [
                  GestureDetector(
                    onTap: () => HapticUtils.mediumImpact(),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GlassContainer(
                        blur: 10, opacity: 0.3,
                        borderRadius: BorderRadius.circular(50),
                        child: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomNetworkImage(
                        imageUrl: _profile['image'],
                        borderRadius: 0,
                      ),
                      Positioned(
                        bottom: -1, left: 0, right: 0,
                        height: 150,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter, end: Alignment.bottomCenter,
                              colors: [Colors.transparent, AppTheme.bgScaffold.withOpacity(0.8), AppTheme.bgScaffold],
                              stops: const [0.0, 0.6, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 📄 The Biodata Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderAndBadges(),
                      const SizedBox(height: 25),
                      _buildQuickStats(),
                      const SizedBox(height: 30),
                      _buildTrustBox(),
                      const SizedBox(height: 30),
                      _buildSectionTitle('About Me'),
                      const SizedBox(height: 10),
                      Text(
                        _profile['about'],
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.grey.shade600, height: 1.6),
                      ),
                      const SizedBox(height: 30),
                      _buildDetailCard('Education & Career', Icons.work_outline_rounded, [
                        {'label': 'Profession', 'value': _profile['profession']},
                        {'label': 'Company', 'value': _profile['company']},
                        {'label': 'Education', 'value': _profile['education']},
                        {'label': 'Annual Income', 'value': _profile['income']},
                      ]),
                      const SizedBox(height: 20),
                      _buildDetailCard('Family Details', Icons.family_restroom_rounded, [
                        {'label': 'Father', 'value': _profile['father_occupation']},
                        {'label': 'Mother', 'value': _profile['mother_occupation']},
                        {'label': 'Siblings', 'value': _profile['siblings']},
                        {'label': 'Family Type', 'value': _profile['family_type']},
                      ]),
                      const SizedBox(height: 20),
                      _buildDetailCard('Lifestyle', Icons.self_improvement_rounded, [
                        {'label': 'Diet', 'value': _profile['diet']},
                        {'label': 'Drinking & Smoking', 'value': _profile['drink_smoke']},
                      ]),
                      const SizedBox(height: 30),
                      _buildSectionTitle('Interests & Hobbies'),
                      const SizedBox(height: 15),
                      Wrap(
                        spacing: 10, runSpacing: 10,
                        children: (_profile['hobbies'] as List<String>).map((hobby) {
                          return CustomChip(label: hobby, isSelected: false);
                        }).toList(),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ==========================================
          // 2. FLOATING ACTION BAR (Glassmorphism)
          // ==========================================
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(25, 15, 25, 30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    // 🔥 FIX: BorderLine ko BorderSide se replace kiya hai
                    border: Border(top: BorderSide(color: Colors.grey.shade200)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => HapticUtils.mediumImpact(),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: AppTheme.softShadow,
                          ),
                          child: const Icon(Icons.star_border_rounded, color: Colors.amber, size: 24),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticUtils.heavyImpact();
                          },
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [AppTheme.brandPrimary, Color(0xFFFF5E7E)]),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [BoxShadow(color: AppTheme.brandPrimary.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text('Send Interest', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAndBadges() {
    return FadeAnimation(
      delayInMs: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  '${_profile['name']}, ${_profile['age']}',
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.brandDark, height: 1.2),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AppTheme.brandPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                child: Text('${_profile['matchPercentage']} Match', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.brandPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '${_profile['height']} • ${_profile['gotra']} • ${_profile['city']}',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return FadeAnimation(
      delayInMs: 200,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: AppTheme.softShadow),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem(Icons.height_rounded, 'Height', _profile['height']),
            Container(width: 1, height: 40, color: Colors.grey.shade200),
            _statItem(Icons.work_outline_rounded, 'Job', 'Engineer'),
            Container(width: 1, height: 40, color: Colors.grey.shade200),
            _statItem(Icons.location_on_outlined, 'City', 'Bengaluru'),
          ],
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.brandPrimary, size: 22),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.brandDark)),
        Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 10, color: Colors.grey.shade500)),
      ],
    );
  }

  Widget _buildTrustBox() {
    return FadeAnimation(
      delayInMs: 300,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.green.shade400, shape: BoxShape.circle),
              child: const Icon(Icons.security_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Verified Profile', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                  Text('Mobile, Photo & Govt ID verified by AI', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.green.shade700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return FadeAnimation(
      delayInMs: 400,
      child: Text(
        title,
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.brandDark),
      ),
    );
  }

  Widget _buildDetailCard(String title, IconData icon, List<Map<String, String>> details) {
    return FadeAnimation(
      delayInMs: 500,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.brandPrimary, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.brandDark)),
              ],
            ),
            const SizedBox(height: 15),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 15),
            ...details.map((detail) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(detail['label']!, style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                    ),
                    const Text(':   ', style: TextStyle(color: Colors.grey)),
                    Expanded(
                      child: Text(detail['value']!, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppTheme.brandDark, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}