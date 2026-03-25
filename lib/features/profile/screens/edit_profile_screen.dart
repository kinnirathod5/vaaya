import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../shared/animations/fade_animation.dart';
import '../../../../shared/widgets/custom_network_image.dart';
import '../../../../shared/widgets/custom_textfield.dart';

// ============================================================
// ✏️ EDIT PROFILE SCREEN — Redesigned
// 6 tabs — Personal · Career · Location · Family · Lifestyle · Partner Pref
//
// Improvements:
//   • Icon + label tab bar — premium pill style
//   • Each section in a white card — cleaner visual grouping
//   • Floating animated Save button with loading state
//   • Photo section — full width, larger cards, reorder hint
//   • Animated "Unsaved" badge with pulse
//   • Chip selectors with check icon on selected
//   • Consistent section spacing & card radii
//   • Partner Pref — improved info banner, better slider labels
//
// TODO: Replace with userProvider (Riverpod)
//       On save → profileRepository.updateProfile(data)
// ============================================================
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {

  late final TabController _tabController;
  bool _hasChanges = false;
  bool _isSaving   = false;

  // ── Tab 1: Personal ──────────────────────────────────────
  final _firstNameCtrl  = TextEditingController(text: 'Rahul');
  final _lastNameCtrl   = TextEditingController(text: 'Rathod');
  String _maritalStatus = 'Never Married';
  String _selectedGotra = 'Rathod';
  String _motherTongue  = 'Lambadi';
  String _horoscope     = 'Not specified';
  int _heightFeet = 5, _heightInches = 10;
  bool _isManglik = false;
  List<String> _languagesKnown = ['Lambadi', 'Hindi'];

  static const List<String> _maritalOptions  = ['Never Married', 'Divorced', 'Widowed', 'Separated'];
  static const List<String> _gotraList       = ['Rathod', 'Chavan', 'Pawar', 'Jadhav', 'Ade', 'Naik', 'Muqayya', 'Gormati'];
  static const List<String> _languageOptions = ['Lambadi', 'Hindi', 'Marathi', 'Telugu', 'Kannada', 'English', 'Gujarati', 'Tamil'];
  static const List<String> _horoscopeOptions = [
    'Not specified', 'Mesh (Aries)', 'Vrishabh (Taurus)', 'Mithun (Gemini)',
    'Kark (Cancer)', 'Simha (Leo)', 'Kanya (Virgo)', 'Tula (Libra)',
    'Vrishchik (Scorpio)', 'Dhanu (Sagittarius)', 'Makar (Capricorn)',
    'Kumbh (Aquarius)', 'Meen (Pisces)',
  ];

  // ── Tab 2: Career ────────────────────────────────────────
  final _professionCtrl = TextEditingController(text: 'Product Manager');
  final _educationCtrl  = TextEditingController(text: 'MBA');
  String _workSector    = 'Private Sector';
  String _annualIncome  = '5–10 LPA';

  static const List<String> _workSectorOptions = [
    'Private Sector', 'Government / PSU', 'Business / Self-Employed',
    'Defence / Police', 'Agriculture', 'Not Working',
  ];
  static const List<String> _incomeOptions = [
    'Below 2 LPA', '2–5 LPA', '5–10 LPA', '10–20 LPA',
    '20–50 LPA', 'Above 50 LPA', 'Not disclosed',
  ];

  // ── Tab 3: Location ──────────────────────────────────────
  final _cityCtrl        = TextEditingController(text: 'Mumbai');
  final _nativePlaceCtrl = TextEditingController(text: 'Nagpur');
  String _country = 'India';
  String _state   = 'Maharashtra';

  static const List<String> _countryOptions = ['India', 'USA', 'UK', 'Canada', 'Australia', 'UAE', 'Singapore', 'New Zealand'];
  static const List<String> _stateOptions   = ['Maharashtra', 'Rajasthan', 'Gujarat', 'Madhya Pradesh', 'Karnataka', 'Telangana', 'Andhra Pradesh', 'Delhi', 'Tamil Nadu', 'Uttar Pradesh', 'Other'];

  // ── Tab 4: Family ────────────────────────────────────────
  String _familyType       = 'Joint Family';
  String _fatherOccupation = 'Business';
  String _motherOccupation = 'Not Working';
  int    _brothersCount    = 0;
  int    _sistersCount     = 0;

  static const List<String> _familyTypeOptions        = ['Joint Family', 'Nuclear Family'];
  static const List<String> _parentOccupationOptions  = ['Business', 'Government Employee', 'Farmer', 'Retired', 'Private Job', 'Not Working', 'Passed Away'];

  // ── Tab 5: Lifestyle ─────────────────────────────────────
  String _diet     = 'Vegetarian';
  String _smoking  = 'Non-Smoker';
  String _drinking = 'Non-Drinker';
  List<String> _interests = ['Travelling', 'Cooking'];
  List<String> _hobbies   = ['Reading', 'Music'];

  static const List<String> _dietOptions     = ['Vegetarian', 'Non-Vegetarian', 'Eggetarian', 'Jain'];
  static const List<String> _smokingOptions  = ['Non-Smoker', 'Occasionally', 'Smoker'];
  static const List<String> _drinkingOptions = ['Non-Drinker', 'Occasionally', 'Regular'];
  static const List<String> _interestOptions = [
    'Travelling', 'Cooking', 'Music', 'Fitness', 'Reading',
    'Photography', 'Dancing', 'Cricket', 'Gardening',
    'Painting', 'Yoga', 'Movies', 'Trekking', 'Gaming',
  ];
  static const List<String> _hobbyOptions = [
    'Reading', 'Music', 'Cricket', 'Cooking', 'Painting',
    'Photography', 'Dancing', 'Gardening', 'Writing', 'Chess',
    'Swimming', 'Cycling', 'Sketching', 'Knitting',
  ];

  final _aboutCtrl = TextEditingController(
    text: 'Looking for a sincere, family-oriented partner.',
  );

  // ── Tab 6: Partner Prefs ─────────────────────────────────
  RangeValues _ageRange    = const RangeValues(22, 32);
  RangeValues _heightRange = const RangeValues(150, 175);
  String _prefCity          = 'Any';
  String _prefMaritalStatus = 'Never Married';
  String _prefEducation     = 'Any';
  String _prefWorkSector    = 'Any';
  String _prefIncome        = 'Any';
  String _prefDiet          = 'Any';
  List<String> _prefGotra   = [];
  bool _prefSameGotra    = false;
  bool _prefManglikOnly  = false;
  bool _prefVerifiedOnly = false;
  bool _premiumOnly      = false;

  final _partnerDescCtrl = TextEditingController(text: '');

  static const List<String> _prefCityOptions      = ['Any', 'Mumbai', 'Pune', 'Nagpur', 'Nashik', 'Aurangabad', 'Delhi', 'Bangalore', 'Hyderabad'];
  static const List<String> _prefEducationOptions = ['Any', 'Below 10th', '10th Pass', '12th Pass', 'Diploma', 'Graduate', 'Post Graduate', 'Doctorate'];
  static const List<String> _prefIncomeOptions    = ['Any', 'Below 2 LPA', '2–5 LPA', '5–10 LPA', '10–20 LPA', '20–50 LPA', 'Above 50 LPA'];

  // Photos
  final List<String> _photos = [
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
  ];

  // ── Tab config ────────────────────────────────────────────
  static const _tabData = [
    {'label': 'Personal',    'icon': Icons.person_outline_rounded},
    {'label': 'Career',      'icon': Icons.work_outline_rounded},
    {'label': 'Location',    'icon': Icons.location_on_outlined},
    {'label': 'Family',      'icon': Icons.diversity_1_rounded},
    {'label': 'Lifestyle',   'icon': Icons.spa_outlined},
    {'label': 'Partner',     'icon': Icons.favorite_border_rounded},
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticUtils.selectionClick();
        setState(() {});
      }
    });
    for (final c in [
      _firstNameCtrl, _lastNameCtrl, _professionCtrl,
      _educationCtrl, _cityCtrl, _nativePlaceCtrl,
      _aboutCtrl, _partnerDescCtrl,
    ]) {
      c.addListener(() => setState(() => _hasChanges = true));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameCtrl.dispose(); _lastNameCtrl.dispose();
    _professionCtrl.dispose(); _educationCtrl.dispose();
    _cityCtrl.dispose(); _nativePlaceCtrl.dispose();
    _aboutCtrl.dispose(); _partnerDescCtrl.dispose();
    super.dispose();
  }

  // ── Save ──────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_hasChanges) { context.pop(); return; }
    HapticUtils.mediumImpact();
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() { _isSaving = false; _hasChanges = false; });
    HapticUtils.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
          SizedBox(width: 10),
          Text('Profile updated successfully',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        ],
      ),
      backgroundColor: AppTheme.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
    context.pop();
  }

  void _markChanged() => setState(() => _hasChanges = true);

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.bgScaffold,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 14),
            _buildTabBar(),
            const SizedBox(height: 4),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildPersonalTab(),
                  _buildCareerTab(),
                  _buildLocationTab(),
                  _buildFamilyTab(),
                  _buildLifestyleTab(),
                  _buildPartnerPrefTab(),
                ],
              ),
            ),
            _buildSaveBtn(bottomPad),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Row(
        children: [
          // Back
          GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              _hasChanges ? _showDiscardDialog() : context.pop();
            },
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.white, shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: AppTheme.softShadow,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppTheme.brandDark, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit Profile', style: TextStyle(
                  fontFamily: 'Cormorant Garamond',
                  fontSize: 26, fontWeight: FontWeight.w700,
                  color: AppTheme.brandDark, letterSpacing: -0.3, height: 1.1,
                )),
                Text('Keep your info up to date', style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 11,
                  color: Color(0xFF9CA3AF),
                )),
              ],
            ),
          ),
          // Unsaved badge
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _hasChanges
                ? Container(
              key: const ValueKey('unsaved'),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFE083)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6, height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD97706),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('Unsaved', style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFD97706),
                  )),
                ],
              ),
            )
                : const SizedBox.shrink(key: ValueKey('saved')),
          ),
        ],
      ),
    );
  }

  // ── Tab bar ───────────────────────────────────────────────
  Widget _buildTabBar() {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (_, __) => SizedBox(
        height: 46,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const BouncingScrollPhysics(),
          itemCount: _tabData.length,
          itemBuilder: (_, i) {
            final active = _tabController.index == i;
            final tab = _tabData[i];
            return GestureDetector(
              onTap: () => _tabController.animateTo(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: active ? AppTheme.brandPrimary : Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: active ? AppTheme.brandPrimary : Colors.grey.shade200,
                  ),
                  boxShadow: active
                      ? [BoxShadow(
                      color: AppTheme.brandPrimary.withValues(alpha: 0.28),
                      blurRadius: 12, offset: const Offset(0, 4))]
                      : AppTheme.softShadow,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: 14,
                      color: active ? Colors.white : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 6),
                    Text(tab['label'] as String, style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : Colors.grey.shade500,
                    )),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TAB 1 — PERSONAL
  // ═══════════════════════════════════════════════════════════
  Widget _buildPersonalTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      physics: const BouncingScrollPhysics(),
      children: [

        // Photos
        FadeAnimation(delayInMs: 0, child: _buildPhotoSection()),
        const SizedBox(height: 14),

        // Name
        FadeAnimation(delayInMs: 40, child: _Card(
          label: 'FULL NAME',
          icon: Icons.badge_outlined,
          child: Column(children: [
            _LabelField(label: 'First Name', child: CustomTextField(
                hintText: 'First name', controller: _firstNameCtrl)),
            const SizedBox(height: 12),
            _LabelField(label: 'Last Name', child: CustomTextField(
                hintText: 'Last name', controller: _lastNameCtrl)),
          ]),
        )),
        const SizedBox(height: 12),

        // Marital status
        FadeAnimation(delayInMs: 70, child: _Card(
          label: 'MARITAL STATUS',
          icon: Icons.ring_volume_outlined,
          child: _ChipGrid(
            options: _maritalOptions, selected: [_maritalStatus],
            singleSelect: true,
            onChanged: (v) { setState(() { _maritalStatus = v.first; _hasChanges = true; }); },
          ),
        )),
        const SizedBox(height: 12),

        // Gotra
        FadeAnimation(delayInMs: 100, child: _Card(
          label: 'GOTRA',
          icon: Icons.diversity_3_outlined,
          child: _ChipGrid(
            options: _gotraList, selected: [_selectedGotra],
            singleSelect: true,
            onChanged: (v) { setState(() { _selectedGotra = v.first; _hasChanges = true; }); },
          ),
        )),
        const SizedBox(height: 12),

        // Height
        FadeAnimation(delayInMs: 130, child: _Card(
          label: 'HEIGHT',
          icon: Icons.height_rounded,
          child: _buildHeightPicker(),
        )),
        const SizedBox(height: 12),

        // Horoscope
        FadeAnimation(delayInMs: 160, child: _Card(
          label: 'HOROSCOPE (RASHI)',
          icon: Icons.auto_awesome_outlined,
          child: Column(children: [
            _StyledDropdown(
              value: _horoscope, options: _horoscopeOptions,
              onChanged: (v) { setState(() { _horoscope = v!; _hasChanges = true; }); },
            ),
            const SizedBox(height: 12),
            _ToggleRow(
              label: 'Manglik',
              subtitle: 'Mark if the person is Manglik',
              value: _isManglik,
              onChanged: (v) { setState(() { _isManglik = v; _hasChanges = true; }); },
            ),
          ]),
        )),
        const SizedBox(height: 12),

        // Languages
        FadeAnimation(delayInMs: 190, child: _Card(
          label: 'LANGUAGES',
          icon: Icons.translate_rounded,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _SubLabel('Languages Known'),
            const SizedBox(height: 10),
            _ChipGrid(
              options: _languageOptions, selected: _languagesKnown,
              singleSelect: false,
              onChanged: (v) { setState(() { _languagesKnown = v; _hasChanges = true; }); },
            ),
            const SizedBox(height: 14),
            _SubLabel('Mother Tongue'),
            const SizedBox(height: 10),
            _ChipGrid(
              options: _languageOptions, selected: [_motherTongue],
              singleSelect: true,
              onChanged: (v) { setState(() { _motherTongue = v.first; _hasChanges = true; }); },
            ),
          ]),
        )),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildHeightPicker() {
    return Column(
      children: [
        // Display
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$_heightFeet",
                    style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 42,
                      fontWeight: FontWeight.w900, color: AppTheme.brandPrimary,
                    ),
                  ),
                  TextSpan(
                    text: " ft  ",
                    style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 18,
                      fontWeight: FontWeight.w600, color: Colors.grey.shade400,
                    ),
                  ),
                  TextSpan(
                    text: "$_heightInches",
                    style: const TextStyle(
                      fontFamily: 'Poppins', fontSize: 42,
                      fontWeight: FontWeight.w900, color: AppTheme.brandPrimary,
                    ),
                  ),
                  TextSpan(
                    text: " in",
                    style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 18,
                      fontWeight: FontWeight.w600, color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Pickers
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: AppTheme.bgScaffold,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(child: CupertinoPicker(
                scrollController: FixedExtentScrollController(initialItem: _heightFeet - 4),
                itemExtent: 44,
                onSelectedItemChanged: (i) {
                  HapticUtils.selectionClick();
                  setState(() { _heightFeet = i + 4; _hasChanges = true; });
                },
                children: List.generate(4, (i) => Center(
                  child: Text('${i + 4} ft', style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 17,
                    fontWeight: FontWeight.w700, color: AppTheme.brandDark,
                  )),
                )),
              )),
              Container(width: 1, height: 80, color: Colors.grey.shade200),
              Expanded(child: CupertinoPicker(
                scrollController: FixedExtentScrollController(initialItem: _heightInches),
                itemExtent: 44,
                onSelectedItemChanged: (i) {
                  HapticUtils.selectionClick();
                  setState(() { _heightInches = i; _hasChanges = true; });
                },
                children: List.generate(12, (i) => Center(
                  child: Text('$i in', style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 17,
                    fontWeight: FontWeight.w700, color: AppTheme.brandDark,
                  )),
                )),
              )),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TAB 2 — CAREER
  // ═══════════════════════════════════════════════════════════
  Widget _buildCareerTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      physics: const BouncingScrollPhysics(),
      children: [

        FadeAnimation(delayInMs: 0, child: _Card(
          label: 'EDUCATION',
          icon: Icons.school_outlined,
          child: _LabelField(
            label: 'Degree / Qualification',
            child: CustomTextField(
              hintText: 'e.g. MBA, B.Tech, CA',
              controller: _educationCtrl,
              prefixIcon: Icons.school_outlined,
            ),
          ),
        )),
        const SizedBox(height: 12),

        FadeAnimation(delayInMs: 50, child: _Card(
          label: 'OCCUPATION',
          icon: Icons.work_outline_rounded,
          child: _LabelField(
            label: 'Job Title / Profession',
            child: CustomTextField(
              hintText: 'e.g. Software Engineer, Doctor',
              controller: _professionCtrl,
              prefixIcon: Icons.work_outline_rounded,
            ),
          ),
        )),
        const SizedBox(height: 12),

        FadeAnimation(delayInMs: 100, child: _Card(
          label: 'WORK SECTOR',
          icon: Icons.business_outlined,
          child: _ChipGrid(
            options: _workSectorOptions, selected: [_workSector],
            singleSelect: true,
            onChanged: (v) { setState(() { _workSector = v.first; _hasChanges = true; }); },
          ),
        )),
        const SizedBox(height: 12),

        FadeAnimation(delayInMs: 150, child: _Card(
          label: 'ANNUAL INCOME',
          icon: Icons.currency_rupee_rounded,
          child: _ChipGrid(
            options: _incomeOptions, selected: [_annualIncome],
            singleSelect: true,
            onChanged: (v) { setState(() { _annualIncome = v.first; _hasChanges = true; }); },
          ),
        )),
        const SizedBox(height: 20),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TAB 3 — LOCATION
  // ═══════════════════════════════════════════════════════════
  Widget _buildLocationTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      physics: const BouncingScrollPhysics(),
      children: [

        FadeAnimation(delayInMs: 0, child: _Card(
          label: 'CURRENT LOCATION',
          icon: Icons.location_on_outlined,
          child: Column(children: [
            _LabelField(label: 'Country', child: _StyledDropdown(
              value: _country, options: _countryOptions,
              onChanged: (v) { setState(() { _country = v!; _hasChanges = true; }); },
            )),
            const SizedBox(height: 12),
            _LabelField(label: 'State', child: _StyledDropdown(
              value: _state, options: _stateOptions,
              onChanged: (v) { setState(() { _state = v!; _hasChanges = true; }); },
            )),
            const SizedBox(height: 12),
            _LabelField(label: 'City', child: CustomTextField(
              hintText: 'e.g. Mumbai',
              controller: _cityCtrl,
              prefixIcon: Icons.location_city_rounded,
            )),
          ]),
        )),
        const SizedBox(height: 12),

        FadeAnimation(delayInMs: 80, child: _Card(
          label: 'NATIVE PLACE',
          icon: Icons.home_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your original hometown or ancestral village',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey.shade400)),
              const SizedBox(height: 10),
              CustomTextField(
                hintText: 'e.g. Nagpur, Tandur, Bidar',
                controller: _nativePlaceCtrl,
                prefixIcon: Icons.home_outlined,
              ),
            ],
          ),
        )),
        const SizedBox(height: 20),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TAB 4 — FAMILY
  // ═══════════════════════════════════════════════════════════
  Widget _buildFamilyTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      physics: const BouncingScrollPhysics(),
      children: [

        FadeAnimation(delayInMs: 0, child: _Card(
          label: 'FAMILY TYPE',
          icon: Icons.home_work_outlined,
          child: _ChipGrid(
            options: _familyTypeOptions, selected: [_familyType],
            singleSelect: true,
            onChanged: (v) { setState(() { _familyType = v.first; _hasChanges = true; }); },
          ),
        )),
        const SizedBox(height: 12),

        FadeAnimation(delayInMs: 60, child: _Card(
          label: "PARENTS' OCCUPATION",
          icon: Icons.people_outline_rounded,
          child: Column(children: [
            _LabelField(label: "Father's Occupation", child: _StyledDropdown(
              value: _fatherOccupation, options: _parentOccupationOptions,
              onChanged: (v) { setState(() { _fatherOccupation = v!; _hasChanges = true; }); },
            )),
            const SizedBox(height: 12),
            _LabelField(label: "Mother's Occupation", child: _StyledDropdown(
              value: _motherOccupation, options: _parentOccupationOptions,
              onChanged: (v) { setState(() { _motherOccupation = v!; _hasChanges = true; }); },
            )),
          ]),
        )),
        const SizedBox(height: 12),

        FadeAnimation(delayInMs: 120, child: _Card(
          label: 'SIBLINGS',
          icon: Icons.group_outlined,
          child: Row(children: [
            Expanded(child: _CounterTile(
              label: 'Brothers', icon: Icons.boy_rounded,
              value: _brothersCount,
              onChanged: (v) { setState(() { _brothersCount = v; _hasChanges = true; }); },
            )),
            const SizedBox(width: 12),
            Expanded(child: _CounterTile(
              label: 'Sisters', icon: Icons.girl_rounded,
              value: _sistersCount,
              onChanged: (v) { setState(() { _sistersCount = v; _hasChanges = true; }); },
            )),
          ]),
        )),
        const SizedBox(height: 20),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TAB 5 — LIFESTYLE
  // ═══════════════════════════════════════════════════════════
  Widget _buildLifestyleTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      physics: const BouncingScrollPhysics(),
      children: [

        FadeAnimation(delayInMs: 0, child: _Card(
          label: 'DIET',
          icon: Icons.restaurant_outlined,
          child: _ChipGrid(
            options: _dietOptions, selected: [_diet],
            singleSelect: true,
            onChanged: (v) { setState(() { _diet = v.first; _hasChanges = true; }); },
          ),
        )),
        const SizedBox(height: 12),

        FadeAnimation(delayInMs: 50, child: _Card(
          label: 'HABITS',
          icon: Icons.self_improvement_outlined,
          child: Column(children: [
            _LabelField(label: 'Smoking', child: _ChipGrid(
              options: _smokingOptions, selected: [_smoking],
              singleSelect: true, compact: true,
              onChanged: (v) { setState(() { _smoking = v.first; _hasChanges = true; }); },
            )),
            const SizedBox(height: 14),
            _LabelField(label: 'Drinking', child: _ChipGrid(
              options: _drinkingOptions, selected: [_drinking],
              singleSelect: true, compact: true,
              onChanged: (v) { setState(() { _drinking = v.first; _hasChanges = true; }); },
            )),
          ]),
        )),
        const SizedBox(height: 12),

        FadeAnimation(delayInMs: 100, child: _Card(
          label: 'INTERESTS & HOBBIES',
          icon: Icons.interests_outlined,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _SubLabel('Interests  ·  Select all that apply'),
            const SizedBox(height: 10),
            _ChipGrid(
              options: _interestOptions, selected: _interests,
              singleSelect: false,
              onChanged: (v) { setState(() { _interests = v; _hasChanges = true; }); },
            ),
            const SizedBox(height: 16),
            _SubLabel('Hobbies  ·  Select all that apply'),
            const SizedBox(height: 10),
            _ChipGrid(
              options: _hobbyOptions, selected: _hobbies,
              singleSelect: false,
              onChanged: (v) { setState(() { _hobbies = v; _hasChanges = true; }); },
            ),
          ]),
        )),
        const SizedBox(height: 12),

        FadeAnimation(delayInMs: 150, child: _Card(
          label: 'ABOUT ME',
          icon: Icons.notes_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('This will be visible on your profile',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey.shade400)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.bgScaffold,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _aboutCtrl,
                  maxLines: 5, maxLength: 300,
                  style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 13,
                    color: AppTheme.brandDark, height: 1.6,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Write about yourself, your values, and what you seek...',
                    hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14),
                    counterStyle: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey.shade400),
                  ),
                ),
              ),
            ],
          ),
        )),
        const SizedBox(height: 20),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TAB 6 — PARTNER PREFERENCES
  // ═══════════════════════════════════════════════════════════
  Widget _buildPartnerPrefTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      physics: const BouncingScrollPhysics(),
      children: [

        // Info banner
        FadeAnimation(delayInMs: 0, child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          decoration: BoxDecoration(
            color: AppTheme.brandPrimary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.brandPrimary.withValues(alpha: 0.14)),
          ),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.brandPrimary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tune_rounded, size: 18, color: AppTheme.brandPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(
                'Set your preferences to get more compatible match suggestions.',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 12,
                    color: AppTheme.brandDark.withValues(alpha: 0.70), height: 1.5),
              )),
            ],
          ),
        )),

        // Age range
        FadeAnimation(delayInMs: 30, child: _Card(
          label: 'AGE RANGE',
          icon: Icons.cake_outlined,
          child: _SliderSection(
            minLabel: '${_ageRange.start.round()} yrs',
            maxLabel: '${_ageRange.end.round()} yrs',
            child: SliderTheme(
              data: _sliderTheme(context),
              child: RangeSlider(
                values: _ageRange, min: 18, max: 55, divisions: 37,
                onChanged: (v) => setState(() { _ageRange = v; _hasChanges = true; }),
              ),
            ),
          ),
        )),
        const SizedBox(height: 12),

        // Height range
        FadeAnimation(delayInMs: 60, child: _Card(
          label: 'HEIGHT RANGE',
          icon: Icons.height_rounded,
          child: _SliderSection(
            minLabel: _cmToFeet(_heightRange.start.round()),
            maxLabel: _cmToFeet(_heightRange.end.round()),
            child: SliderTheme(
              data: _sliderTheme(context),
              child: RangeSlider(
                values: _heightRange, min: 140, max: 190, divisions: 50,
                onChanged: (v) => setState(() { _heightRange = v; _hasChanges = true; }),
              ),
            ),
          ),
        )),
        const SizedBox(height: 12),

        FadeAnimation(delayInMs: 90, child: _Card(
          label: 'MARITAL STATUS',
          icon: Icons.ring_volume_outlined,
          child: _ChipGrid(
            options: ['Any', 'Never Married', 'Divorced', 'Widowed'],
            selected: [_prefMaritalStatus], singleSelect: true,
            onChanged: (v) => setState(() { _prefMaritalStatus = v.first; _hasChanges = true; }),
          ),
        )),
        const SizedBox(height: 12),

        FadeAnimation(delayInMs: 120, child: _Card(
          label: 'MINIMUM EDUCATION',
          icon: Icons.school_outlined,
          child: _ChipGrid(
            options: _prefEducationOptions, selected: [_prefEducation],
            singleSelect: true,
            onChanged: (v) => setState(() { _prefEducation = v.first; _hasChanges = true; }),
          ),
        )),
        const SizedBox(height: 12),

        FadeAnimation(delayInMs: 150, child: _Card(
          label: 'WORK SECTOR',
          icon: Icons.business_outlined,
          child: _ChipGrid(
            options: ['Any', 'Private Sector', 'Government / PSU', 'Business / Self-Employed', 'Defence / Police'],
            selected: [_prefWorkSector], singleSelect: true,
            onChanged: (v) => setState(() { _prefWorkSector = v.first; _hasChanges = true; }),
          ),
        )),
        const SizedBox(height: 12),

        FadeAnimation(delayInMs: 180, child: _Card(
          label: 'ANNUAL INCOME (MIN)',
          icon: Icons.currency_rupee_rounded,
          child: _ChipGrid(
            options: _prefIncomeOptions, selected: [_prefIncome],
            singleSelect: true,
            onChanged: (v) => setState(() { _prefIncome = v.first; _hasChanges = true; }),
          ),
        )),
        const SizedBox(height: 12),

        FadeAnimation(delayInMs: 210, child: _Card(
          label: 'PREFERRED CITY',
          icon: Icons.location_city_rounded,
          child: _ChipGrid(
            options: _prefCityOptions, selected: [_prefCity],
            singleSelect: true,
            onChanged: (v) => setState(() { _prefCity = v.first; _hasChanges = true; }),
          ),
        )),
        const SizedBox(height: 12),

        FadeAnimation(delayInMs: 240, child: _Card(
          label: 'PREFERRED GOTRA',
          icon: Icons.diversity_3_outlined,
          child: Column(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Leave empty to accept any gotra',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey.shade400)),
            ),
            const SizedBox(height: 10),
            _ChipGrid(
              options: _gotraList, selected: _prefGotra,
              singleSelect: false,
              onChanged: (v) => setState(() { _prefGotra = v; _hasChanges = true; }),
            ),
            const SizedBox(height: 12),
            _ToggleRow(
              label: 'Same Gotra Acceptable',
              subtitle: 'Turn off to exclude same-gotra matches',
              value: _prefSameGotra,
              onChanged: (v) => setState(() { _prefSameGotra = v; _hasChanges = true; }),
            ),
          ]),
        )),
        const SizedBox(height: 12),

        FadeAnimation(delayInMs: 270, child: _Card(
          label: 'DIET PREFERENCE',
          icon: Icons.restaurant_outlined,
          child: _ChipGrid(
            options: ['Any', 'Vegetarian', 'Non-Vegetarian', 'Eggetarian', 'Jain'],
            selected: [_prefDiet], singleSelect: true,
            onChanged: (v) => setState(() { _prefDiet = v.first; _hasChanges = true; }),
          ),
        )),
        const SizedBox(height: 12),

        FadeAnimation(delayInMs: 300, child: _Card(
          label: 'SPECIAL FILTERS',
          icon: Icons.verified_outlined,
          child: Column(children: [
            _ToggleRow(
              label: 'Manglik Profiles Only',
              subtitle: 'Show only Manglik matches',
              value: _prefManglikOnly,
              onChanged: (v) => setState(() { _prefManglikOnly = v; _hasChanges = true; }),
            ),
            const SizedBox(height: 10),
            _ToggleRow(
              label: 'Verified Profiles Only',
              subtitle: 'Show only identity-verified profiles',
              value: _prefVerifiedOnly,
              onChanged: (v) => setState(() { _prefVerifiedOnly = v; _hasChanges = true; }),
            ),
            const SizedBox(height: 10),
            _ToggleRow(
              label: 'Premium Members Only',
              subtitle: 'Show only premium subscribed profiles',
              value: _premiumOnly,
              onChanged: (v) => setState(() { _premiumOnly = v; _hasChanges = true; }),
            ),
          ]),
        )),
        const SizedBox(height: 12),

        FadeAnimation(delayInMs: 330, child: _Card(
          label: 'IDEAL PARTNER DESCRIPTION',
          icon: Icons.edit_note_rounded,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Optional — shown on your profile to matches',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey.shade400)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.bgScaffold,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _partnerDescCtrl,
                maxLines: 5, maxLength: 300,
                style: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 13,
                  color: AppTheme.brandDark, height: 1.6,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Looking for someone who values our Banjara traditions...',
                  hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                  counterStyle: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey.shade400),
                ),
              ),
            ),
          ]),
        )),
        const SizedBox(height: 20),
      ],
    );
  }

  // ── Photo section ─────────────────────────────────────────
  Widget _buildPhotoSection() {
    return _Card(
      label: 'PHOTOS',
      icon: Icons.photo_library_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('First photo is your main profile photo',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey.shade400)),
          const SizedBox(height: 12),
          SizedBox(
            height: 116,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                ..._photos.asMap().entries.map((e) => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 86, height: 116,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: e.key == 0
                            ? Border.all(color: AppTheme.brandPrimary, width: 2)
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: CustomNetworkImage(imageUrl: e.value, borderRadius: 14),
                      ),
                    ),
                    // Main badge
                    if (e.key == 0)
                      Positioned(
                        bottom: 6, left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.brandPrimary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Main', style: TextStyle(
                            fontFamily: 'Poppins', fontSize: 8,
                            fontWeight: FontWeight.w800, color: Colors.white,
                          )),
                        ),
                      ),
                    // Delete
                    Positioned(
                      top: -6, right: 4,
                      child: GestureDetector(
                        onTap: () {
                          HapticUtils.lightImpact();
                          setState(() { _photos.removeAt(e.key); _hasChanges = true; });
                        },
                        child: Container(
                          width: 22, height: 22,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: const Icon(Icons.close_rounded, size: 13, color: Colors.redAccent),
                        ),
                      ),
                    ),
                  ],
                )),
                // Add button
                GestureDetector(
                  onTap: () => HapticUtils.lightImpact(),
                  child: Container(
                    width: 86, height: 116,
                    decoration: BoxDecoration(
                      color: AppTheme.brandPrimary.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.brandPrimary.withValues(alpha: 0.22),
                        width: 1.5,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.brandPrimary.withValues(alpha: 0.10),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.add_rounded,
                              color: AppTheme.brandPrimary.withValues(alpha: 0.70), size: 20),
                        ),
                        const SizedBox(height: 6),
                        Text('Add Photo', style: TextStyle(
                          fontFamily: 'Poppins', fontSize: 10,
                          color: AppTheme.brandPrimary.withValues(alpha: 0.60),
                          fontWeight: FontWeight.w600,
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Save button ───────────────────────────────────────────
  Widget _buildSaveBtn(double bottomPad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 10, 20, bottomPad + 16),
      child: GestureDetector(
        onTap: _isSaving ? null : _save,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity, height: 54,
          decoration: BoxDecoration(
            gradient: _hasChanges
                ? AppTheme.brandGradient
                : LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade300]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: _hasChanges ? AppTheme.primaryGlow : [],
          ),
          child: Center(
            child: _isSaving
                ? const SizedBox(
              width: 22, height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _hasChanges ? Icons.check_rounded : Icons.check_circle_rounded,
                  color: Colors.white, size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  _hasChanges ? 'Save Changes' : 'All Saved',
                  style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 15,
                    fontWeight: FontWeight.w700, color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
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
      trackHeight: 3.5,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
    );
  }

  String _cmToFeet(int cm) {
    final inches = (cm / 2.54).round();
    return "${inches ~/ 12}'${inches % 12}\"";
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        title: const Text('Discard changes?', style: TextStyle(
          fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 17,
          color: AppTheme.brandDark,
        )),
        content: Text(
          'You have unsaved changes. If you go back now, they will be lost.',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey.shade500, height: 1.55),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Editing', style: TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: AppTheme.brandPrimary,
            )),
          ),
          TextButton(
            onPressed: () { Navigator.pop(context); context.pop(); },
            child: Text('Discard', style: TextStyle(
              fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: Colors.grey.shade500,
            )),
          ),
        ],
      ),
    );
  }
}


