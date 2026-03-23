import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../shared/animations/fade_animation.dart';
import '../../../../shared/widgets/custom_network_image.dart';
import '../../../../shared/widgets/custom_textfield.dart';
import '../../../../shared/widgets/custom_chip.dart';

// ============================================================
// ✏️ EDIT PROFILE SCREEN
// Tabbed edit — Basic Info, About, Preferences
// TODO: Replace dummy data with userProvider (Riverpod)
//       On save → profileRepository.updateProfile(data)
// ============================================================
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {

  // ── Tab controller ────────────────────────────────────────
  late final TabController _tabController;

  // ── Basic Info ────────────────────────────────────────────
  final TextEditingController _firstNameCtrl =
  TextEditingController(text: 'Rahul');
  final TextEditingController _lastNameCtrl =
  TextEditingController(text: 'Rathod');
  final TextEditingController _cityCtrl =
  TextEditingController(text: 'Mumbai');
  final TextEditingController _professionCtrl =
  TextEditingController(text: 'Product Manager');
  final TextEditingController _educationCtrl =
  TextEditingController(text: 'MBA');
  String _selectedGotra = 'Rathod';
  int _heightFeet = 5;
  int _heightInches = 10;

  static const List<String> _gotraList = [
    'Rathod', 'Chavan', 'Pawar', 'Jadhav',
    'Ade', 'Naik', 'Muqayya', 'Gormati',
  ];

  // ── About ─────────────────────────────────────────────────
  final TextEditingController _aboutCtrl = TextEditingController(
    text:
    'Looking for a sincere, family-oriented partner. I love travelling and good food. Family comes first.',
  );

  // ── Preferences ───────────────────────────────────────────
  RangeValues _ageRange = const RangeValues(22, 30);
  RangeValues _heightRange = const RangeValues(150, 170);
  String _preferredCity = 'Any';
  bool _premiumOnly = false;

  static const List<String> _cityOptions = [
    'Any', 'Mumbai', 'Pune', 'Nagpur',
    'Nashik', 'Aurangabad', 'Delhi', 'Bangalore',
  ];

  // ── Photo state ───────────────────────────────────────────
  final List<String> _photos = [
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
  ];

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticUtils.selectionClick();
        setState(() {});
      }
    });

    // Track changes
    for (final c in [
      _firstNameCtrl, _lastNameCtrl, _cityCtrl,
      _professionCtrl, _educationCtrl, _aboutCtrl,
    ]) {
      c.addListener(() => setState(() => _hasChanges = true));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _cityCtrl.dispose();
    _professionCtrl.dispose();
    _educationCtrl.dispose();
    _aboutCtrl.dispose();
    super.dispose();
  }

  // ── Save ──────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_hasChanges) {
      context.pop();
      return;
    }
    HapticUtils.mediumImpact();

    // TODO: profileRepository.updateProfile({...})
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    HapticUtils.heavyImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Profile updated successfully ✓',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
    context.pop();
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.bgScaffold,
      body: SafeArea(
        child: Column(
          children: [

            // ── Header ───────────────────────────────────
            _buildHeader(),

            // ── Tab bar ──────────────────────────────────
            _buildTabBar(),
            const SizedBox(height: 4),

            // ── Tab content ──────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildBasicInfoTab(),
                  _buildAboutTab(),
                  _buildPreferencesTab(),
                ],
              ),
            ),

            // ── Save button ──────────────────────────────
            _buildSaveButton(bottomPadding),
          ],
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              if (_hasChanges) {
                _showDiscardDialog();
              } else {
                context.pop();
              }
            },
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: AppTheme.softShadow,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppTheme.brandDark,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.brandDark,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          // Unsaved changes indicator
          if (_hasChanges)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFFBBF24).withValues(alpha: 0.4),
                ),
              ),
              child: const Text(
                'Unsaved',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFD97706),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Custom Tab Bar ────────────────────────────────────────
  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: AnimatedBuilder(
        animation: _tabController,
        builder: (_, __) {
          return Row(
            children: List.generate(3, (i) {
              final labels = ['Basic Info', 'About', 'Preferences'];
              final isActive = _tabController.index == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _tabController.animateTo(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                    height: 40,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppTheme.brandPrimary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive
                            ? AppTheme.brandPrimary
                            : Colors.grey.shade200,
                      ),
                      boxShadow: isActive
                          ? [BoxShadow(
                        color: AppTheme.brandPrimary
                            .withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        labels[i],
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? Colors.white
                              : Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  // ── TAB 1: Basic Info ─────────────────────────────────────
  Widget _buildBasicInfoTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      physics: const BouncingScrollPhysics(),
      children: [

        // ── Photo section ───────────────────────────────
        FadeAnimation(
          delayInMs: 0,
          child: _buildPhotoSection(),
        ),
        const SizedBox(height: 24),

        // ── Name ────────────────────────────────────────
        FadeAnimation(
          delayInMs: 60,
          child: _EditSection(
            title: 'Name',
            child: Column(
              children: [
                _LabeledField(
                  label: 'FIRST NAME',
                  child: CustomTextField(
                    hintText: 'First name',
                    controller: _firstNameCtrl,
                  ),
                ),
                const SizedBox(height: 14),
                _LabeledField(
                  label: 'LAST NAME',
                  child: CustomTextField(
                    hintText: 'Last name',
                    controller: _lastNameCtrl,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Location & Profession ────────────────────────
        FadeAnimation(
          delayInMs: 120,
          child: _EditSection(
            title: 'Location & Work',
            child: Column(
              children: [
                _LabeledField(
                  label: 'CITY',
                  child: CustomTextField(
                    hintText: 'e.g. Mumbai',
                    controller: _cityCtrl,
                    prefixIcon: Icons.location_city_rounded,
                  ),
                ),
                const SizedBox(height: 14),
                _LabeledField(
                  label: 'PROFESSION',
                  child: CustomTextField(
                    hintText: 'e.g. Software Engineer',
                    controller: _professionCtrl,
                    prefixIcon: Icons.work_outline_rounded,
                  ),
                ),
                const SizedBox(height: 14),
                _LabeledField(
                  label: 'EDUCATION',
                  child: CustomTextField(
                    hintText: 'e.g. B.Tech, MBA',
                    controller: _educationCtrl,
                    prefixIcon: Icons.school_outlined,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Height ───────────────────────────────────────
        FadeAnimation(
          delayInMs: 180,
          child: _EditSection(
            title: 'Height',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppTheme.bgScaffold,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                              initialItem: _heightFeet - 4),
                          itemExtent: 44,
                          onSelectedItemChanged: (i) {
                            HapticUtils.selectionClick();
                            setState(() => _heightFeet = i + 4);
                            setState(() => _hasChanges = true);
                          },
                          children: List.generate(4, (i) => Center(
                            child: Text('${i + 4} ft',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.brandDark,
                                )),
                          )),
                        ),
                      ),
                      Text(':',
                          style: TextStyle(
                              fontSize: 22,
                              color: Colors.grey.shade300)),
                      SizedBox(
                        width: 100,
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                              initialItem: _heightInches),
                          itemExtent: 44,
                          onSelectedItemChanged: (i) {
                            HapticUtils.selectionClick();
                            setState(() => _heightInches = i);
                            setState(() => _hasChanges = true);
                          },
                          children: List.generate(12, (i) => Center(
                            child: Text('$i in',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.brandDark,
                                )),
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    "$_heightFeet'$_heightInches\"",
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.brandPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Gotra ────────────────────────────────────────
        FadeAnimation(
          delayInMs: 240,
          child: _EditSection(
            title: 'Gotra',
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _gotraList.map((g) => CustomChip(
                label: g,
                isSelected: _selectedGotra == g,
                onTap: () {
                  HapticUtils.selectionClick();
                  setState(() {
                    _selectedGotra = g;
                    _hasChanges = true;
                  });
                },
              )).toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ── TAB 2: About ──────────────────────────────────────────
  Widget _buildAboutTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      physics: const BouncingScrollPhysics(),
      children: [
        FadeAnimation(
          delayInMs: 0,
          child: _EditSection(
            title: 'About Me',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: TextField(
                    controller: _aboutCtrl,
                    maxLines: 6,
                    maxLength: 300,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppTheme.brandDark,
                      height: 1.6,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Write a short bio about yourself...',
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                      counterStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tip: Mention your interests, family values, and what you\'re looking for.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Colors.grey.shade400,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── TAB 3: Preferences ────────────────────────────────────
  Widget _buildPreferencesTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      physics: const BouncingScrollPhysics(),
      children: [

        // Age range
        FadeAnimation(
          delayInMs: 0,
          child: _EditSection(
            title: 'Partner Age Range',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_ageRange.start.round()} – ${_ageRange.end.round()} years',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.brandPrimary,
                  ),
                ),
                SliderTheme(
                  data: _sliderTheme(context),
                  child: RangeSlider(
                    values: _ageRange,
                    min: 18, max: 50, divisions: 32,
                    onChanged: (v) {
                      HapticUtils.selectionClick();
                      setState(() { _ageRange = v; _hasChanges = true; });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Height range
        FadeAnimation(
          delayInMs: 80,
          child: _EditSection(
            title: 'Partner Height Range',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_cmToFeet(_heightRange.start.round())} – ${_cmToFeet(_heightRange.end.round())}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.brandPrimary,
                  ),
                ),
                SliderTheme(
                  data: _sliderTheme(context),
                  child: RangeSlider(
                    values: _heightRange,
                    min: 140, max: 190, divisions: 50,
                    onChanged: (v) {
                      HapticUtils.selectionClick();
                      setState(() { _heightRange = v; _hasChanges = true; });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Preferred city
        FadeAnimation(
          delayInMs: 160,
          child: _EditSection(
            title: 'Preferred City',
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _cityOptions.map((city) => CustomChip(
                label: city,
                isSelected: _preferredCity == city,
                onTap: () {
                  HapticUtils.selectionClick();
                  setState(() { _preferredCity = city; _hasChanges = true; });
                },
              )).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Toggles
        FadeAnimation(
          delayInMs: 240,
          child: _EditSection(
            title: 'Other Preferences',
            child: _ToggleTile(
              label: 'Show Premium profiles only',
              subtitle: 'Only see verified premium members',
              value: _premiumOnly,
              onChanged: (v) {
                HapticUtils.selectionClick();
                setState(() { _premiumOnly = v; _hasChanges = true; });
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ── Photo Section ─────────────────────────────────────────
  Widget _buildPhotoSection() {
    return _EditSection(
      title: 'Photos',
      child: SizedBox(
        height: 110,
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          children: [
            ..._photos.asMap().entries.map((entry) {
              return Stack(
                children: [
                  Container(
                    width: 90,
                    height: 110,
                    margin: const EdgeInsets.only(right: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: CustomNetworkImage(
                        imageUrl: entry.value,
                        borderRadius: 14,
                      ),
                    ),
                  ),
                  // Remove button
                  Positioned(
                    top: 4, right: 14,
                    child: GestureDetector(
                      onTap: () {
                        HapticUtils.lightImpact();
                        setState(() {
                          _photos.removeAt(entry.key);
                          _hasChanges = true;
                        });
                      },
                      child: Container(
                        width: 22, height: 22,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 13,
                        ),
                      ),
                    ),
                  ),
                  // Main photo indicator
                  if (entry.key == 0)
                    Positioned(
                      bottom: 6, left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.brandPrimary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Main',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }),

            // Add photo
            GestureDetector(
              onTap: () {
                HapticUtils.lightImpact();
                // TODO: image picker
              },
              child: Container(
                width: 90,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.brandPrimary.withValues(alpha: 0.20),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded,
                        color: AppTheme.brandPrimary.withValues(alpha: 0.50),
                        size: 24),
                    const SizedBox(height: 4),
                    Text(
                      'Add',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        color: AppTheme.brandPrimary.withValues(alpha: 0.50),
                        fontWeight: FontWeight.w600,
                      ),
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

  // ── Save button ───────────────────────────────────────────
  Widget _buildSaveButton(double bottomPad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 10, 20, bottomPad + 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE8395A), Color(0xFFFF6B84)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE8395A).withValues(alpha: 0.30),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _save,
            borderRadius: BorderRadius.circular(18),
            child: const Center(
              child: Text(
                'Save Changes',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Discard dialog ────────────────────────────────────────
  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Discard changes?',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        content: const Text(
          'You have unsaved changes. Are you sure you want to go back?',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Keep Editing',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                color: AppTheme.brandPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: Text(
              'Discard',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────
  SliderThemeData _sliderTheme(BuildContext context) {
    return SliderTheme.of(context).copyWith(
      activeTrackColor: AppTheme.brandPrimary,
      inactiveTrackColor: Colors.grey.shade200,
      thumbColor: AppTheme.brandPrimary,
      overlayColor: AppTheme.brandPrimary.withValues(alpha: 0.12),
      trackHeight: 3,
    );
  }

  String _cmToFeet(int cm) {
    final inches = (cm / 2.54).round();
    return "${inches ~/ 12}'${inches % 12}\"";
  }
}


// ── Reusable edit section ─────────────────────────────────
class _EditSection extends StatelessWidget {
  const _EditSection({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppTheme.brandDark,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}


// ── Labeled field ────────────────────────────────────────
class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade400,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 7),
        child,
      ],
    );
  }
}


// ── Toggle tile ──────────────────────────────────────────
class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String label, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.brandDark,
                )),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: Colors.grey.shade500,
                )),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.brandPrimary,
          ),
        ],
      ),
    );
  }
}