import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/haptic_utils.dart';

import '../widgets/onboarding_step_header.dart';
import '../widgets/step1_name.dart';
import '../widgets/step2_gender.dart';
import '../widgets/step3_birthday.dart';
import '../widgets/step4_height.dart';
import '../widgets/step5_community.dart';
import '../widgets/step6_photo_location.dart';
import '../widgets/onboarding_next_button.dart';
import '../widgets/celebration_overlay.dart';

// ============================================================
// 🪷 ACCOUNT CREATION SCREEN
// 6-step onboarding — new user
// Steps: Name → Gender → Birthday → Height → Community → Photo
// TODO: onboardingProvider → profileRepository.createProfile()
// ============================================================
class AccountCreationScreen extends StatefulWidget {
  const AccountCreationScreen({super.key});

  @override
  State<AccountCreationScreen> createState() => _AccountCreationScreenState();
}

class _AccountCreationScreenState extends State<AccountCreationScreen>
    with TickerProviderStateMixin {

  final PageController _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 6;

  // Step metadata — emoji + label + one-line motivational text
  static const List<Map<String, String>> _stepMeta = [
    {'emoji': '👤', 'label': 'Name',      'hint': 'Let\'s start with who you are.'},
    {'emoji': '🌸', 'label': 'Gender',    'hint': 'One tap — helps us personalise.'},
    {'emoji': '🎂', 'label': 'Birthday',  'hint': 'Every great match has perfect timing.'},
    {'emoji': '📏', 'label': 'Height',    'hint': 'Almost there, keep going!'},
    {'emoji': '🤝', 'label': 'Community', 'hint': 'Your roots shape your identity.'},
    {'emoji': '📸', 'label': 'Photo',     'hint': 'Last step — the VIP Lounge awaits!'},
  ];

  // ── Step 1 ────────────────────────────────────────────────
  String _profileFor = '';
  final TextEditingController _firstNameCtrl = TextEditingController();
  final TextEditingController _lastNameCtrl  = TextEditingController();
  static const List<String> _forOptions = [
    'Myself', 'Son', 'Daughter', 'Brother', 'Sister', 'Relative',
  ];

  // ── Step 2 ────────────────────────────────────────────────
  String _gender = '';

  // ── Step 3 ────────────────────────────────────────────────
  DateTime _dob = DateTime(2000, 1, 1);
  bool _dobTouched = false;

  // ── Step 4 ────────────────────────────────────────────────
  int _feet = 5, _inches = 4;

  // ── Step 5 ────────────────────────────────────────────────
  String _gotra = '';
  static const List<String> _gotraList = [
    'Rathod', 'Chavan', 'Pawar', 'Jadhav',
    'Ade', 'Naik', 'Muqayya', 'Gormati',
  ];

  // ── Step 6 ────────────────────────────────────────────────
  bool _photoUploaded = false;
  int _scanStep = 0; // 0=idle 1=scanning 2=done


  // ── Celebration ───────────────────────────────────────────
  bool _celebrate = false;

  // ── Helpers ───────────────────────────────────────────────
  String get _firstName {
    final n = _firstNameCtrl.text.trim();
    return n.isEmpty ? '' : n.split(' ').first;
  }

  bool get _canNext {
    switch (_currentStep) {
      case 0: return _profileFor.isNotEmpty &&
          _firstNameCtrl.text.trim().length >= 2 &&
          _lastNameCtrl.text.trim().length >= 2;
      case 1: return _gender.isNotEmpty;
      case 2: return _dobTouched;
      case 3: return true;
      case 4: return _gotra.isNotEmpty;
      case 5: return _photoUploaded && _scanStep == 2;
      default: return false;
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _firstNameCtrl.addListener(() => setState(() {}));
    _lastNameCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (!_canNext) { HapticUtils.errorVibrate(); return; }
    FocusScope.of(context).unfocus();
    if (_currentStep < _totalSteps - 1) {
      HapticUtils.lightImpact();
      setState(() => _currentStep++);
      _pageController.animateToPage(_currentStep,
          duration: const Duration(milliseconds: 480),
          curve: Curves.easeOutCubic);
    } else {
      HapticUtils.heavyImpact();
      setState(() => _celebrate = true);
      Future.delayed(const Duration(milliseconds: 2600), () {
        if (mounted) context.go('/dashboard');
      });
    }
  }

  void _prev() {
    FocusScope.of(context).unfocus();
    if (_currentStep > 0) {
      HapticUtils.lightImpact();
      setState(() => _currentStep--);
      _pageController.animateToPage(_currentStep,
          duration: const Duration(milliseconds: 480),
          curve: Curves.easeOutCubic);
    } else {
      context.pop();
    }
  }

  void _onPhotoTap() {
    if (_photoUploaded) return;
    HapticUtils.mediumImpact();
    setState(() { _photoUploaded = true; _scanStep = 1; });
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) { setState(() => _scanStep = 2); HapticUtils.heavyImpact(); }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final kbOpen    = MediaQuery.of(context).viewInsets.bottom > 0;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.bgScaffold,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            _ambientGlow(),
            SafeArea(
              child: Column(
                children: [
                  // Progress header
                  OnboardingStepHeader(
                    current: _currentStep,
                    total: _totalSteps,
                    meta: _stepMeta,
                    onBack: _prev,
                  ),

                  // Hint text — one line, subtle
                  _HintBanner(
                    key: ValueKey(_currentStep),
                    text: _stepMeta[_currentStep]['hint']!,
                  ),
                  const SizedBox(height: 4),

                  // Page content
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        Step1Name(
                          profileFor: _profileFor, forOptions: _forOptions,
                          firstCtrl: _firstNameCtrl, lastCtrl: _lastNameCtrl,
                          onForChanged: (v) => setState(() => _profileFor = v),
                        ),
                        Step2Gender(
                          gender: _gender, firstName: _firstName,
                          onChanged: (v) => setState(() => _gender = v),
                        ),
                        Step3Birthday(
                          dob: _dob, touched: _dobTouched,
                          firstName: _firstName, isFemale: _gender == 'Female',
                          onChanged: (d) => setState(() { _dob = d; _dobTouched = true; }),
                        ),
                        Step4Height(
                          feet: _feet, inches: _inches,
                          firstName: _firstName, isFemale: _gender == 'Female',
                          onFeetChanged: (v) => setState(() => _feet = v),
                          onInchesChanged: (v) => setState(() => _inches = v),
                        ),
                        Step5Community(
                          gotra: _gotra, gotraList: _gotraList,
                          firstName: _firstName,
                          onGotraChanged: (v) => setState(() => _gotra = v),
                        ),
                        Step6PhotoLocation(
                          uploaded: _photoUploaded, scanStep: _scanStep,
                          firstName: _firstName,
                          onPhotoTap: _onPhotoTap,
                        ),
                      ],
                    ),
                  ),

                  // Next button
                  OnboardingNextButton(
                    enabled: _canNext,
                    isLast: _currentStep == _totalSteps - 1,
                    bottom: kbOpen ? 15 : bottomPad + 16,
                    onTap: _next,
                  ),
                ],
              ),
            ),

            if (_celebrate) CelebrationOverlay(firstName: _firstName),
          ],
        ),
      ),
    );
  }

  Widget _ambientGlow() {
    return Stack(children: [
      AnimatedPositioned(
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOutCubic,
        top: _currentStep.isOdd ? 180 : -60,
        left: _currentStep.isEven ? -60 : null,
        right: _currentStep.isOdd ? -60 : null,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
          child: Container(
            width: 240, height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.brandPrimary.withValues(alpha: 0.09),
            ),
          ),
        ),
      ),
    ]);
  }
}

// ── Hint banner — subtle, one line ───────────────────────────
class _HintBanner extends StatelessWidget {
  const _HintBanner({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.25),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: Padding(
        key: ValueKey(text),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}