// ══════════════════════════════════════════════════════════════
// PRIVATE WIDGETS
// ══════════════════════════════════════════════════════════════

// Card wrapper with label + icon header
class _Card extends StatelessWidget {
  const _Card({required this.label, required this.icon, required this.child});
  final String label;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: AppTheme.brandPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 14, color: AppTheme.brandPrimary),
                ),
                const SizedBox(width: 8),
                Text(label, style: TextStyle(
                  fontFamily: 'Poppins', fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade500,
                  letterSpacing: 1.0,
                )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }
}

// Labeled field
class _LabelField extends StatelessWidget {
  const _LabelField({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(
          fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600,
          color: Colors.grey.shade500,
        )),
        const SizedBox(height: 7),
        child,
      ],
    );
  }
}

// Sub-section label
class _SubLabel extends StatelessWidget {
  const _SubLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(
      fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w700,
      color: Colors.grey.shade500,
    ));
  }
}

// Chip grid — single or multi select with check icon
class _ChipGrid extends StatelessWidget {
  const _ChipGrid({
    required this.options, required this.selected,
    required this.singleSelect, required this.onChanged,
    this.compact = false,
  });

  final List<String> options;
  final List<String> selected;
  final bool singleSelect;
  final bool compact;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: compact ? 8 : 9,
      runSpacing: compact ? 8 : 9,
      children: options.map((opt) {
        final isSelected = selected.contains(opt);
        return GestureDetector(
          onTap: () {
            HapticUtils.selectionClick();
            List<String> next;
            if (singleSelect) {
              next = [opt];
            } else {
              next = List.from(selected);
              isSelected ? next.remove(opt) : next.add(opt);
            }
            onChanged(next);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 14,
              vertical: compact ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.brandPrimary : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppTheme.brandPrimary : Colors.grey.shade200,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(Icons.check_rounded, color: Colors.white, size: 12),
                  const SizedBox(width: 4),
                ],
                Text(opt, style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: compact ? 11 : 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Styled dropdown
class _StyledDropdown extends StatelessWidget {
  const _StyledDropdown({required this.value, required this.options, required this.onChanged});
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.bgScaffold,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: options.contains(value) ? value : options.first,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade400, size: 22),
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.brandDark),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(14),
          onChanged: onChanged,
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
        ),
      ),
    );
  }
}

// Toggle row
class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.label, required this.subtitle, required this.value, required this.onChanged});
  final String label, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppTheme.bgScaffold,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 13,
                fontWeight: FontWeight.w700, color: AppTheme.brandDark,
              )),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(
                fontFamily: 'Poppins', fontSize: 11, color: Colors.grey.shade400,
              )),
            ],
          )),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value, onChanged: onChanged,
              activeColor: AppTheme.brandPrimary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}

// Counter tile with icon
class _CounterTile extends StatelessWidget {
  const _CounterTile({required this.label, required this.icon, required this.value, required this.onChanged});
  final String label;
  final IconData icon;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.bgScaffold,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: AppTheme.brandPrimary.withValues(alpha: 0.60)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(
            fontFamily: 'Poppins', fontSize: 12,
            fontWeight: FontWeight.w700, color: AppTheme.brandDark,
          )),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () { HapticUtils.selectionClick(); if (value > 0) onChanged(value - 1); },
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Icon(Icons.remove_rounded, size: 15),
                ),
              ),
              Text('$value', style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 20,
                fontWeight: FontWeight.w900, color: AppTheme.brandDark,
              )),
              GestureDetector(
                onTap: () { HapticUtils.selectionClick(); if (value < 10) onChanged(value + 1); },
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    gradient: AppTheme.brandGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_rounded, size: 15, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Slider section with min/max pills
class _SliderSection extends StatelessWidget {
  const _SliderSection({required this.minLabel, required this.maxLabel, required this.child});
  final String minLabel, maxLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Pill(minLabel),
            Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.grey.shade400),
            _Pill(maxLabel),
          ],
        ),
        child,
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.brandPrimary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.brandPrimary.withValues(alpha: 0.18)),
      ),
      child: Text(text, style: const TextStyle(
        fontFamily: 'Poppins', fontSize: 13,
        fontWeight: FontWeight.w700, color: AppTheme.brandPrimary,
      )),
    );
  }
}